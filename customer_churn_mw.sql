-- Looking at the dataset
select * from customerchurn.business;

-- Q1: How are customers distributed across different countries, cities, and genders? What is the total number of customers in each distribution?
SELECT 
    country, city, gender, COUNT(*) AS dist_count
FROM
    customerchurn.business
GROUP BY country , city , gender
ORDER BY dist_count DESC;

-- Q2: What is the total number of customers in each customer segment and their contract type?
SELECT 
    customer_segment, contract_type, COUNT(*) AS segment_count
FROM
    customerchurn.business
GROUP BY customer_segment , contract_type
ORDER BY customer_segment, contract_type;

-- Q3: Which signup channel brings in the most customers, and which has the highest average tenure?
SELECT 
    signup_channel,
    COUNT(*) AS channel_count,
    ROUND(AVG(tenure_months), 2) AS avg_tenure
FROM
    customerchurn.business
GROUP BY signup_channel
ORDER BY channel_count DESC , avg_tenure DESC;

-- Q4: How does the age group affect the average total revenue? What are the number of customers for each age group?
SELECT 
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18 to 25'
        WHEN age BETWEEN 26 AND 34 THEN '26 to 34'
        WHEN age BETWEEN 35 AND 42 THEN '35 to 42'
        WHEN age BETWEEN 43 AND 50 THEN '43 to 50'
        WHEN age BETWEEN 51 AND 59 THEN '51 to 59'
        WHEN age >= 60 THEN '60+'
    END AS age_group,
    ROUND(AVG(total_revenue), 2) AS avg_revenue,
    COUNT(*) AS age_count
FROM
    customerchurn.business
GROUP BY age_group
ORDER BY age_group;

-- Q5: What is the average number of monthly logins and weekly active days for churned vs. non-churned customers?
SELECT 
    churn,
    ROUND(AVG(monthly_logins), 2) AS avg_monthly_logins,
    ROUND(AVG(weekly_active_days), 2) AS avg_weekly_active_days,
    ROUND(AVG(avg_session_time),2) AS avg_session_time
FROM
    customerchurn.business
GROUP BY churn;

-- Q6: Do customers who use more than 5 features have a lower churn rate compared to those who use fewer?
SELECT 
    CASE
        WHEN features_used >= 5 THEN 'More_features (>=5)'
        ELSE 'Less_features (<5)'
    END AS feature_usage,
    AVG(churn) * 100 AS churn_rate
FROM
    customerchurn.business
GROUP BY feature_usage;

-- Q7: List all customers who haven't logged in for more than 30 days and their monthly fee and potential login loss.
SELECT 
    customer_id, monthly_fee, last_login_days_ago,
    monthly_fee * last_login_days_ago as login_loss
FROM
    customerchurn.business
WHERE
    last_login_days_ago > 30
ORDER BY last_login_days_ago DESC;

-- Q8: Is there a correlation between usage growth rate and the nps score?
SELECT 
    CASE
        WHEN nps_score BETWEEN - 100 AND - 50 THEN '-100 and -50'
        WHEN nps_score BETWEEN - 51 AND 0 THEN '-51 to 0'
        WHEN nps_score BETWEEN 1 AND 50 THEN '1 to 50'
        WHEN nps_score BETWEEN 51 AND 100 THEN '51 to 100'
    END AS nps_score_buckets,
    ROUND(AVG(usage_growth_rate), 2) AS avg_growth_rate
FROM
    customerchurn.business
GROUP BY nps_score_buckets
ORDER BY nps_score_buckets;

-- Q9: Who are the top 10% of customers in terms of total revenue? What are their common characteristics?
with PercentRank as (
select *,
PERCENT_RANK () over (PARTITION BY customer_id order by total_revenue desc) as revenue_percent
from customerchurn.business)
select
customer_id,
customer_segment,
total_revenue,
city,
payment_method,
monthly_logins
from PercentRank
where revenue_percent <= 0.1;

-- Q10: How many customers have experienced payment failures, and is there a significant link between these failures and churn?
SELECT 
    payment_failures, ROUND(AVG(churn) * 100, 2) AS churn_rate
FROM
    customerchurn.business
GROUP BY payment_failures
ORDER BY payment_failures;

