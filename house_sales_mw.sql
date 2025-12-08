
-- Looking at empty property address rows
SELECT 
    *
FROM
    housing.house_sales
WHERE
    propertyaddress = '';

-- Discovering variations in the land use field
SELECT DISTINCT
    landuse
FROM
    housing.house_sales
WHERE
    landuse LIKE '%land%';

-- Standardizing the land use field
UPDATE housing.house_sales 
SET 
    landuse = 'VACANT RESIDENTIAL LAND'
WHERE
    landuse = 'VACANT RES LAND';

UPDATE housing.house_sales 
SET 
    landuse = 'GREENBELT'
WHERE
    landuse LIKE '%greenbelt%';

-- Verifying the standardization
SELECT DISTINCT
    landuse
FROM
    housing.house_sales;

-- Standardizing the vacancy field
UPDATE housing.house_sales 
SET 
    soldasvacant = 'Yes'
WHERE
    soldasvacant = 'Y';

UPDATE housing.house_sales 
SET 
    soldasvacant = 'No'
WHERE
    soldasvacant = 'N';

-- Verifying the standardization
SELECT DISTINCT
    soldasvacant
FROM
    housing.house_sales;

-- Adding a city column to store the extracted city name
alter table housing.house_sales
add column city varchar(255);

-- Populating the city column
UPDATE housing.house_sales 
SET 
    city = SUBSTRING_INDEX(propertyaddress, ', ', - 1);

-- Viewing the city field
SELECT DISTINCT
    city
FROM
    housing.house_sales;

-- Making a new column for the year
alter table housing.house_sales
add column SaleYear year;

-- Populating the year column
UPDATE housing.house_sales 
SET 
    saleyear = YEAR(STR_TO_DATE(saledate, '%M %D %Y'));

-- Creating a temporary table with the clean data
create temporary table housing.house_sales_clean
select * from housing.house_sales
where propertyaddress != ''
and ownername != ''
and city != '';

-- Viewing the temporary table
SELECT 
    *
FROM
    housing.house_sales_clean;

-- Q1: What is the average sale price for each city?
SELECT 
    city, ROUND(AVG(saleprice), 2) AS avg_sale_price
FROM
    housing.house_sales_clean
GROUP BY city
ORDER BY avg_sale_price DESC;

-- Q2: How many property sales in each city?
SELECT 
    city, COUNT(*) AS sales
FROM
    housing.house_sales_clean
GROUP BY city
ORDER BY sales DESC;

-- Q3: What are the minimum and maximum sale price for each city?
select city, min(saleprice) as min_sale_price, max(saleprice) as max_sale_price
from housing.house_sales_clean
group by city
order by min_sale_price, max_sale_price;

-- Q4: What are the minimum and maximum total values for each city?
SELECT 
    city,
    MIN(totalvalue) AS min_total_value,
    MAX(totalvalue) AS max_total_value
FROM
    housing.house_sales_clean
GROUP BY city
ORDER BY min_total_value , max_total_value;

-- Q5: What is the property sale price overtime? What is the average sale price for each year and month?
SELECT 
    city,
    YEAR(STR_TO_DATE(saledate, '%M %D %Y')) AS sale_year,
    MONTHNAME(STR_TO_DATE(saledate, '%M %D %Y')) AS sale_month,
    ROUND(AVG(saleprice), 2) AS avg_sale_price
FROM
    housing.house_sales_clean
GROUP BY city , sale_year , sale_month
ORDER BY avg_sale_price DESC;

-- Q6: What are the top 5 selling months?
SELECT 
    MONTHNAME(STR_TO_DATE(saledate, '%M %D %Y')) AS sale_month,
    COUNT(*) AS num_sales
FROM
    housing.house_sales_clean
GROUP BY sale_month
ORDER BY num_sales DESC
LIMIT 5;

-- Q7: Which are the best selling years?
SELECT 
    YEAR(STR_TO_DATE(saledate, '%M %D %Y')) AS sale_year,
    COUNT(*) AS num_sales
FROM
    housing.house_sales_clean
GROUP BY sale_year
ORDER BY num_sales DESC;

-- Q8: How does the acreage affect the average price and value?
SELECT 
    CASE
        WHEN acreage BETWEEN 0.04 AND 4.79 THEN '0.04 to 4.79'
        WHEN acreage BETWEEN 4.80 AND 9.53 THEN '4.80 to 9.53'
        WHEN acreage BETWEEN 9.54 AND 14.28 THEN '9.54 to 14.28'
        WHEN acreage BETWEEN 14.29 AND 19.02 THEN '14.29 to 19.02'
        WHEN acreage BETWEEN 19.03 AND 23.77 THEN '19.03 to 23.77'
        WHEN acreage BETWEEN 23.78 AND 28.52 THEN '23.78 to 28.52'
        WHEN acreage BETWEEN 28.53 AND 33.26 THEN '28.53 to 33.26'
        WHEN acreage BETWEEN 33.27 AND 38.01 THEN '33.27 to 38.01'
        WHEN acreage BETWEEN 38.02 AND 42.75 THEN '38.02 to 42.75'
        WHEN acreage BETWEEN 42.76 AND 47.50 THEN '42.76 to 47.50'
    END AS acreage_buckets,
    ROUND(AVG(saleprice), 2) AS avg_sale_price,
    ROUND(AVG(totalvalue), 2) AS avg_total_value,
    COUNT(*) AS records_in_bucket
FROM
    housing.house_sales_clean
GROUP BY acreage_buckets
ORDER BY records_in_bucket DESC;

