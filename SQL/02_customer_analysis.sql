-- SQL Dialect: SQLite
-- Developed using SQLite for data analysis and Power BI preparation.


-- Customer KPIs
SELECT ROUND(SUM(price),2) AS total_revenue
FROM master_olist; -- 13279836.59


SELECT
COUNT(DISTINCT order_id) AS total_orders
FROM master_olist;  -- 96478

SELECT
COUNT(DISTINCT customer_unique_id) AS total_customers
FROM master_olist;  -- 93358

SELECT
ROUND(
SUM(price)*1.0/ COUNT(DISTINCT order_id),2) AS avg_order_value
FROM master_olist; -- 137.65

WITH a AS 
(SELECT customer_unique_id,
COUNT(DISTINCT order_id) AS total_orders
FROM master_olist
GROUP BY customer_unique_id
ORDER BY total_orders DESC)
SELECT ROUND(COUNT(CASE WHEN total_orders>1 THEN 1 END)*100.0/COUNT(*),2) AS percentage_repeat_customers
FROM a;  -- 3%


-- RFM Analysis
SELECT
MAX(order_purchase_timestamp) AS latest_ordered_date
FROM master_olist;  -- refrence point for recency 2018-08-29 15:00:37

SELECT customer_unique_id,
ROUND(julianday('2018-08-29 15:00:37')-julianday(MAX(order_purchase_timestamp))) AS customer_recency
FROM master_olist
GROUP BY customer_unique_id
ORDER BY customer_recency ASC;

SELECT customer_unique_id,
COUNT(DISTINCT order_id) AS customer_frequency
FROM master_olist
GROUP BY customer_unique_id
ORDER BY customer_frequency DESC;

WITH a AS 
(SELECT customer_unique_id,
COUNT(DISTINCT order_id) AS customer_frequency
FROM master_olist
GROUP BY customer_unique_id
ORDER BY customer_frequency DESC)
SELECT COUNT(*) AS one_time_customers
FROM a WHERE customer_frequency=1;



SELECT customer_unique_id,
ROUND(SUM(price),2) AS customer_monetary
FROM master_olist
GROUP BY customer_unique_id
ORDER BY customer_monetary DESC


-- Pareto Analysis
SELECT customer_unique_id,
ROUND(SUM(price),2) AS revenue_per_customer
FROM master_olist
GROUP BY customer_unique_id
ORDER BY revenue_per_customer DESC;

SELECT customer_unique_id,
COUNT(DISTINCT order_id) AS total_orders
FROM master_olist
GROUP BY customer_unique_id
ORDER BY total_orders DESC;

WITH a AS
(SELECT customer_unique_id,
COUNT(DISTINCT order_id) AS total_orders
FROM master_olist
GROUP BY customer_unique_id
)
SELECT ROUND(SUM(m.price),2) AS revenue_repeated_customer
FROM a 
LEFT JOIN master_olist m
ON a.customer_unique_id=m.customer_unique_id
WHERE total_orders>1 

-- Create tables for Power BI

CREATE TABLE rfm_table AS 
SELECT customer_unique_id,
ROUND(julianday('2018-08-29 15:00:37')-julianday(MAX(order_purchase_timestamp))) AS customer_recency,
COUNT(DISTINCT order_id) AS customer_frequency,
ROUND(SUM(price),2) AS customer_monetary
FROM master_olist
GROUP BY customer_unique_id;


CREATE TABLE customer_revenue AS
SELECT customer_unique_id,
ROUND(SUM(price),2) AS revenue_per_customer
FROM master_olist
GROUP BY customer_unique_id;

CREATE TABLE cohort AS
WITH first_purchase AS
(SELECT customer_unique_id,
MIN(order_purchase_timestamp) AS first_purchase_date
FROM master_olist
GROUP BY customer_unique_id)
SELECT m.customer_unique_id,
strftime('%Y-%m', fp.first_purchase_date) AS cohort_month,
strftime('%Y-%m', m.order_purchase_timestamp) AS order_month
FROM master_olist m
JOIN first_purchase fp
ON m.customer_unique_id = fp.customer_unique_id;
