---1. Number of order per days
select
	DAte(o.order_purchase_timestamp) as Day,
	COUNT(*) as "Number of orders",
	sum(oi.price+oi.freight_value) as "Revenue"
from orders o
join order_items oi on oi.order_id = o.order_id 
group by Day

---2. Number of orders per weekdays
select 
	CASE strftime('%w',o.order_purchase_timestamp)
		when "0" then "Sunday"
		when "1" then "Monday"
		when "2" then "Tuesday"
		when "3" then "Wednesday"
		when "4" then "Thursday"
		when "5" then "Friday"
		when "6" then "Saturday"
		end as "Weekdays",
		COUNT(*) as "Number of order" 
from orders o 
group by Weekdays
order by "Number of order" ASC

---3. Order by hours
select  strftime('%H',o.order_purchase_timestamp) as "Hour", 
		count(*) as "Number of order"
from orders o
group by Hour
order by "Hour";

---4. Order per hours per days
WITH OrderDayHour AS (
    SELECT
        CASE STRFTIME('%w', order_purchase_timestamp)
            WHEN '1' THEN 'Mon'
            WHEN '2' THEN 'Tue'
            WHEN '3' THEN 'Wed'
            WHEN '4' THEN 'Thu'
            WHEN '5' THEN 'Fri'
            WHEN '6' THEN 'Sat'
            WHEN '0' THEN 'Sun'
        END AS day_of_week_name,
        CAST(STRFTIME('%w', order_purchase_timestamp) AS INTEGER) AS day_of_week_int,
        CAST(STRFTIME("%H", order_purchase_timestamp) AS INTEGER) AS hour
    FROM orders
)
SELECT
    day_of_week_name,
    COUNT(CASE WHEN hour = 0 THEN 1 END) AS "0",
    COUNT(CASE WHEN hour = 1 THEN 1 END) AS "1",
    COUNT(CASE WHEN hour = 2 THEN 1 END) AS "2",
    COUNT(CASE WHEN hour = 3 THEN 1 END) AS "3",
    COUNT(CASE WHEN hour = 4 THEN 1 END) AS "4",
    COUNT(CASE WHEN hour = 5 THEN 1 END) AS "5",
    COUNT(CASE WHEN hour = 6 THEN 1 END) AS "6",
    COUNT(CASE WHEN hour = 7 THEN 1 END) AS "7",
    COUNT(CASE WHEN hour = 8 THEN 1 END) AS "8",
    COUNT(CASE WHEN hour = 9 THEN 1 END) AS "9",
    COUNT(CASE WHEN hour = 10 THEN 1 END) AS "10",
    COUNT(CASE WHEN hour = 11 THEN 1 END) AS "11",
    COUNT(CASE WHEN hour = 12 THEN 1 END) AS "12",
    COUNT(CASE WHEN hour = 13 THEN 1 END) AS "13",
    COUNT(CASE WHEN hour = 14 THEN 1 END) AS "14",
    COUNT(CASE WHEN hour = 15 THEN 1 END) AS "15",
    COUNT(CASE WHEN hour = 16 THEN 1 END) AS "16",
    COUNT(CASE WHEN hour = 17 THEN 1 END) AS "17",
    COUNT(CASE WHEN hour = 18 THEN 1 END) AS "18",
    COUNT(CASE WHEN hour = 19 THEN 1 END) AS "19",
    COUNT(CASE WHEN hour = 20 THEN 1 END) AS "20",
    COUNT(CASE WHEN hour = 21 THEN 1 END) AS "21",
    COUNT(CASE WHEN hour = 22 THEN 1 END) AS "22",
    COUNT(CASE WHEN hour = 23 THEN 1 END) AS "23"
FROM OrderDayHour
GROUP BY day_of_week_name, day_of_week_int
ORDER BY day_of_week_int;

---5. Top 10 Cities with the Most Orders
SELECT c.customer_city  as "City name", 
	count(o.order_id) as "Total order" 
from customers c 
left join orders o on c.customer_id = o.customer_id 
group by c.customer_city 
order by "Total order" DESC
LIMIT 10;

---6. Product price statistic 
select 
min(oi.price) as "Min product price",
ROUND(AVG(oi.price),2) as "Average product price",
max(oi.price) as "Max product price"
from order_items oi 
join products p on p.product_id = oi.product_id;

---7. Total order price statistic 
SELECT
    MIN(order_price) AS "Min order price",
    ROUND(AVG(order_price), 2) AS "Average order price",
    MAX(order_price) AS "Max order price"
FROM (
    SELECT
        orders.order_id,
        SUM(order_items.price + order_items.freight_value) AS order_price
    FROM orders
        JOIN order_items USING (order_id)
    GROUP BY orders.order_id
)

---8. Total order price
SELECT o.order_id, SUM(oi.price) AS total_order_price
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.order_id;

---9. Total product price
SELECT o.order_id, oi.price, pc.product_category_name_english
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
join product_category_name_translation pc on p.product_category_name = pc.product_category_name;

---10. Top 10 Products by Revenue
select pcnt.product_category_name_english as "Product name",
round(sum(oi.price)) as "Total order price",
count(oi.product_id) as "Number of product"
from order_items oi 
join products p on p.product_id =oi.product_id 
join product_category_name_translation pcnt on pcnt.product_category_name = p.product_category_name 
join orders o on o.order_id =oi.order_id 
WHERE o.order_status ='delivered'
group by "Product name"
order by "Total order price" DESC
limit 10;

