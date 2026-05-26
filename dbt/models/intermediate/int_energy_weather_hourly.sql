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
        
        -- Kellaaja kategooria
        case 
            when extract(hour from prices.timestamp_utc at time zone 'UTC')::int between 0 and 6 then 'Night'
            when extract(hour from prices.timestamp_utc at time zone 'UTC')::int between 7 and 10 then 'Morning Peak'
            when extract(hour from prices.timestamp_utc at time zone 'UTC')::int between 11 and 16 then 'Day'
            when extract(hour from prices.timestamp_utc at time zone 'UTC')::int between 17 and 20 then 'Evening Peak'
            else 'Evening'
        end as time_category,

        -- Päevavalguse loogika
        case
            when weather.shortwave_radiation > 0 then true
            else false
        end as is_daylight_hour,
        
        -- Temperatuuri kategooria
        case
            when weather.temperature_2m_c is null then 'N/A'
            when weather.temperature_2m_c < 0 then 'Freezing'
            when weather.temperature_2m_c < 10 then 'Cold'
            when weather.temperature_2m_c < 20 then 'Mild'
            else 'Warm'
        end as temperature_category,
        
        -- Tuule kategooria 
        case
            when weather.wind_speed_10m_kmh is null then 'N/A'
            when weather.wind_speed_10m_kmh < 10 then 'Low Wind'
            when weather.wind_speed_10m_kmh < 25 then 'Medium Wind'
            else 'High Wind'
        end as wind_category,
        
        -- Päikesekiirguse kategooria
        case
            when weather.shortwave_radiation is null then 'N/A'
            when weather.shortwave_radiation >= 500 then 'Very Sunny'
            when weather.shortwave_radiation >= 200 then 'Sunny'
            else 'Cloudy/Night'
        end as solar_category,
        
        -- Pilvisuse kategooria
        case 
            when weather.cloud_cover is null then 'N/A'
            when weather.cloud_cover < 20 then 'Clear Sky'
            when weather.cloud_cover between 20 and 80 then 'Partly Cloudy'
            else 'Overcast'
        end as cloud_category   

    from prices
    inner join weather
        on prices.country_code = weather.country_code
        and prices.timestamp_utc = weather.timestamp_utc
)

select *
from joined