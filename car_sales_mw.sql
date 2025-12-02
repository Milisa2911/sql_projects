-- Inspecting the raw data
SELECT 
    *
FROM
    car_sales.car_prices;

-- Identifying and inspecting records with missing or empty values
SELECT 
    *
FROM
    car_sales.car_prices
WHERE
    car_make = '';

-- Performing data cleaning by creating a temporary, clean version of the table
create TEMPORARY table car_sales.car_prices_clean as
SELECT *
from car_sales.car_prices
where car_make != '';

-- Verifying the success of the cleaning step by displaying the contents of the newly created table
SELECT 
    *
FROM
    car_sales.car_prices_clean;

-- Q1: How many sales have been make for each make and model?
SELECT 
    car_make, car_model, COUNT(*) AS sales
FROM
    car_sales.car_prices_clean
GROUP BY car_make , car_model
ORDER BY sales DESC;

-- Q2: What is the average sale price for each state?
SELECT 
    sale_state,
    ROUND(AVG(car_selling_price), 2) AS avg_sale_price
FROM
    car_sales.car_prices_clean
GROUP BY sale_state
ORDER BY avg_sale_price DESC;

-- Q3: How many car sales in each state?
SELECT 
    sale_state, COUNT(*) AS sales
FROM
    car_sales.car_prices
GROUP BY sale_state
ORDER BY sales DESC;

-- Q4: What is the sale price of cars over time? What is the average sale price of each car in each month and year?
SELECT 
    car_make,
    car_model,
    DATE_FORMAT(STR_TO_DATE(car_sale_date, '%a %b %d %Y %H:%i:%s'),
            '%M') AS sale_month,
    YEAR(STR_TO_DATE(car_sale_date, '%a %b %d %Y %H:%i:%s')) AS sale_year,
    ROUND(AVG(car_selling_price), 2) AS avg_sale_price
FROM
    car_sales.car_prices_clean
GROUP BY car_make , car_model , sale_month , sale_year
ORDER BY avg_sale_price DESC;

-- Q5: Which month has the most sales?
SELECT 
    DATE_FORMAT(STR_TO_DATE(car_sale_date, '%a %b %d %Y %H:%i:%s'),
            '%M') AS sale_month,
    COUNT(*) AS sales
FROM
    car_sales.car_prices_clean
GROUP BY sale_month
ORDER BY sales DESC;

-- Q6: What are the top 5 most selling body types
SELECT 
    car_body, COUNT(*) AS sales
FROM
    car_sales.car_prices_clean
GROUP BY car_body
ORDER BY sales DESC
LIMIT 5;

-- Q6: Find the sales where the sales price is higher than the average sales price and by how much
select 
model_year, 
car_make, 
car_model, 
car_selling_price, 
model_avg, 
car_selling_price / model_avg as price_ratio 
from 
	(select 
	model_year, 
	car_make, 
	car_model, 
	car_selling_price, 
	avg(car_selling_price) over (partition by car_make, car_model) as model_avg
	from car_sales.car_prices_clean) s
where car_selling_price > model_avg
order by price_ratio desc;

-- Q7: How does the car condition affect the selling price?
SELECT 
    CASE
        WHEN car_condition BETWEEN 0 AND 9 THEN '0 to 9'
        WHEN car_condition BETWEEN 10 AND 19 THEN '10 to 19'
        WHEN car_condition BETWEEN 20 AND 29 THEN '20 to 29'
        WHEN car_condition BETWEEN 30 AND 39 THEN '30 to 39'
        WHEN car_condition BETWEEN 40 AND 49 THEN '40 to 49'
    END AS car_condition_bucket,
    COUNT(*) sales,
    AVG(car_selling_price) AS avg_selling_price
FROM
    car_sales.car_prices_clean
GROUP BY car_condition_bucket
ORDER BY car_condition_bucket;

-- Q8: How does the odometer affect the selling price?
SELECT 
    CASE
        WHEN car_odometer BETWEEN 0 AND 99999 THEN '0 to 99999'
        WHEN car_odometer BETWEEN 100000 AND 199999 THEN '100000 to 199999'
        WHEN car_odometer BETWEEN 200000 AND 299999 THEN '200000 to 299999'
        WHEN car_odometer BETWEEN 300000 AND 399999 THEN '300000 to 399999'
        WHEN car_odometer BETWEEN 400000 AND 499999 THEN '400000 to 499999'
        WHEN car_odometer BETWEEN 500000 AND 599999 THEN '500000 to 599999'
        WHEN car_odometer BETWEEN 600000 AND 699999 THEN '600000 to 699999'
        WHEN car_odometer BETWEEN 700000 AND 799999 THEN '700000 to 799999'
        WHEN car_odometer BETWEEN 800000 AND 899999 THEN '800000 to 899999'
        WHEN car_odometer BETWEEN 900000 AND 999999 THEN '900000 to 999999'
    END AS car_odometer_bucket,
    COUNT(*) sales,
    AVG(car_selling_price) AS avg_selling_price