-- Q11: Did customers who experienced a price increase in the last 3 months show a higher churn rate than those who didn't?
SELECT 
    price_increase_last_3m,
    ROUND(AVG(churn) * 100, 2) AS churn_rate
FROM
    customerchurn.business
GROUP BY price_increase_last_3m;

-- Q12 Does applying a discount significantly increase the average tenure and features of a customer?
SELECT 
    discount_applied,
    ROUND(AVG(tenure_months), 2) AS avg_tenure_months,
    ROUND(AVG(features_used), 2) AS avg_features_used
FROM
    customerchurn.business
GROUP BY discount_applied;

-- Q13: What is the most common complaint type, and which one is most likely to lead to a churn event?
SELECT 
    complaint_type,
    COUNT(*) AS total_complaints,
    AVG(churn) * 100 AS churn_rate
FROM
    customerchurn.business
WHERE
    complaint_type IS NOT NULL
GROUP BY complaint_type
ORDER BY churn_rate DESC;

-- Q14: Does a higher avg resolution time or more escalations lead to a lower csat score?
SELECT 
    CASE
        WHEN avg_resolution_time < 12 THEN 'Fast (<12h)'
        WHEN avg_resolution_time BETWEEN 12 AND 24 THEN 'Normal (12-24h)'
        ELSE 'Slow (>24h)'
    END AS resolution_speed,
    ROUND(AVG(escalations), 2) AS avg_escalations,
    ROUND(AVG(csat_score), 2) AS avg_csat
FROM
    customerchurn.business
GROUP BY resolution_speed
ORDER BY resolution_speed;

-- Q15: Calculate the average csat score and nps score per customer segment.
SELECT 
    customer_segment,
    ROUND(AVG(csat_score), 2) AS avg_csat_score,
    ROUND(AVG(nps_score), 2) AS avg_nps_score
FROM
    customerchurn.business
GROUP BY customer_segment;

-- Q16: Identify customers who have submitted more than 3 support tickets and have a csat score below 3.0.
SELECT 
    customer_id, support_tickets, csat_score
FROM
    customerchurn.business
WHERE
    support_tickets > 3 AND csat_score < 3;

-- Q17: What is the overall churn rate of the business?
SELECT 
    ROUND(AVG(churn) * 100, 2) AS overall_churn_rate
FROM
    customerchurn.business;

-- Q18: Compare the churn rates between contract types.
SELECT 
    contract_type, ROUND(AVG(churn) * 100, 2) AS churn_rate
FROM
    customerchurn.business
GROUP BY contract_type;

-- Q19: Identify customers with churn = 0 but who have high payment failures, low csat score, and negative usage growth rate.
SELECT 
    customer_id, payment_failures, csat_score, usage_growth_rate
FROM
    customerchurn.business
WHERE
    payment_failures > 1 AND csat_score < 2
        AND usage_growth_rate < 0;

-- Q20: Compare the average email open rate and marketing click rate across different customer segments.
SELECT 
    customer_segment,
    ROUND(AVG(email_open_rate), 2) AS avg_email_open_rate,
    ROUND(AVG(marketing_click_rate), 2) AS avg_marketing_click_rate
FROM
    customerchurn.business
GROUP BY customer_segment;

-- Q21: Do customers with a high referral count have a higher tenure months on average?
SELECT 
    CASE
        WHEN referral_count BETWEEN 0 AND 2 THEN '0 to 2'
        WHEN referral_count BETWEEN 3 AND 5 THEN '3 to 5'
        WHEN referral_count BETWEEN 6 AND 7 THEN '6 to 7'
    END AS referral_count_buckets,
    ROUND(AVG(tenure_months), 2) AS avg_tenure_months,
    ROUND(AVG(churn) * 100, 2) AS churn_rate
FROM
    customerchurn.business
GROUP BY referral_count_buckets;

-- OR

SELECT 
    CASE
        WHEN referral_count > 0 THEN 'Has Referrals'
        ELSE 'No Referrals'
    END AS referral_status,
    AVG(tenure_months) AS avg_tenure,
    AVG(churn) * 100 AS churn_rate
FROM
    customerchurn.business
GROUP BY referral_status;

-- Q22: Does a survey response translate to higher marketing click rate?
SELECT 
    survey_response,
    ROUND(AVG(marketing_click_rate), 2) AS avg_marketing_click_rate
FROM
    customerchurn.business
GROUP BY survey_response;