-- Q9: How does the year the house was built affect the average price and value? What is the % difference in average total value and average sale value?
SELECT 
    CASE
        WHEN yearbuilt BETWEEN 1799 AND 1820 THEN '1799 to 1820'
        WHEN yearbuilt BETWEEN 1821 AND 1842 THEN '1821 to 1842'
        WHEN yearbuilt BETWEEN 1843 AND 1864 THEN '1843 to 1864'
        WHEN yearbuilt BETWEEN 1865 AND 1886 THEN '1865 to 1886'
        WHEN yearbuilt BETWEEN 1887 AND 1908 THEN '1887 to 1908'
        WHEN yearbuilt BETWEEN 1909 AND 1930 THEN '1909 to 1930'
        WHEN yearbuilt BETWEEN 1931 AND 1952 THEN '1931 to 1952'
        WHEN yearbuilt BETWEEN 1953 AND 1974 THEN '1953 to 1974'
        WHEN yearbuilt BETWEEN 1975 AND 1996 THEN '1975 to 1996'
        WHEN yearbuilt BETWEEN 1997 AND 2017 THEN '1997 to 2017'
    END AS year_built_buckets,
    ROUND(AVG(saleprice), 2) AS avg_sale_price,
    ROUND(AVG(totalvalue), 2) AS avg_total_value,
    ROUND((AVG(saleprice) - AVG(totalvalue)) / AVG(totalvalue),
            2) * 100 AS diff_perc
FROM
    housing.house_sales_clean
GROUP BY year_built_buckets
ORDER BY year_built_buckets;

-- Q10: What are the top 5 oldest houses and what were their value and selling price?
SELECT 
    yearbuilt,
    saleyear,
    saleyear - yearbuilt AS age,
    totalvalue,
    saleprice,
    saleprice - totalvalue AS value_price_diff
FROM
    housing.house_sales_clean
ORDER BY yearbuilt
LIMIT 5;

-- Q11: What are the top 5 youngest houses and what were their value and selling price?
SELECT 
    yearbuilt,
    saleyear,
    yearbuilt - saleyear AS age,
    totalvalue,
    saleprice,
    saleprice - totalvalue AS value_price_diff
FROM
    housing.house_sales_clean
ORDER BY yearbuilt DESC
LIMIT 5;

-- Q12: Are there houses sold more than once and what is the details of the sales?
select
legalreference,
saleprice,
house_sales
from
(select
legalreference,
saleprice,
count(*) over (partition by legalreference) as house_sales
from housing.house_sales_clean) x
where house_sales > 1
group by legalreference, house_sales, saleprice
order by house_sales desc;

-- Q13: How does the average sale price differ by land use type?
SELECT 
    landuse, ROUND(AVG(saleprice), 2) AS avg_price
FROM
    housing.house_sales_clean
GROUP BY landuse
ORDER BY avg_price DESC;

-- Q14: How does the number of Bedrooms and Bathrooms affect the average sale price?
SELECT 
    bedrooms,
    fullbath,
    halfbath,
    ROUND(AVG(saleprice), 2) AS avg_price,
    COUNT(*) AS sales
FROM
    housing.house_sales_clean
GROUP BY bedrooms , fullbath , halfbath
ORDER BY sales DESC;

-- Q15: What is the average value and price for each tax district?
SELECT 
    taxdistrict,
    ROUND(AVG(totalvalue), 2) AS avg_value,
    ROUND(AVG(saleprice), 2) AS avg_price
FROM
    housing.house_sales_clean
GROUP BY taxdistrict
ORDER BY avg_value , avg_price DESC;

-- Q16: How does the vacancy of the property affect its value and price?
SELECT 
    soldasvacant,
    ROUND(AVG(totalvalue), 2) AS avg_value,
    ROUND(AVG(saleprice), 2) AS avg_price
FROM
    housing.house_sales_clean
GROUP BY soldasvacant;

-- Q17: Which city has the most vacant property and what is the value?
SELECT 
    city,
    COUNT(soldasvacant) AS num_vacant,
    ROUND(AVG(totalvalue), 2) AS avg_value
FROM
    housing.house_sales_clean
WHERE
    soldasvacant = 'Yes'
GROUP BY city
ORDER BY num_vacant DESC;

-- Q18: Which tax district has the most vacant property and what is the value?
SELECT 
    taxdistrict,
    COUNT(soldasvacant) AS num_vacant,
    ROUND(AVG(totalvalue), 2) AS avg_value
FROM
    housing.house_sales_clean
WHERE
    soldasvacant = 'Yes'
GROUP BY taxdistrict
ORDER BY num_vacant DESC;

-- Q19: Which land use has the most vacant property and what is the value?
SELECT 
    landuse,
    COUNT(soldasvacant) AS num_vacant,
    ROUND(AVG(totalvalue), 2) AS avg_value
FROM
    housing.house_sales_clean
WHERE
    soldasvacant = 'Yes'
GROUP BY landuse
ORDER BY num_vacant DESC;

-- Q20: Which year has the most vacant property and what is the value?
SELECT 
    saleyear,
    COUNT(soldasvacant) AS num_vacant,
    ROUND(AVG(totalvalue), 2) AS avg_value
FROM
    housing.house_sales_clean
WHERE
    soldasvacant = 'Yes'
GROUP BY saleyear
ORDER BY num_vacant DESC;

-- Q21: What are the oldest and youngest houses for each district?
SELECT 
    taxdistrict,
    MIN(yearbuilt) AS oldest,
    MAX(yearbuilt) AS youngest
FROM
    housing.house_sales_clean
GROUP BY taxdistrict
ORDER BY oldest , youngest;

-- Q22: What are the oldest and youngest houses for each city?
SELECT 
    city, MIN(yearbuilt) AS oldest, MAX(yearbuilt) AS youngest
FROM
    housing.house_sales_clean
GROUP BY city
ORDER BY oldest , youngest;