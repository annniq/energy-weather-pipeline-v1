-- Kontrollib ainult numbriliste väärtuste füüsikalisi ja äripiire intermediate kihis.
select 
    country_code,
    timestamp_utc,
    price_eur_mwh,
    temperature_2m_c,
    wind_speed_10m_kmh,
    shortwave_radiation,
    cloud_cover
from {{ ref('int_energy_weather_hourly') }}
where 
    -- 1. Elektrihinna kontroll 
    -- Üle euroopaline hinnalae min -500 €/MWh (ehk -50 senti kilovatt-tunni eest)  ja hinnalagi  5000 €/MWh
    price_eur_mwh not between -500 and 5000
    
    -- 2. Ilmaandmete vahemike kontrollid
    or temperature_2m_c not between -50 and 50  -- Soome
    or wind_speed_10m_kmh not between 0 and 125 -- 125 km/h on ligikaudu 35 m/s (täpsemalt 34,7 m/s)
    or shortwave_radiation < 0
    or cloud_cover not between 0 and 100
