-- Task 2.1
 WITH clean_data AS (
        SELECT CAST(field9 AS REAL) AS volume
        FROM Metro_Interstate_Traffic_Volume
        WHERE field8 != 'date_time'
    ),
    stats AS (
        SELECT 
            COUNT(*) AS count,
            AVG(volume) AS mean,
            MIN(volume) AS min_val,
            MAX(volume) AS max_val,
            MAX(volume) - MIN(volume) AS range,
            AVG(volume * volume) - (AVG(volume) * AVG(volume)) AS variance,
            SQRT(AVG(volume * volume) - (AVG(volume) * AVG(volume))) AS std_dev
        FROM clean_data
    ),
    ordered AS (
        SELECT volume,
               ROW_NUMBER() OVER (ORDER BY volume) AS row_num,
               COUNT(*) OVER () AS total_rows
        FROM clean_data
    ),
    median_calc AS (
        SELECT AVG(volume) AS median
        FROM ordered
        WHERE row_num IN ((total_rows + 1) / 2, (total_rows + 2) / 2)
    )
    SELECT 
        s.count,
        ROUND(s.mean, 2) AS mean,
        ROUND(m.median, 2) AS median,
        ROUND(s.std_dev, 2) AS std_dev,
        ROUND(s.variance, 2) AS variance,
        s.min_val,
        s.max_val,
        s.range
    FROM stats s, median_calc m;
	
	-- Task 2.2
	 WITH clean_data AS (
        SELECT 
            CAST(field2 AS REAL) AS temp,
            CAST(field9 AS REAL) AS volume
        FROM Metro_Interstate_Traffic_Volume
        WHERE field8 != 'date_time'
          AND CAST(field2 AS REAL) > 0
    ),
    stats AS (
        SELECT 
            COUNT(*) AS n,
            SUM(temp) AS sum_x,
            SUM(volume) AS sum_y,
            SUM(temp * volume) AS sum_xy,
            SUM(temp * temp) AS sum_x2,
            SUM(volume * volume) AS sum_y2
        FROM clean_data
    )
    SELECT 
        n AS total_records,
        ROUND(
            (n * sum_xy - sum_x * sum_y) / 
            (SQRT(n * sum_x2 - sum_x * sum_x) * SQRT(n * sum_y2 - sum_y * sum_y)), 
            4
        ) AS correlation_coefficient_r
    FROM stats;
	
	