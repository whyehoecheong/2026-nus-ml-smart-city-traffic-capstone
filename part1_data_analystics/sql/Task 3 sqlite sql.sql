-- Task 3.1
	 WITH totals AS (
        SELECT 
            COUNT(*) * 1.0 AS total_n,
            SUM(CASE WHEN CAST(field9 AS INTEGER) > 5500 THEN 1 ELSE 0 END) AS cnt_congestion,
            SUM(CASE WHEN field6 = 'Clear' THEN 1 ELSE 0 END) AS cnt_clear,
            SUM(CASE WHEN CAST(field9 AS INTEGER) > 5500 AND field6 = 'Clear' THEN 1 ELSE 0 END) AS cnt_both
        FROM Metro_Interstate_Traffic_Volume
        WHERE field8 != 'date_time'
    )
    SELECT 
        'P(Congestion)' AS Event,
        cnt_congestion AS Count,
        ROUND(cnt_congestion / total_n, 4) AS Probability_Decimal,
        ROUND((cnt_congestion / total_n) * 100.0, 2) || '%' AS Percentage
    FROM totals
    UNION ALL
    SELECT 
        'P(Clear Weather)' AS Event,
        cnt_clear AS Count,
        ROUND(cnt_clear / total_n, 4) AS Probability_Decimal,
        ROUND((cnt_clear / total_n) * 100.0, 2) || '%' AS Percentage
    FROM totals
    UNION ALL
    SELECT 
        'P(Congestion AND Clear Weather)' AS Event,
        cnt_both AS Count,
        ROUND(cnt_both / total_n, 4) AS Probability_Decimal,
        ROUND((cnt_both / total_n) * 100.0, 2) || '%' AS Percentage
    FROM totals;
	
	-- 3.2
	 WITH counts AS (
        SELECT 
            COUNT(*) * 1.0 AS total_n,
            SUM(CASE WHEN CAST(field9 AS INTEGER) > 5500 THEN 1 ELSE 0 END) * 1.0 AS n_cong,
            SUM(CASE WHEN field6 = 'Clear' THEN 1 ELSE 0 END) * 1.0 AS n_clear,
            SUM(CASE WHEN field6 = 'Clear' AND CAST(field9 AS INTEGER) > 5500 THEN 1 ELSE 0 END) * 1.0 AS n_clear_and_cong,
            SUM(CASE WHEN CAST(field2 AS REAL) > 292 AND CAST(field9 AS INTEGER) > 5500 THEN 1 ELSE 0 END) * 1.0 AS n_hightemp_and_cong
        FROM Metro_Interstate_Traffic_Volume
        WHERE field8 != 'date_time'
    )
    SELECT 
        'P(Clear Weather | Congestion)' AS Metric,
        ROUND(n_clear_and_cong / n_cong, 4) AS Decimal_Value,
        ROUND((n_clear_and_cong / n_cong) * 100.0, 2) || '%' AS Percentage
    FROM counts
    UNION ALL
    SELECT 
        'P(High Temp > 292K | Congestion)',
        ROUND(n_hightemp_and_cong / n_cong, 4),
        ROUND((n_hightemp_and_cong / n_cong) * 100.0, 2) || '%'
    FROM counts
    UNION ALL
    SELECT 
        'P(A ∩ B) [Actual Joint]',
        ROUND(n_clear_and_cong / total_n, 4),
        ROUND((n_clear_and_cong / total_n) * 100.0, 2) || '%'
    FROM counts
    UNION ALL
    SELECT 
        'P(A) * P(B) [Expected if Independent]',
        ROUND((n_cong / total_n) * (n_clear / total_n), 4),
        ROUND(((n_cong / total_n) * (n_clear / total_n)) * 100.0, 2) || '%'
    FROM counts;

    -- 2. Odds Ratio
    WITH odds_data AS (
        SELECT 
            SUM(CASE WHEN field6 = 'Clear' AND CAST(field9 AS INTEGER) > 5500 THEN 1 ELSE 0 END) * 1.0 AS a,
            SUM(CASE WHEN field6 = 'Clear' AND CAST(field9 AS INTEGER) <= 5500 THEN 1 ELSE 0 END) * 1.0 AS b,
            SUM(CASE WHEN field6 = 'Clouds' AND CAST(field9 AS INTEGER) > 5500 THEN 1 ELSE 0 END) * 1.0 AS c,
            SUM(CASE WHEN field6 = 'Clouds' AND CAST(field9 AS INTEGER) <= 5500 THEN 1 ELSE 0 END) * 1.0 AS d
        FROM Metro_Interstate_Traffic_Volume
        WHERE field8 != 'date_time'
    )
    SELECT 
        ROUND(a / b, 4) AS Odds_Clear,
        ROUND(c / d, 4) AS Odds_Cloudy,
        ROUND((a * d) / (b * c), 4) AS Odds_Ratio_Clear_vs_Cloudy
    FROM odds_data;