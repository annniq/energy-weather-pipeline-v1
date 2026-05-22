# dbt transformations

dbt transforms the Airflow-loaded `staging` tables into analytics schemas:

- `intermediate.int_energy_weather_hourly`: hourly joined electricity price and weather view.
- `marts.fct_energy_weather_hourly`: dashboard-ready hourly fact table.
- `marts.mart_energy_weather_daily`: daily country-level summary.
- `marts.mart_energy_weather_by_condition`: daily summary by temperature, wind and daylight buckets.

The Airflow DAG runs dbt after both ingestion branches finish:

```bash
/opt/airflow/dbt_venv/bin/dbt build --no-partial-parse --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt
```

For a manual run inside Docker:

```bash
docker compose exec airflow-scheduler /opt/airflow/dbt_venv/bin/dbt build --no-partial-parse --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt
```

For a manual run from the host machine, point dbt to the exposed database port:

```bash
$env:DBT_HOST="localhost"
$env:DBT_PORT="5433"
$env:DBT_USER="<analytics-db-user>"
$env:DBT_PASSWORD="<analytics-db-password>"
$env:DBT_DBNAME="<analytics-db-name>"
dbt build --project-dir dbt --profiles-dir dbt
```
