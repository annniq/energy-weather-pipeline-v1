{{
    config(
        materialized='incremental',
        unique_key=['country_code', 'date_utc']
    )
}}

with daily as (
    select
        country_code,
        date_utc,
        count(*) as hourly_observation_count,
        avg(price_eur_mwh) as avg_price_eur_mwh,
        min(price_eur_mwh) as min_price_eur_mwh,
        max(price_eur_mwh) as max_price_eur_mwh,
        avg(temperature_2m_c) as avg_temperature_2m_c,
        min(temperature_2m_c) as min_temperature_2m_c,
        max(temperature_2m_c) as max_temperature_2m_c,
        avg(wind_speed_10m_kmh) as avg_wind_speed_10m_kmh,
        avg(shortwave_radiation) as avg_shortwave_radiation,
        avg(cloud_cover) as avg_cloud_cover,
        avg(case when is_daylight_hour then price_eur_mwh end) as avg_daylight_price_eur_mwh,
        avg(case when not is_daylight_hour then price_eur_mwh end) as avg_dark_hour_price_eur_mwh
    from {{ ref('fct_energy_weather_hourly') }}
    group by
        country_code,
        date_utc
)

select
    country_code,
    date_utc,
    hourly_observation_count,
    avg_price_eur_mwh,
    min_price_eur_mwh,
    max_price_eur_mwh,
    avg_temperature_2m_c,
    min_temperature_2m_c,
    max_temperature_2m_c,
    avg_wind_speed_10m_kmh,
    avg_shortwave_radiation,
    avg_cloud_cover,
    avg_daylight_price_eur_mwh,
    avg_dark_hour_price_eur_mwh
from daily

{% if is_incremental() %}
where not exists (
    select 1
    from {{ this }} as existing_rows
    where existing_rows.country_code = daily.country_code
        and existing_rows.date_utc = daily.date_utc
)
{% endif %}
