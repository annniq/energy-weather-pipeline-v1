select
    country_code,
    date_utc,
    hourly_observation_count
from {{ ref('mart_energy_weather_daily') }}
where hourly_observation_count <> 24
