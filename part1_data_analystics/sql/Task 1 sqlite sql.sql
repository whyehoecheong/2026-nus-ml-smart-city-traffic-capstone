CREATE VIEW IF NOT EXISTS v_annual_traffic_comparison AS
    WITH yearly_summary AS (
        SELECT 
            substr(field8, 1, 4) AS year,
            SUM(CAST(field9 AS INTEGER)) AS total_traffic_volume
        FROM Metro_Interstate_Traffic_Volume
        WHERE field8 != 'date_time'
          AND substr(field8, 1, 4) BETWEEN '2012' AND '2017'
        GROUP BY year
    )
    SELECT 
        year,
        LAG(total_traffic_volume) OVER (ORDER BY year) AS prev_year_traffic,
        total_traffic_volume AS current_year_traffic,
        total_traffic_volume - LAG(total_traffic_volume) OVER (ORDER BY year) AS volume_difference,
        ROUND(
            (total_traffic_volume - LAG(total_traffic_volume) OVER (ORDER BY year)) * 100.0 / 
            LAG(total_traffic_volume) OVER (ORDER BY year), 
            2
        ) || '%' AS pct_change,
        CASE 
            WHEN LAG(total_traffic_volume) OVER (ORDER BY year) IS NULL THEN 'Baseline'
            WHEN total_traffic_volume > LAG(total_traffic_volume) OVER (ORDER BY year) THEN 'Increase'
            WHEN total_traffic_volume < LAG(total_traffic_volume) OVER (ORDER BY year) THEN 'Decrease'
            ELSE 'No Change'
        END AS trend
    FROM yearly_summary
    ORDER BY year;
    
	
	SELECT * FROM v_annual_traffic_comparison;

	  WITH yearly_summary AS (
        SELECT 
            substr(field8, 1, 4) AS year,
            SUM(CAST(field9 AS INTEGER)) AS total_traffic_volume
        FROM Metro_Interstate_Traffic_Volume
        WHERE field8 != 'date_time'
        GROUP BY year
    )
    SELECT 
        year,
        LAG(total_traffic_volume) OVER (ORDER BY year) AS prev_year_traffic,
        total_traffic_volume AS current_year_traffic,
        total_traffic_volume - LAG(total_traffic_volume) OVER (ORDER BY year) AS volume_difference,
        ROUND(
            (total_traffic_volume - LAG(total_traffic_volume) OVER (ORDER BY year)) * 100.0 / 
            LAG(total_traffic_volume) OVER (ORDER BY year), 
            2
        ) || '%' AS pct_change,
        CASE 
            WHEN LAG(total_traffic_volume) OVER (ORDER BY year) IS NULL THEN 'Baseline'
            WHEN total_traffic_volume > LAG(total_traffic_volume) OVER (ORDER BY year) THEN 'Increase'
            WHEN total_traffic_volume < LAG(total_traffic_volume) OVER (ORDER BY year) THEN 'Decrease'
            ELSE 'No Change'
        END AS trend
    FROM yearly_summary
	
	   SELECT 
        date,
        holiday,
        ROUND(AVG(temp_celsius), 1) AS avg_celsius,
        ROUND(AVG(temp_fahrenheit), 1) AS avg_fahrenheit,
        MIN(temp_celsius) AS min_celsius,
        MAX(temp_celsius) AS max_celsius,
        ROUND(AVG(traffic_volume), 0) AS avg_hourly_traffic
    FROM v_temperature_analysis
    WHERE date IN ('2015-01-01', '2015-09-07', '2016-01-01', '2016-09-05', '2017-01-01', '2017-01-02', '2017-09-04')
    GROUP BY date
    ORDER BY date;
	
	
	
	-- Temperature
	WITH holiday_dates AS (
        SELECT '2015 New Year''s Day' AS holiday, '2015-01-01' AS target_date UNION ALL
        SELECT '2015 Labor Day', '2015-09-07' UNION ALL
        SELECT '2016 New Year''s Day', '2016-01-01' UNION ALL
        SELECT '2016 Labor Day', '2016-09-05' UNION ALL
        SELECT '2017 New Year''s Day', '2017-01-01' UNION ALL
        SELECT '2017 New Year''s Observed (Jan 2)', '2017-01-02' UNION ALL
        SELECT '2017 Labor Day', '2017-09-04'
    )
    SELECT 
        h.holiday,
        h.target_date,
        COUNT(t.field2) AS hours_recorded,
        ROUND(AVG(CAST(t.field2 AS REAL)), 2) AS avg_kelvin,
        ROUND(AVG(CAST(t.field2 AS REAL)) - 273.15, 1) || ' °C' AS avg_celsius,
        ROUND((AVG(CAST(t.field2 AS REAL)) - 273.15) * 9.0 / 5.0 + 32, 1) || ' °F' AS avg_fahrenheit,
        ROUND(MIN(CAST(t.field2 AS REAL)) - 273.15, 1) || ' °C' AS min_celsius,
        ROUND(MAX(CAST(t.field2 AS REAL)) - 273.15, 1) || ' °C' AS max_celsius
    FROM holiday_dates h
    LEFT JOIN Metro_Interstate_Traffic_Volume t 
        ON substr(t.field8, 1, 10) = h.target_date 
        AND t.field8 != 'date_time'
    GROUP BY h.holiday, h.target_date
    ORDER BY h.target_date;
	
	
	-- create temp VIEW
	CREATE VIEW v_temperature_analysis AS
    SELECT 
        -- Timestamps and Date Parts
        field8 AS date_time,
        substr(field8, 1, 10) AS date,
        substr(field8, 1, 4)  AS year,
        substr(field8, 6, 2)  AS month,
        substr(field8, 9, 2)  AS day,
        CAST(substr(field8, 12, 2) AS INTEGER) AS hour,
        
        -- Cleaned Holiday ('None' converted to NULL)
        CASE 
            WHEN field1 = 'None' OR field1 IS NULL THEN NULL 
            ELSE field1 
        END AS holiday,
    
        -- Raw Temperature (Kelvin)
        CAST(field2 AS REAL) AS temp_kelvin,
    
        -- Converted Temperatures (sensor errors of 0 K treated as NULL)
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
	
	-- Holiday temperature VIEW
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
        -- Deduplicate hours where multiple weather records exist for the same timestamp
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
	
	 SELECT * 
    FROM v_holiday_traffic_temp_comparison 
    WHERE year IN ('2015', '2016', '2017') ;