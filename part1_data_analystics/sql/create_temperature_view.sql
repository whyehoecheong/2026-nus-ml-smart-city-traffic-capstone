-- ====================================================================
-- Script: create_temperature_view.sql
-- Description: Creates a cleaned and converted SQL View for Temperature
--              and Weather Analysis on Metro_Interstate_Traffic_Volume.
-- ====================================================================

DROP VIEW IF EXISTS v_temperature_analysis;

CREATE VIEW v_temperature_analysis AS
SELECT 
    -- Timestamps and Date Parts
    field8 AS date_time,
    substr(field8, 1, 10) AS date,
    substr(field8, 1, 4)  AS year,
    substr(field8, 6, 2)  AS month,
    substr(field8, 9, 2)  AS day,
    CAST(substr(field8, 12, 2) AS INTEGER) AS hour,
    
    -- Holiday
    CASE 
        WHEN field1 = 'None' OR field1 IS NULL THEN NULL 
        ELSE field1 
    END AS holiday,

    -- Raw Temperature (Kelvin)
    CAST(field2 AS REAL) AS temp_kelvin,

    -- Converted Temperatures (handling 0 K sensor anomalies as NULL)
    CASE 
        WHEN CAST(field2 AS REAL) > 0 THEN ROUND(CAST(field2 AS REAL) - 273.15, 2)
        ELSE NULL 
    END AS temp_celsius,

    CASE 
        WHEN CAST(field2 AS REAL) > 0 THEN ROUND((CAST(field2 AS REAL) - 273.15) * 9.0 / 5.0 + 32.0, 2)
        ELSE NULL 
    END AS temp_fahrenheit,

    -- Weather Attributes
    CAST(field3 AS REAL) AS rain_1h,
    CAST(field4 AS REAL) AS snow_1h,
    CAST(field5 AS INTEGER) AS clouds_all,
    field6 AS weather_main,
    field7 AS weather_description,

    -- Traffic Volume
    CAST(field9 AS INTEGER) AS traffic_volume

FROM Metro_Interstate_Traffic_Volume
WHERE field8 != 'date_time';
