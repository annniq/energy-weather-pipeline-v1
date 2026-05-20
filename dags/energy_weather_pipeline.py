from datetime import datetime, timedelta, timezone

import pendulum
from airflow.sdk import dag, task


EXPECTED_COUNTRIES = {"EE", "FI", "LV", "LT"}

LOCATIONS = {
    "EE": {
        "city": "Tallinn",
        "latitude": 59.4370,
        "longitude": 24.7536,
    },
    "LV": {
        "city": "Riga",
        "latitude": 56.9496,
        "longitude": 24.1052,
    },
    "LT": {
        "city": "Vilnius",
        "latitude": 54.6872,
        "longitude": 25.2797,
    },
    "FI": {
        "city": "Helsinki",
        "latitude": 60.1699,
        "longitude": 24.9384,
    },
}


@dag(
    dag_id="energy_weather_pipeline",
    schedule="30 0 * * *",
    start_date=pendulum.datetime(2026, 5, 1, tz="UTC"),
    catchup=False,
    tags=["energy", "weather", "elering", "open-meteo"],
)
def energy_weather_pipeline():
    @task
    def resolve_target_date() -> str:
        """
        Manual run config:
        {
          "target_date": "2026-05-18"
        }

        Scheduled run:
        - loads yesterday based on Airflow's logical date
        """
        from airflow.sdk import get_current_context

        context = get_current_context()
        dag_run = context.get("dag_run")
        conf = dag_run.conf if dag_run and dag_run.conf else {}

        if conf and "target_date" not in conf:
            raise ValueError(
                "Invalid DAG config. Use only: {'target_date': 'YYYY-MM-DD'}"
            )

        if "target_date" in conf:
            target_date = datetime.strptime(conf["target_date"], "%Y-%m-%d").date()
            return str(target_date)

        data_interval_start = context.get("data_interval_start")

        if data_interval_start is not None:
            logical_date = data_interval_start.in_timezone("UTC").date()
        else:
            logical_date = pendulum.now("UTC").date()

        target_date = logical_date - timedelta(days=1)

        return str(target_date)

    @task(retries=3, retry_delay=timedelta(minutes=1))
    def extract_elering_prices(target_date: str) -> str:
        """
        Downloads Elering NPS spot prices for one UTC calendar day.

        The endpoint returns electricity price timestamps.
        No hourly expansion is done.
        """
        import json
        import urllib.parse
        import urllib.request

        start_str = f"{target_date}T00:00:00.000Z"
        end_str = f"{target_date}T23:45:00.000Z"

        params = urllib.parse.urlencode(
            {
                "start": start_str,
                "end": end_str,
            }
        )

        url = f"https://dashboard.elering.ee/api/nps/price?{params}"

        with urllib.request.urlopen(url, timeout=60) as response:
            if response.status != 200:
                raise RuntimeError(f"Elering API failed with status {response.status}")

            payload = json.loads(response.read().decode("utf-8"))

        if "data" not in payload:
            raise RuntimeError("Elering API response does not contain 'data' field")

        output_path = f"/tmp/elering_prices_{target_date}.json"

        with open(output_path, "w", encoding="utf-8") as file:
            json.dump(
                {
                    "target_date": target_date,
                    "source_url": url,
                    "payload": payload,
                },
                file,
                ensure_ascii=False,
                indent=2,
            )

        return output_path

    @task
    def load_elering_prices(raw_file_path: str) -> int:
        """
        Loads Elering prices into:
        staging.elering_prices
        """
        import json
        from datetime import datetime, timezone

        from airflow.providers.postgres.hooks.postgres import PostgresHook

        with open(raw_file_path, "r", encoding="utf-8") as file:
            wrapper = json.load(file)

        target_date = wrapper["target_date"]
        payload = wrapper["payload"]

        rows = []

        for country_code, prices in payload.get("data", {}).items():
            country_code = country_code.upper()

            if country_code not in EXPECTED_COUNTRIES:
                continue

            for item in prices:
                timestamp_utc = datetime.fromtimestamp(
                    int(item["timestamp"]),
                    tz=timezone.utc,
                )

                if str(timestamp_utc.date()) != target_date:
                    continue

                rows.append(
                    (
                        country_code,
                        timestamp_utc,
                        float(item["price"]),
                        target_date,
                        "elering_nps",
                    )
                )

        if not rows:
            raise RuntimeError("No Elering price rows found to load")

        hook = PostgresHook(postgres_conn_id="analytics_db")

        insert_sql = """
            INSERT INTO staging.elering_prices (
                country_code,
                timestamp_utc,
                price_eur_mwh,
                price_date,
                source
            )
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (country_code, timestamp_utc)
            DO UPDATE SET
                price_eur_mwh = EXCLUDED.price_eur_mwh,
                price_date = EXCLUDED.price_date,
                source = EXCLUDED.source,
                loaded_at = NOW();
        """

        conn = hook.get_conn()

        try:
            with conn.cursor() as cursor:
                cursor.executemany(insert_sql, rows)

            conn.commit()
        finally:
            conn.close()

        return len(rows)

    @task(retries=3, retry_delay=timedelta(minutes=1))
    def extract_open_meteo_weather(target_date: str) -> str:
        """
        Downloads Open-Meteo 15-minute weather data for one UTC calendar day.
        """
        import json
        import urllib.parse
        import urllib.request

        all_weather = {}

        for country_code, location in LOCATIONS.items():
            params = urllib.parse.urlencode(
                {
                    "latitude": location["latitude"],
                    "longitude": location["longitude"],
                    "start_date": target_date,
                    "end_date": target_date,
                    "minutely_15": (
                        "temperature_2m,"
                        "wind_speed_10m,"
                        "shortwave_radiation,"
                        "cloud_cover"
                    ),
                    "timezone": "UTC",
                }
            )

            url = f"https://api.open-meteo.com/v1/forecast?{params}"

            with urllib.request.urlopen(url, timeout=60) as response:
                if response.status != 200:
                    raise RuntimeError(
                        f"Open-Meteo API failed for {country_code} "
                        f"with status {response.status}"
                    )

                payload = json.loads(response.read().decode("utf-8"))

            if "minutely_15" not in payload:
                raise RuntimeError(
                    f"Open-Meteo response for {country_code} "
                    "does not contain 'minutely_15'"
                )

            all_weather[country_code] = {
                "location": location,
                "source_url": url,
                "payload": payload,
            }

        output_path = f"/tmp/open_meteo_weather_{target_date}.json"

        with open(output_path, "w", encoding="utf-8") as file:
            json.dump(
                {
                    "target_date": target_date,
                    "countries": all_weather,
                },
                file,
                ensure_ascii=False,
                indent=2,
            )

        return output_path

    @task
    def load_open_meteo_weather(raw_file_path: str) -> int:
        """
        Loads Open-Meteo weather data into:
        staging.open_meteo_weather
        """
        import json
        from datetime import datetime, timezone

        from airflow.providers.postgres.hooks.postgres import PostgresHook

        with open(raw_file_path, "r", encoding="utf-8") as file:
            wrapper = json.load(file)

        target_date = wrapper["target_date"]
        countries = wrapper["countries"]

        rows = []

        for country_code, country_payload in countries.items():
            minutely = country_payload["payload"]["minutely_15"]

            times = minutely.get("time", [])
            temperatures = minutely.get("temperature_2m", [])
            wind_speeds = minutely.get("wind_speed_10m", [])
            radiation = minutely.get("shortwave_radiation", [])
            cloud_cover = minutely.get("cloud_cover", [])

            for index, time_value in enumerate(times):
                timestamp_utc = datetime.fromisoformat(time_value).replace(
                    tzinfo=timezone.utc
                )

                if str(timestamp_utc.date()) != target_date:
                    continue

                rows.append(
                    (
                        country_code,
                        timestamp_utc,
                        temperatures[index],
                        wind_speeds[index],
                        radiation[index],
                        cloud_cover[index],
                        target_date,
                        "open_meteo",
                    )
                )

        if not rows:
            raise RuntimeError("No Open-Meteo weather rows found to load")

        hook = PostgresHook(postgres_conn_id="analytics_db")

        insert_sql = """
            INSERT INTO staging.open_meteo_weather (
                country_code,
                timestamp_utc,
                temperature_2m_c,
                wind_speed_10m_kmh,
                shortwave_radiation,
                cloud_cover,
                weather_date,
                source
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (country_code, timestamp_utc)
            DO UPDATE SET
                temperature_2m_c = EXCLUDED.temperature_2m_c,
                wind_speed_10m_kmh = EXCLUDED.wind_speed_10m_kmh,
                shortwave_radiation = EXCLUDED.shortwave_radiation,
                cloud_cover = EXCLUDED.cloud_cover,
                weather_date = EXCLUDED.weather_date,
                source = EXCLUDED.source,
                loaded_at = NOW();
        """

        conn = hook.get_conn()

        try:
            with conn.cursor() as cursor:
                cursor.executemany(insert_sql, rows)

            conn.commit()
        finally:
            conn.close()

        return len(rows)

    target_date = resolve_target_date()

    prices_raw_file = extract_elering_prices(target_date)
    weather_raw_file = extract_open_meteo_weather(target_date)

    prices_loaded = load_elering_prices(prices_raw_file)
    weather_loaded = load_open_meteo_weather(weather_raw_file)

    [prices_loaded, weather_loaded]


energy_weather_pipeline()