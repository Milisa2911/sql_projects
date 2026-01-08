-- Standardizing the data
alter table coffee_shop.sales change column `Month Name` month_name varchar(100);
alter table coffee_shop.sales change column `Day Name` day_name varchar(100);
alter table coffee_shop.sales change column `Hour` trans_hour int(4);

-- Dropping duplicate columns
alter table coffee_shop.sales drop column `Month`;
alter table coffee_shop.sales drop column `Day of Week`;

-- Reviewing the changes
select * from coffee_shop.sales;

-- Q1: What is the total revenue per month?
SELECT 
    SUM(total_bill) AS total_revenue, month_name
FROM
    coffee_shop.sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- Q2: Which store generates the highest revenue?
SELECT 
    SUM(total_bill) AS total_revenue, store_location
FROM
    coffee_shop.sales
GROUP BY store_location
ORDER BY total_revenue DESC;

-- Q3: What is the average transaction value per product category?
SELECT 
    product_category, ROUND(AVG(total_bill), 2) AS avg_trans_val
FROM
    coffee_shop.sales
GROUP BY product_category
ORDER BY avg_trans_val DESC;

-- Q4: What are the top 5 best-selling products by quantity?
SELECT 
    product_type, COUNT(transaction_id) AS quantity
FROM
    coffee_shop.sales
GROUP BY product_type
ORDER BY quantity DESC
LIMIT 5;

-- Q5: Which product category contributes most to the total revenue?
select product_category,
sum(total_bill) as total_revenue,
round((SUM(total_bill) / SUM(SUM(total_bill)) OVER()) * 100,2) AS revenue_pct
from coffee_shop.sales
group by product_category
order by revenue_pct desc;

-- Q6: What is the most bought product size?
SELECT 
    size, COUNT(transaction_id) AS num_orders
FROM
    coffee_shop.sales
GROUP BY size
ORDER BY num_orders DESC;

-- Q7: What are the peak hours for transactions across all stores?
SELECT 
    CASE
        WHEN trans_hour BETWEEN 6 AND 8 THEN '6 to 8'
        WHEN trans_hour BETWEEN 9 AND 12 THEN '9 to 12'
        WHEN trans_hour BETWEEN 13 AND 16 THEN '13 to 16'
        WHEN trans_hour BETWEEN 17 AND 20 THEN '17 to 20'
    END AS time_buckets,
    COUNT(transaction_id) AS num_orders
FROM
    coffee_shop.sales
GROUP BY time_buckets
ORDER BY time_buckets;

-- Q8: How do sales vary by the Day of the Week?
SELECT 
    day_name, COUNT(transaction_id) AS num_orders
FROM
    coffee_shop.sales
GROUP BY day_name
ORDER BY num_orders DESC;

-- Q9: Is there a specific time of day when a certain product type sells more?
SELECT 
    product_category,
    trans_hour,
    COUNT(transaction_id) AS num_orders
FROM
    coffee_shop.sales
GROUP BY product_category , trans_hour;

-- Q10: Which products have the highest unit price but low transaction quantity?
SELECT 
    product_category,
    product_type,
    product_detail,
    unit_price,
    COUNT(transaction_id) AS num_orders
FROM
    coffee_shop.sales
WHERE
    unit_price > 8
GROUP BY product_category , product_type , product_detail , unit_price
ORDER BY unit_price DESC;

-- Q11: Are there stores that perform better on specific days?
SELECT 
    store_location,
    day_name,
    COUNT(transaction_id) AS num_orders
FROM
    coffee_shop.sales
GROUP BY store_location , day_name
ORDER BY num_orders DESC;

-- Q12: What is the average transaction quatity for each product?
select
product_category,
avg(transaction_qty) as avg_tran_qty
from coffee_shop.sales
group by product_category;

-- Q13: Which size is the most profitable across all categories?
SELECT 
    product_category, size, SUM(total_bill) AS total_revenue, COUNT(transaction_id) AS num_orders
FROM
    coffee_shop.sales
WHERE
    size != 'Not Defined'
GROUP BY product_category , size
ORDER BY total_revenue DESC;