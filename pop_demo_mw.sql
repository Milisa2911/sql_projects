-- Quick check of the table structure, and initial records to ensure data loading was successful.
SELECT 
    *
FROM
    newschema.pop_demo;


-- Standardizing column names to improve readability and usability
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Country name` country_name VARCHAR(100);
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Year` population_year INT4;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population of children under the age of 1` population_children_under_1 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population of children under the age of 5` population_children_under_5 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population of children under the age of 15` population_children_under_15 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population under the age of 25` population_under_25 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population aged 15 to 64 years` population_15_to_64 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population older than 15 years` population_older_15 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population older than 18 years` population_older_18 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population at age 1` population_at_1 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population aged 1 to 4 years` population_1_to_4 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population aged 5 to 9 years` population_5_to_9 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population aged 10 to 14 years` population_10_to_14 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population aged 15 to 19 years` population_15_to_19 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population aged 20 to 29 years` population_20_to_29 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population aged 30 to 39 years` population_30_to_39 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population aged 40 to 49 years` population_40_to_49 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population aged 50 to 59 years` population_50_to_59 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population aged 60 to 69 years` population_60_to_69 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population aged 70 to 79 years` population_70_to_79 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population aged 80 to 89 years` population_80_to_89 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population aged 90 to 99 years` population_90_to_99 int8;
ALTER TABLE newschema.pop_demo CHANGE COLUMN `Population older than 100 years` population_100_above int8;


-- Verifing that all countries and regions have the same number of records
SELECT 
    country_name, COUNT(*) AS num_rows
FROM
    newschema.pop_demo
GROUP BY country_name;

SELECT 
    country_name, COUNT(*) AS num_rows
FROM
    newschema.pop_demo
WHERE
    country_name LIKE '%(UN)%'
GROUP BY country_name;


-- Add a new classification column
ALTER TABLE  newschema.pop_demo
ADD COLUMN record_type VARCHAR(100);


-- Assign the 'Continent' label to all records containing '(UN)'
UPDATE newschema.pop_demo 
SET 
    record_type = 'Continent'
WHERE
    country_name LIKE '%(UN)%';


-- Assign the 'Country' label to all remaining records 
UPDATE newschema.pop_demo 
SET 
    record_type = 'Country'
WHERE
    record_type IS NULL;
    
    
-- Assign the 'Category' label to records representing economic groups or special groupings
UPDATE newschema.pop_demo
SET record_type = 'Category'
WHERE country_name IN (
'High-income countries',
'Land-locked developing countries (LLDC)',
'Least developed countries',
'Less developed regions',
'Less developed regions, excluding China',
'Less developed regions, excluding least developed countries',
'Low-income countries',
'Lower-middle-income countries',
'More developed regions',
'Small island developing states (SIDS)',
'Upper-middle-income countries',
'World'
);


-- Q1 What is the population of people aged 90 and above for each country in the latest year
SELECT 
    country_name,
    (population_90_to_99 + population_100_above) AS pop_90_plus
FROM
    newschema.pop_demo
WHERE
    population_year = 2021
        AND record_type = 'Country'
ORDER BY pop_90_plus desc;


-- Q2 Which countries have the highest population growth in the last year. See population and percentage change
SELECT 
    country_name,
    population_2020,
    population_2021,
    population_2021 - population_2020 AS pop_growth_num,
    ROUND((population_2021 - population_2020) / population_2020 * 100,
            2) AS pop_growth_pct
FROM
    (SELECT 
        p.country_name,
            (SELECT 
                    p1.population
                FROM
                    newschema.pop_demo p1
                WHERE
                    p1.country_name = p.country_name
                        AND p1.population_year = 2020) AS population_2020,
            (SELECT 
                    p1.population
                FROM
                    newschema.pop_demo p1
                WHERE
                    p1.country_name = p.country_name
                        AND p1.population_year = 2021) AS population_2021
    FROM
        newschema.pop_demo p
    WHERE
        p.record_type = 'Country'
            AND p.population_year = 2021) s
ORDER BY pop_growth_pct DESC;


-- Q3 Which single country has the highest population decline in the past year
SELECT 
    country_name,
    population_2020,
    population_2021,
    population_2021 - population_2020 AS pop_growth_num,
    ROUND((population_2021 - population_2020) / population_2020 * 100,
            2) AS pop_growth_pct
FROM
    (SELECT 
        p.country_name,
            (SELECT 
                    p1.population
                FROM
                    newschema.pop_demo p1
                WHERE
                    p1.country_name = p.country_name
                        AND p1.population_year = 2020) AS population_2020,
            (SELECT 
                    p1.population
                FROM
                    newschema.pop_demo p1
                WHERE
                    p1.country_name = p.country_name
                        AND p1.population_year = 2021) AS population_2021
    FROM
        newschema.pop_demo p
    WHERE
        p.record_type = 'Country'
            AND p.population_year = 2021) s
