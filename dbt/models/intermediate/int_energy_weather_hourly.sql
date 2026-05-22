with prices as (
    select
        country_code,
        timestamp_utc,
        price_eur_mwh,
        price_date
    from {{ source('staging', 'elering_prices') }}
),

weather as (
    select
        country_code,
        timestamp_utc,
        temperature_2m_c,
        wind_speed_10m_kmh,
        shortwave_radiation,
        cloud_cover,
        weather_date
    from {{ source('staging', 'open_meteo_weather') }}
),

joined as (
    select
        prices.country_code,
        prices.timestamp_utc,
        prices.price_date as date_utc,
        extract(hour from prices.timestamp_utc at time zone 'UTC')::int as hour_utc,
        prices.price_eur_mwh,
        weather.temperature_2m_c,
        weather.wind_speed_10m_kmh,
        weather.shortwave_radiation,
        weather.cloud_cover,
        weather.weather_date,
        case
            when weather.shortwave_radiation > 0 then true
            else false
        end as is_daylight_hour,
        case
            when weather.temperature_2m_c is null then 'unknown'
            when weather.temperature_2m_c < 0 then 'freezing'
            when weather.temperature_2m_c < 10 then 'cold'
            when weather.temperature_2m_c < 20 then 'mild'
            else 'warm'
        end as temperature_band,
        case
            when weather.wind_speed_10m_kmh is null then 'unknown'
            when weather.wind_speed_10m_kmh < 10 then 'low_wind'
            when weather.wind_speed_10m_kmh < 25 then 'medium_wind'
            else 'high_wind'
        end as wind_band
    from prices
    inner join weather
        on prices.country_code = weather.country_code
        and prices.timestamp_utc = weather.timestamp_utc
)

select *
from joined
