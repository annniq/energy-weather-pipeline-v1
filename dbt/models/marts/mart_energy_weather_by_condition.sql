{{
    config(
        materialized='incremental',
        unique_key=[
            'country_code',
            'date_utc',
            'temperature_category',
            'wind_category',
            'solar_category',  
            'cloud_category',  
            'is_daylight_hour'
        ]
    )
}}

with filtered_source as (
    select *
    from {{ ref('fct_energy_weather_hourly') }}

    {% if is_incremental() %}
    -- Võtame alustabelist andmed, mis on samal päeval või uuemad kui sihttabeli max kuupäev.
    -- dbt asendab muutunud read automaatselt tänu unique_key-le.
    where date_utc >= (select max(date_utc) from {{ this }})
    {% endif %}
),

condition_summary as (
    select
        country_code,
        date_utc,
        temperature_category,
        wind_category,
        solar_category,
        cloud_category,
        is_daylight_hour,
        count(*) as hourly_observation_count,
        avg(price_eur_mwh) as avg_price_eur_mwh,
        avg(temperature_2m_c) as avg_temperature_2m_c,
        avg(wind_speed_10m_kmh) as avg_wind_speed_10m_kmh,
        avg(shortwave_radiation) as avg_shortwave_radiation,
        avg(cloud_cover) as avg_cloud_cover
    from filtered_source
    group by
        country_code,
        date_utc,
        temperature_category,
        wind_category,
        solar_category,
        cloud_category,
        is_daylight_hour
)

select
    country_code,
    date_utc,
    temperature_category,
    wind_category,
    solar_category,
    cloud_category,
    is_daylight_hour,
    hourly_observation_count,
    avg_price_eur_mwh,
    avg_temperature_2m_c,
    avg_wind_speed_10m_kmh,
    avg_shortwave_radiation,
    avg_cloud_cover
from condition_summary