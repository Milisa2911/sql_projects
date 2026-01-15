-- Q1: What is the average charges for smokers and non-smokers across different age groups?
SELECT 
    CASE
        WHEN age BETWEEN 18 AND 28 THEN '18 to 28'
        WHEN age BETWEEN 29 AND 39 THEN '29 to 39'
        WHEN age BETWEEN 40 AND 50 THEN '40 to 50'
        WHEN age BETWEEN 51 AND 64 THEN '51+'
    END AS age_groups,
    smoker,
    ROUND(AVG(charges), 2) AS avg_charges
FROM
    medical.charges
GROUP BY age_groups , smoker
ORDER BY age_groups;

-- Q2: What is the "Smoking Premium" across different age groups?
SELECT 
    FLOOR(age / 10) * 10 AS age_decade,
    ROUND(AVG(CASE
                WHEN smoker = 'yes' THEN charges
            END),
            2) AS avg_smoker_charge,
    ROUND(AVG(CASE
                WHEN smoker = 'no' THEN charges
            END),
            2) AS avg_non_smoker_charge,
    ROUND(AVG(CASE
                WHEN smoker = 'yes' THEN charges
            END) - AVG(CASE
                WHEN smoker = 'no' THEN charges
            END),
            2) AS smoking_premium
FROM
    medical.charges
GROUP BY age_decade
ORDER BY age_decade;

-- Q3: Identify the average charge for individuals who are both smokers and have a BMI over 30
SELECT 
    ROUND(AVG(charges), 2) AS avg_charges
FROM
    medical.charges
WHERE
    smoker = 'Yes' AND bmi > 30;

-- Q3: How do charges scale with BMI tiers?
SELECT 
    CASE
        WHEN bmi < 18.5 THEN 'Underweight'
        WHEN bmi >= 18.5 AND bmi < 25 THEN 'Normal'
        WHEN bmi >= 25 AND bmi < 30 THEN 'Overweight'
        WHEN bmi >= 30 THEN 'Obese'
    END AS bmi_tiers,
    ROUND(AVG(charges), 2) AS avg_charges
FROM
    medical.charges
GROUP BY bmi_tiers;

-- Q4: Is there a "BMI Threshold"?????
WITH AvgTotal AS (SELECT AVG(charges) as global_avg FROM medical.charges)
SELECT 
    ROUND(bmi, 0) as rounded_bmi,
    ROUND(AVG(charges), 2) as avg_charge_at_bmi,
    (SELECT ROUND(global_avg, 2) FROM AvgTotal) as dataset_average
FROM medical.charges
GROUP BY rounded_bmi
HAVING AVG(charges) > (SELECT global_avg FROM AvgTotal)
ORDER BY rounded_bmi ASC
LIMIT 1;

-- Q5: Does the number of children correlate with higher charges for the parent?
SELECT 
    CASE
        WHEN children < 3 THEN 'Less than 3'
        WHEN children >= 3 THEN '3+'
    END AS age_range,
    ROUND(AVG(charges), 2) AS avg_charges,
    COUNT(*) AS policy_holders,
    ROUND(AVG(bmi), 2) AS avg_bmi
FROM
    medical.charges
GROUP BY age_range;

-- Q6: What is the average BMI and percentage of smokers per region, and how does that affect the region's total medical expenditure????
SELECT 
    region,
    COUNT(*) AS total_pop,
    ROUND(SUM(CASE
                WHEN smoker = 'yes' THEN 1
                ELSE 0
            END) * 100 / COUNT(*),
            2) AS smoking_rate_percentage,
    ROUND(AVG(charges), 2) AS avg_regional_charge
FROM
    medical.charges
GROUP BY region
ORDER BY avg_regional_charge DESC;

-- Q7: What is the total and average expenditure?
SELECT 
    COUNT(*) AS policy_holders,
    ROUND(SUM(charges), 2) AS total_expenditure,
    ROUND(AVG(charges), 2) AS avg_expenditure,
    ROUND(MIN(charges), 2) AS min_expenditure,
    ROUND(MAX(charges), 2) AS max_expenditure
FROM
    medical.charges;

-- Q8: Which region generates the most revenue and which is the most expensive per person?
SELECT 
    region,
    COUNT(*) AS total_pop,
    ROUND(SUM(charges), 2) AS total_revenue,
    ROUND(MAX(charges), 2) AS max_expenditure
FROM
    medical.charges
GROUP BY region
ORDER BY max_expenditure DESC;

-- Q9: What is the financial impact of gender across different age brackets?
SELECT 
    CASE
        WHEN age BETWEEN 18 AND 28 THEN '18 to 28'
        WHEN age BETWEEN 29 AND 39 THEN '29 to 39'
        WHEN age BETWEEN 40 AND 50 THEN '40 to 50'
        WHEN age BETWEEN 51 AND 64 THEN '51+'
    END AS age_groups,
    COUNT(*) AS total_pop,
    sex,
    ROUND(AVG(charges), 2) AS avg_expenditure
FROM
    medical.charges
GROUP BY age_groups , sex
ORDER BY age_groups;

-- Q10: What is the average bmi and expenditure for each sex given the number of children they have?
SELECT 
    CASE
        WHEN children < 3 THEN 'Less than 3'
        WHEN children >= 3 THEN '3+'
    END AS num_children,
    sex,
    ROUND(AVG(bmi), 2) AS avg_bmi,
    ROUND(AVG(charges), 2) AS avg_expenditure
FROM
    medical.charges
GROUP BY num_children , sex
ORDER BY sex;

-- Q11: What are the smokers for each region and the average expenditure?
SELECT 
    region,
    COUNT(*) AS total_smokers,
    ROUND(AVG(charges), 2) AS avg_expenditure
FROM
    medical.charges
WHERE
    smoker = 'Yes'
GROUP BY region
ORDER BY avg_expenditure DESC;
