{{
    config(
        materialized='incremental',
        unique_key=[
            'country_code',
            'date_utc',
            'temperature_band',
            'wind_band',
            'is_daylight_hour'
        ]
    )
}}

with condition_summary as (
    select
        country_code,
        date_utc,
        temperature_band,
        wind_band,
        is_daylight_hour,
        count(*) as hourly_observation_count,
        avg(price_eur_mwh) as avg_price_eur_mwh,
        avg(temperature_2m_c) as avg_temperature_2m_c,
        avg(wind_speed_10m_kmh) as avg_wind_speed_10m_kmh,
        avg(shortwave_radiation) as avg_shortwave_radiation,
        avg(cloud_cover) as avg_cloud_cover
    from {{ ref('fct_energy_weather_hourly') }}
    group by
        country_code,
        date_utc,
        temperature_band,
        wind_band,
        is_daylight_hour
)

select
    country_code,
    date_utc,
    temperature_band,
    wind_band,
    is_daylight_hour,
    hourly_observation_count,
    avg_price_eur_mwh,
    avg_temperature_2m_c,
    avg_wind_speed_10m_kmh,
    avg_shortwave_radiation,
    avg_cloud_cover
from condition_summary

{% if is_incremental() %}
where not exists (
    select 1
    from {{ this }} as existing_rows
    where existing_rows.country_code = condition_summary.country_code
        and existing_rows.date_utc = condition_summary.date_utc
        and existing_rows.temperature_band = condition_summary.temperature_band
        and existing_rows.wind_band = condition_summary.wind_band
        and existing_rows.is_daylight_hour = condition_summary.is_daylight_hour
)
{% endif %}