FROM
    car_sales.car_prices_clean
GROUP BY car_odometer_bucket
ORDER BY car_odometer_bucket;

-- Q9: What is the number of unique models sold and min and max prices?
SELECT 
    car_make,
    COUNT(DISTINCT car_model) AS model_sales,
    COUNT(*) AS sales,
    MIN(car_selling_price) AS min_price,
    MAX(car_selling_price) AS max_price
FROM
    car_sales.car_prices_clean
GROUP BY car_make
ORDER BY sales DESC;

-- Q10: Which car make had the highest average selling price?
SELECT 
    car_make,
    ROUND(AVG(car_selling_price), 2) AS avg_selling_price
FROM
    car_sales.car_prices_clean
GROUP BY car_make
ORDER BY avg_selling_price DESC;

-- Q11: Are there cars sold more than once and what is the details of the sales?
select 
car_make,
car_model,
car_vin,
car_selling_price,
car_odometer,
car_condition,
vin_sales
from (select 
car_make,
car_model,
car_vin,
car_selling_price,
car_odometer,
car_condition,
count(*) over (PARTITION BY car_vin) as vin_sales
from car_sales.car_prices_clean) s
where vin_sales > 1;

-- Q12: What is the sales volume for different price ranges and their average selling price?
SELECT 
    CASE
        WHEN car_selling_price BETWEEN 1 AND 31200 THEN 'R1 to R31,200'
        WHEN car_selling_price BETWEEN 31201 AND 62400 THEN 'R31,201 to R62,400'
        WHEN car_selling_price BETWEEN 62401 AND 93600 THEN 'R62,401 to R93,600'
        WHEN car_selling_price BETWEEN 93601 AND 124800 THEN 'R93,601 to R124,800'
        WHEN car_selling_price BETWEEN 124801 AND 156000 THEN 'R124,801 to R156,000'
    END AS price_buckets,
    COUNT(*) AS sales,
    ROUND(AVG(car_selling_price), 2) AS avg_selling_price
FROM
    car_sales.car_prices_clean
GROUP BY price_buckets;

-- Q13: How does the car's age affect its selling price?
SELECT 
    COUNT(*) AS sales,
    ROUND(AVG(car_selling_price), 2) AS avg_selling_price,
    CASE
        WHEN car_age < 0 THEN 0
        ELSE car_age
    END AS car_age_yrs
FROM
    (SELECT 
        car_selling_price,
            YEAR(STR_TO_DATE(car_sale_date, '%a %b %d %Y %H:%i:%s')) - model_year AS car_age
    FROM
        car_sales.car_prices_clean) s
GROUP BY car_age_yrs;

-- Q13: Top 3 manufacturers for each state?
select
    sale_state,
    car_make,
    sales
from (
    select
        sale_state,
        car_make,
        count(*) as sales,
        row_number() over (
            partition by sale_state
            order by count(*) desc
        ) as rn
    from car_sales.car_prices_clean
    group by sale_state, car_make
) x
where rn <= 3;

-- Q14 What is the average condition score for cars in different odometer buckets?
SELECT 
    CASE
        WHEN car_odometer BETWEEN 0 AND 99999 THEN '0 to 99999'
        WHEN car_odometer BETWEEN 100000 AND 199999 THEN '100000 to 199999'
        WHEN car_odometer BETWEEN 200000 AND 299999 THEN '200000 to 299999'
        WHEN car_odometer BETWEEN 300000 AND 399999 THEN '300000 to 399999'
        WHEN car_odometer BETWEEN 400000 AND 499999 THEN '400000 to 499999'
        WHEN car_odometer BETWEEN 500000 AND 599999 THEN '500000 to 599999'
        WHEN car_odometer BETWEEN 600000 AND 699999 THEN '600000 to 699999'
        WHEN car_odometer BETWEEN 700000 AND 799999 THEN '700000 to 799999'
        WHEN car_odometer BETWEEN 800000 AND 899999 THEN '800000 to 899999'
        WHEN car_odometer BETWEEN 900000 AND 999999 THEN '900000 to 999999'
    END AS car_odometer_bucket,
    AVG(car_condition) AS avg_condition
FROM
    car_sales.car_prices_clean
GROUP BY car_odometer_bucket;

-- Q15: What are the top 5 most popular exterior and interior color combinations?
SELECT 
    car_color,
    car_interior,
    CONCAT(car_color,
            ' exterior with ',
            car_interior,
            ' interior') AS color_combination,
    sales
FROM
    (SELECT 
        car_color, car_interior, COUNT(*) AS sales
    FROM
        car_sales.car_prices_clean
    GROUP BY car_color , car_interior) x
ORDER BY sales DESC;
