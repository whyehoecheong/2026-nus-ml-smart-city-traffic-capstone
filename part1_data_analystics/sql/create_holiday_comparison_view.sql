-- ====================================================================
-- Script: create_holiday_comparison_view.sql
-- Description: Creates an SQL View to compare Traffic and Temperature 
--              between Labor Day and New Year's Day across all years.
-- ====================================================================

DROP VIEW IF EXISTS v_holiday_traffic_temp_comparison;

CREATE VIEW v_holiday_traffic_temp_comparison AS
WITH holiday_lookup AS (
    SELECT '2013-01-01' AS holiday_date, '2013' AS year, 'New Year''s Day' AS holiday_name UNION ALL
    SELECT '2013-09-02', '2013', 'Labor Day' UNION ALL
    SELECT '2014-01-01', '2014', 'New Year''s Day' UNION ALL
    SELECT '2015-09-07', '2015', 'Labor Day' UNION ALL
    SELECT '2016-01-01', '2016', 'New Year''s Day' UNION ALL
    SELECT '2016-09-05', '2016', 'Labor Day' UNION ALL
    SELECT '2017-01-01', '2017', 'New Year''s Day' UNION ALL
    SELECT '2017-01-02', '2017', 'New Year''s Day (Observed)' UNION ALL
    SELECT '2017-09-04', '2017', 'Labor Day' UNION ALL
    SELECT '2018-01-01', '2018', 'New Year''s Day' UNION ALL
    SELECT '2018-09-03', '2018', 'Labor Day'
),
hourly_clean AS (
    -- Deduplicate multi-weather condition entries per hourly timestamp
    SELECT 
        substr(field8, 1, 10) AS date_str,
        field8 AS date_time,
        MAX(CAST(field9 AS INTEGER)) AS hourly_traffic,
        AVG(CASE WHEN CAST(field2 AS REAL) > 0 THEN CAST(field2 AS REAL) END) AS hourly_temp_k
    FROM Metro_Interstate_Traffic_Volume
    WHERE field8 != 'date_time'
    GROUP BY field8
)
SELECT 
    h.holiday_name,
    h.holiday_date,
    h.year,
    COUNT(c.date_time) AS hours_recorded,
    SUM(c.hourly_traffic) AS total_daily_traffic,
    ROUND(AVG(c.hourly_traffic), 1) AS avg_hourly_traffic,
    ROUND(AVG(c.hourly_temp_k) - 273.15, 1) AS avg_temp_celsius,
    ROUND(MIN(c.hourly_temp_k) - 273.15, 1) AS min_temp_celsius,
    ROUND(MAX(c.hourly_temp_k) - 273.15, 1) AS max_temp_celsius,
    ROUND((AVG(c.hourly_temp_k) - 273.15) * 9.0 / 5.0 + 32.0, 1) AS avg_temp_fahrenheit
FROM holiday_lookup h
LEFT JOIN hourly_clean c ON c.date_str = h.holiday_date
GROUP BY h.holiday_name, h.holiday_date, h.year
ORDER BY h.holiday_date;
