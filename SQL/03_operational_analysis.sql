-- SQL Dialect: SQLite
-- Developed using SQLite for data analysis and Power BI preparation.



-- Create delivery analysis table
CREATE TABLE delivery_analysis AS
SELECT order_id,review_score,product_category_name,customer_state,
CAST(julianday(DATE(order_delivered_customer_date))-julianday(DATE(order_estimated_delivery_date))AS INTEGER) AS delay_days
FROM master_olist;


-- Review score distribution
SELECT review_score,
COUNT(review_score) AS number_of_reviews
FROM master_olist
GROUP BY review_score
HAVING review_score>=1
ORDER BY review_score DESC;

-- Delivery delay analysis
SELECT order_id,
CAST(julianday(DATE(order_delivered_customer_date))-julianday(DATE(order_estimated_delivery_date))AS INTEGER) AS delivery_status
FROM master_olist
ORDER BY delivery_status ASC; -- negative 147 days is suspicious

SELECT
MIN(CAST(julianday(DATE(order_delivered_customer_date))-julianday(DATE(order_estimated_delivery_date))AS INTEGER)) AS min_delay,
MAX(CAST(julianday(DATE(order_delivered_customer_date))-julianday(DATE(order_estimated_delivery_date))AS INTEGER)) AS max_delay
FROM master_olist;

SELECT
COUNT(*) AS extreme_early_orders
FROM master_olist
WHERE CAST(julianday(DATE(order_delivered_customer_date))-julianday(DATE(order_estimated_delivery_date))AS INTEGER)<-30;


-- Delivery status classification
SELECT order_id,delay_days,
CASE WHEN delay_days<-90 THEN 'Extreme Early'
WHEN delay_days<0 THEN 'Early'
WHEN delay_days=0 THEN 'On-Time'
ELSE 'Late'
END AS delivery_status
FROM delivery_analysis;

WITH a AS
(SELECT order_id,review_score,
CASE WHEN delay_days<-90 THEN 'Extreme Early'
WHEN delay_days<0 THEN 'Early'
WHEN delay_days=0 THEN 'On-Time'
ELSE 'Late'
END AS delivery_status
FROM delivery_analysis)
SELECT  delivery_status,
COUNT(*) AS total_orders,
ROUND(AVG(review_score),2) AS avg_review_score
FROM a
GROUP BY delivery_status
ORDER BY avg_review_score DESC;


-- Lowest rated product categories
SELECT product_category_name,
COUNT(DISTINCT order_id) AS total_orders,
ROUND(AVG(review_score),2) AS avg_review_score
FROM master_olist
GROUP BY product_category_name
ORDER BY avg_review_score ASC;

-- Lowest rated states
SELECT customer_state,
COUNT(DISTINCT order_id) AS total_orders,
ROUND(AVG(review_score),2) AS avg_review_score
FROM master_olist
GROUP BY customer_state
ORDER BY avg_review_score ASC;
