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
        weather_date,
        time_category,
        is_daylight_hour,
        temperature_category,
        wind_category,
        solar_category,
        cloud_category
    from {{ ref('int_energy_weather_hourly') }}

    {% if is_incremental() %}
    -- Kui on incremental run, võetakse vaatlusse ainult uued read, mida siht-tabelis veel pole
    where not exists (
        select 1
        from {{ this }} as existing_rows
        where existing_rows.country_code = int_energy_weather_hourly.country_code
            and existing_rows.timestamp_utc = int_energy_weather_hourly.timestamp_utc
    )
    {% endif %}
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
    weather_date,
    time_category,
    is_daylight_hour,
    temperature_category,
    wind_category,
    solar_category,
    cloud_category
from source_rows