ORDER BY pop_growth_pct ASC
LIMIT 1;


-- Q4 Which age group had the highest population out of all countries in the past year
SELECT
  'population_1_to_9' AS age_group,
  (population_1_to_4 + population_5_to_9) AS population
FROM
  newschema.pop_demo
WHERE
  country_name = 'World' AND population_year = 2021
UNION ALL
SELECT
  'population_10_to_19' AS age_group,
  (population_10_to_14 + population_15_to_19) AS population
FROM
  newschema.pop_demo
WHERE
  country_name = 'World' AND population_year = 2021
UNION ALL
SELECT
  'population_20_to_29' AS age_group,
  population_20_to_29 AS population
FROM
  newschema.pop_demo
WHERE
  country_name = 'World' AND population_year = 2021
UNION ALL
SELECT
  'population_30_to_39' AS age_group,
  population_30_to_39 AS population
FROM
  newschema.pop_demo
WHERE
  country_name = 'World' AND population_year = 2021
UNION ALL
SELECT
  'population_40_to_49' AS age_group,
  population_40_to_49 AS population
FROM
  newschema.pop_demo
WHERE
  country_name = 'World' AND population_year = 2021
UNION ALL
SELECT
  'population_90_to_99' AS age_group,
  population_90_to_99 AS population
FROM
  newschema.pop_demo
WHERE
  country_name = 'World' AND population_year = 2021
ORDER BY
  population DESC;
  
  
-- Q5 What are the top 10 countries with the highest population growth in the last 10 years. Show number and percentage
SELECT 
    country_name,
    population_2011,
    population_2021,
    population_2021 - population_2011 AS pop_growth_num,
    ROUND((population_2021 - population_2011) / population_2011 * 100,
            2) AS pop_growth_pct
FROM
    (SELECT 
        p.country_name,
            (SELECT 
                    p1.population
                FROM
                    newschema.pop_demo p1
                WHERE
                    p1.country_name = p.country_name
                        AND p1.population_year = 2011) AS population_2011,
            (SELECT 
                    p1.population
                FROM
                    newschema.pop_demo p1
                WHERE
                    p1.country_name = p.country_name
                        AND p1.population_year = 2021) AS population_2021
    FROM
        newschema.pop_demo p
    WHERE
        p.record_type = 'Country'
            AND p.population_year = 2021) s
ORDER BY pop_growth_pct DESC
LIMIT 10;


-- Q6 Which country has the highest percentge growth since the first year recorded
SELECT 
    country_name,
    population_1950,
    population_2021,
    population_2021 - population_1950 AS pop_growth_num,
    ROUND((population_2021 - population_1950) / population_1950 * 100,
            2) AS pop_growth_pct
FROM
    (SELECT 
        p.country_name,
            (SELECT 
                    p1.population
                FROM
                    newschema.pop_demo p1
                WHERE
                    p1.country_name = p.country_name
                        AND p1.population_year = 1950) AS population_1950,
            (SELECT 
                    p1.population
                FROM
                    newschema.pop_demo p1
                WHERE
                    p1.country_name = p.country_name
                        AND p1.population_year = 2021) AS population_2021
    FROM
        newschema.pop_demo p
    WHERE
        p.record_type = 'Country'
            AND p.population_year = 2021) s
ORDER BY pop_growth_pct DESC
LIMIT 1;


-- Q7 Which country has the highest population aged 1 as a percentage of their overall population
SELECT 
    country_name,
    Population,
    population_at_1,
    ROUND((population_at_1 / population) * 100, 2) AS pop_pct
FROM
    newschema.pop_demo
WHERE
    record_type = 'Country'
        AND population_year = 2021
ORDER BY pop_pct DESC;


-- Q8 What is the population of each continent in each year, and how much has it changed in each year
select 
	country_name, 
	population_year, 
    population,
lag (population, 1) over (PARTITION BY country_name ORDER BY population_year asc) as prev_pop,
population - lag (population, 1) over (PARTITION BY country_name ORDER BY population_year asc) as population_change
from 
	newschema.pop_demo
where record_type = 'Continent'
order by country_name, population_year;


-- Q9 What is the yearly global population residing in each country. Show number and percentage
select
    country_name,
    population_year,
    population,
    round(population / sum(population) over (partition by population_year), 2) as pop_ratio,
    round((population / sum(population) over (partition by population_year)) * 100, 2) as pop_pct
from newschema.pop_demo
where record_type = 'Continent'
order by population_year, country_name;


-- Q10 What is the labour force ratio for each country over time
select country_name,
population_year,
round((population_15_to_64 / population) * 100,2) as labour_force_pct
from newschema.pop_demo
where record_type = 'Country';


-- Q11 What is the labour force ratio for each continent over time
select country_name,
population_year,
round((population_15_to_64 / population) * 100,2) as labour_force_pct
from newschema.pop_demo
where record_type = 'Continent';
