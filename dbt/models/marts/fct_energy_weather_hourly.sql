{{
    config(
        materialized='incremental',
        unique_key=['country_code', 'timestamp_utc']
    )
}}

with source_rows as (
    select
        country_code,
        timestamp_utc,
        date_utc,
        hour_utc,
        price_eur_mwh,
        temperature_2m_c,
        wind_speed_10m_kmh,
        shortwave_radiation,
        cloud_cover,
        is_daylight_hour,
        temperature_band,
        wind_band
    from {{ ref('int_energy_weather_hourly') }}
)

select
    country_code,
    timestamp_utc,
    date_utc,
    hour_utc,
    price_eur_mwh,
    temperature_2m_c,
    wind_speed_10m_kmh,
    shortwave_radiation,
    cloud_cover,
    is_daylight_hour,
    temperature_band,
    wind_band
from source_rows

{% if is_incremental() %}
where not exists (
    select 1
    from {{ this }} as existing_rows
    where existing_rows.country_code = source_rows.country_code
        and existing_rows.timestamp_utc = source_rows.timestamp_utc
)
{% endif %}