---11. Reiew score distribution
SELECT or2.review_score,
COUNT(or2.review_score) as "Number of score" 
from order_reviews or2 
group by or2.review_score;

---12. Review comment
SELECT r.review_comment_message AS review_text
FROM order_reviews r
WHERE r.review_score IN (1, 2) AND r.review_comment_message IS NOT NULL;

---13. Review score and delay time for negative review
SELECT 
    o.order_id,
    r.review_score,
    julianday(o.order_delivered_customer_date) - julianday(oi.shipping_limit_date) AS delay_days
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_delivered_customer_date IS NOT NULL 
AND oi.shipping_limit_date IS NOT NULL
AND r.review_score IN (1, 2, 3);

---14. Order time
SELECT c.customer_city  as "City", 
	count(o.order_id) as "Total order",
	AVG(JULIANDAY(order_approved_at) - JULIANDAY(order_purchase_timestamp)) AS approved,
    AVG(JULIANDAY(order_delivered_carrier_date) - JULIANDAY(order_approved_at)) AS delivered_to_carrier,
    AVG(JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_delivered_carrier_date)) AS delivered_to_customer,
    AVG(JULIANDAY(order_estimated_delivery_date) - JULIANDAY(order_delivered_customer_date)) AS estimated_delivery 
from customers c 
left join orders o on c.customer_id = o.customer_id 
group by c.customer_city 
order by "Total order" DESC
LIMIT 10;

---15. Calculate RFM socre
--1. Calculate RFM scores
WITH RecencyScore AS (
    SELECT customer_unique_id,
           MAX(order_purchase_timestamp) AS last_purchase,
           NTILE(5) OVER (ORDER BY MAX(order_purchase_timestamp) DESC) AS recency
    FROM orders
        JOIN customers USING (customer_id)
    WHERE order_status = 'delivered'
    GROUP BY customer_unique_id
),
FrequencyScore AS (
    SELECT customer_unique_id,
           COUNT(order_id) AS total_orders,
           NTILE(5) OVER (ORDER BY COUNT(order_id) DESC) AS frequency
    FROM orders
        JOIN customers USING (customer_id)
    WHERE order_status = 'delivered'
    GROUP BY customer_unique_id
),
MonetaryScore AS (
    SELECT customer_unique_id,
           SUM(price) AS total_spent,
           NTILE(5) OVER (ORDER BY SUM(price) DESC) AS monetary
    FROM orders
        JOIN order_items USING (order_id)
        JOIN customers USING (customer_id)
    WHERE order_status = 'delivered'
    GROUP BY customer_unique_id
),
-- 2. Assign each customer to a group
RFM AS (
    SELECT last_purchase, total_orders, total_spent,
        CASE
            WHEN recency = 1 AND frequency + monetary IN (1, 2, 3, 4) THEN "Champions"
            WHEN recency IN (4, 5) AND frequency + monetary IN (1, 2) THEN "Can't Lose Them"
            WHEN recency IN (4, 5) AND frequency + monetary IN (3, 4, 5, 6) THEN "Hibernating"
            WHEN recency IN (4, 5) AND frequency + monetary IN (7, 8, 9, 10) THEN "Lost"
            WHEN recency IN (2, 3) AND frequency + monetary IN (1, 2, 3, 4) THEN "Loyal Customers"
            WHEN recency = 3 AND frequency + monetary IN (5, 6) THEN "Needs Attention"
            WHEN recency = 1 AND frequency + monetary IN (7, 8) THEN "Recent Users"
            WHEN recency = 1 AND frequency + monetary IN (5, 6) OR
                recency = 2 AND frequency + monetary IN (5, 6, 7, 8) THEN "Potentital Loyalists"
            WHEN recency = 1 AND frequency + monetary IN (9, 10) THEN "Price Sensitive"
            WHEN recency = 2 AND frequency + monetary IN (9, 10) THEN "Promising"
            WHEN recency = 3 AND frequency + monetary IN (7, 8, 9, 10) THEN "About to Sleep"
        END AS RFM_Bucket
    FROM RecencyScore
        JOIN FrequencyScore USING (customer_unique_id)
        JOIN MonetaryScore USING (customer_unique_id)
)
-- 3. Calculate group statistics for plotting
SELECT RFM_Bucket, 
       AVG(JULIANDAY('now') - JULIANDAY(last_purchase)) AS avg_days_since_purchase, 
       AVG(total_spent / total_orders) AS avg_sales_per_customer,
       COUNT(*) AS customer_count
FROM RFM
GROUP BY RFM_Bucket; 

---16. Seller's review score and sales
SELECT 
    sellers.seller_id,
    AVG(order_reviews.review_score) AS avg_review_score,
    SUM(order_items.price) AS total_sales,
    COUNT(orders.order_id) AS num_orders
FROM 
    sellers
    LEFT JOIN order_items ON sellers.seller_id = order_items.seller_id
    LEFT JOIN orders ON order_items.order_id = orders.order_id
    LEFT JOIN order_reviews ON orders.order_id = order_reviews.order_id
GROUP BY sellers.seller_id
having num_orders > 10
order by total_sales DESC;

---17. Seller distribution
select s.seller_id ,
count(s.seller_id) as number_of_order,
avg(oi.price) as avg_price
from sellers s 
left join order_items oi on oi.seller_id = s.seller_id 
group by s.seller_id
order by number_of_order desc;

---18. Total revenue of each seller's group
select s.seller_id ,
count(s.seller_id) as number_of_order,
sum(oi.price) as sum_price
from sellers s 
left join order_items oi on oi.seller_id = s.seller_id 
group by s.seller_id;










