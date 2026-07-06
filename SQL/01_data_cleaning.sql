-- Check missing values

SELECT 
COUNT(*) AS total_rows,
SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS missing_est_date, -- 0
SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_del_date  -- 2965
FROM olist_orders;

SELECT 
COUNT(*) AS total_rows,
SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS missing_productid, -- 0
SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) missing_product_category  -- 610
FROM olist_products;
UPDATE olist_products
SET product_category_name = 'UNKNOWN'
WHERE product_category_name IS NULL;


SELECT 
COUNT(*) AS total_rows,
SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS missing_review_score  -- 0
FROM olist_order_reviews;

-- Check duplicate records
SELECT 
COUNT(*) AS total_rows,
COUNT(DISTINCT order_id) AS true_order_ids
FROM olist_orders; -- no duplicates

SELECT
COUNT(*) AS total_rows,
COUNT(DISTINCT customer_id) AS true_customer_ids
FROM olist_customers_dataset; -- no duplicates

SELECT 
COUNT(*) AS total_rows, 
COUNT(DISTINCT review_id) AS true_review_ids,
(COUNT(*)-COUNT(DISTINCT review_id)) AS numberof_duplicates
FROM olist_order_reviews; -- 814 duplicates


-- Checking order status
SELECT order_status,
COUNT(*) AS totals
FROM olist_orders
GROUP BY order_status;

SELECT 
COUNT(*)
FROM olist_orders
WHERE order_status='canceled'
AND order_delivered_customer_date IS NOT NULL; -- only 6 so ok(possible error)


-- Checking review scores
SELECT
review_score,
COUNT(*)
FROM olist_order_reviews
GROUP BY review_score
ORDER BY review_score;

-- Create master dataset
CREATE TABLE master_olist AS 
SELECT 
o.order_id,

c.customer_id,
c.customer_unique_id,
c.customer_state,

o.order_status,
o.order_purchase_timestamp,
o.order_delivered_customer_date,
o.order_estimated_delivery_date,

oi.product_id,
oi.price,
oi.freight_value,

p.product_category_name,

r.review_score

FROM olist_orders o

LEFT JOIN olist_customers_dataset c
ON o.customer_id = c.customer_id

LEFT JOIN olist_order_items oi
ON o.order_id = oi.order_id

LEFT JOIN olist_products p
ON oi.product_id = p.product_id

LEFT JOIN olist_order_reviews r
ON o.order_id = r.order_id

WHERE o.order_status='delivered'; 
