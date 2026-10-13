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