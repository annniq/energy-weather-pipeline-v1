CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.elering_prices (
    country_code        VARCHAR(2) NOT NULL,
    timestamp_utc      TIMESTAMPTZ NOT NULL,
    price_eur_mwh      NUMERIC(12,4) NOT NULL,
    price_date         DATE NOT NULL,
    source             VARCHAR(50) NOT NULL DEFAULT 'elering_nps',
    loaded_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (country_code, timestamp_utc)
);

CREATE TABLE IF NOT EXISTS staging.open_meteo_weather (
    country_code            VARCHAR(2) NOT NULL,
    timestamp_utc           TIMESTAMPTZ NOT NULL,
    temperature_2m_c        NUMERIC(6,2),
    wind_speed_10m_kmh      NUMERIC(6,2),
    shortwave_radiation     NUMERIC(10,2),
    cloud_cover             NUMERIC(6,2),
    weather_date            DATE NOT NULL,
    source                  VARCHAR(50) NOT NULL DEFAULT 'open_meteo_archive',
    loaded_at               TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (country_code, timestamp_utc)
);