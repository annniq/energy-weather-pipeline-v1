select
    country_code,
    timestamp_utc,
    count(*) as row_count
from {{ ref('fct_energy_weather_hourly') }}
group by
    country_code,
    timestamp_utc
having count(*) > 1
