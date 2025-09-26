SELECT a.airline_name,
       ROUND(100.0 * SUM(f.departures_on_time)::NUMERIC / NULLIF(SUM(f.sectors_flown),0), 2) AS pct_ontime
FROM facts_otp f
JOIN airlines a ON f.airline_id = a.airline_id
GROUP BY a.airline_name
ORDER BY pct_ontime DESC
LIMIT 10;


SELECT r.route_id,
       po1.port_name AS origin,
       po2.port_name AS destination,
       ROUND(100.0 * SUM(f.departures_delayed)::NUMERIC / NULLIF(SUM(f.sectors_flown),0), 2) AS pct_delayed
FROM facts_otp f
JOIN routes r ON f.route_id = r.route_id
JOIN ports po1 ON r.origin_port_id = po1.port_id
JOIN ports po2 ON r.dest_port_id = po2.port_id
GROUP BY r.route_id, po1.port_name, po2.port_name
ORDER BY pct_delayed DESC
LIMIT 10;


SELECT a.airline_name,
       ROUND(100.0 * SUM(f.cancellations)::NUMERIC / NULLIF(SUM(f.sectors_scheduled),0), 2) AS pct_cancelled
FROM facts_otp f
JOIN airlines a ON f.airline_id = a.airline_id
GROUP BY a.airline_name
ORDER BY pct_cancelled DESC;


SELECT po.port_name,
       ROUND(AVG(f.sectors_flown),2) AS avg_monthly_flights
FROM facts_otp f
JOIN routes r ON f.route_id = r.route_id
JOIN ports po ON r.origin_port_id = po.port_id
GROUP BY po.port_name
ORDER BY avg_monthly_flights DESC
LIMIT 15;


SELECT c.month_num,
       c.month_label,
       SUM(f.departures_delayed + f.arrivals_delayed) AS total_delays
FROM facts_otp f
JOIN calendar_months c ON f.cal_id = c.cal_id
GROUP BY c.month_num, c.month_label
ORDER BY c.month_num;


WITH port_stats AS (
  SELECT po.port_name,
         SUM(f.sectors_flown) AS total_flights,
         SUM(f.departures_on_time + f.arrivals_on_time) AS ontime
  FROM facts_otp f
  JOIN routes r ON f.route_id = r.route_id
  JOIN ports po ON r.origin_port_id = po.port_id
  GROUP BY po.port_name
)
SELECT CASE WHEN total_flights > 5000 THEN 'Large Port' ELSE 'Small Port' END AS port_size,
       ROUND(100.0 * SUM(ontime)::NUMERIC / NULLIF(SUM(total_flights),0),2) AS avg_pct_ontime
FROM port_stats
GROUP BY port_size;


SELECT c.year,
       SUM(f.sectors_flown) AS total_flights
FROM facts_otp f
JOIN calendar_months c ON f.cal_id = c.cal_id
JOIN airlines a ON f.airline_id = a.airline_id
WHERE a.airline_name ILIKE '%Qantas%'
GROUP BY c.year
ORDER BY c.year;


SELECT po1.port_name AS origin,
       po2.port_name AS destination,
       ROUND(100.0 * SUM(f.departures_delayed + f.arrivals_delayed)::NUMERIC / NULLIF(SUM(f.sectors_flown),0), 2) AS pct_delayed
FROM facts_otp f
JOIN routes r ON f.route_id = r.route_id
JOIN ports po1 ON r.origin_port_id = po1.port_id
JOIN ports po2 ON r.dest_port_id = po2.port_id
GROUP BY po1.port_name, po2.port_name
HAVING SUM(f.sectors_flown) > 1000
ORDER BY pct_delayed ASC
LIMIT 10;


SELECT c.year,
       ROUND(100.0 * SUM(f.departures_delayed + f.arrivals_delayed)::NUMERIC / NULLIF(SUM(f.sectors_flown),0),2) AS avg_pct_delayed
FROM facts_otp f
JOIN calendar_months c ON f.cal_id = c.cal_id
GROUP BY c.year
ORDER BY c.year;


WITH yearly AS (
  SELECT a.airline_name,
         c.year,
         ROUND(100.0 * SUM(f.departures_on_time)::NUMERIC / NULLIF(SUM(f.sectors_flown),0),2) AS pct_ontime
  FROM facts_otp f
  JOIN airlines a ON f.airline_id = a.airline_id
  JOIN calendar_months c ON f.cal_id = c.cal_id
  GROUP BY a.airline_name, c.year
)
SELECT airline_name,
       MIN(pct_ontime) AS early,
       MAX(pct_ontime) AS late,
       (MAX(pct_ontime) - MIN(pct_ontime)) AS improvement
FROM yearly
GROUP BY airline_name
ORDER BY improvement DESC
LIMIT 5;