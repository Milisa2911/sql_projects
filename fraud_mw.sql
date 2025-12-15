-- Viewing the data
SELECT 
    *
FROM
    fraud.transactions;

-- Changing a column's name
ALTER TABLE 
	fraud.transactions
CHANGE COLUMN `hour` transaction_hour int4;

-- Q1: Which country has the most fraud transactions?
SELECT 
    country, COUNT(*) AS num_fraud
FROM
    fraud.transactions
WHERE
    is_fraud = 1
GROUP BY country , transaction_type , merchant_category
ORDER BY num_fraud DESC;

-- Q2: Which country the most non-fraud transactions?
SELECT 
    country, COUNT(*) AS num_fraud
FROM
    fraud.transactions
WHERE
    is_fraud = 0
GROUP BY country
ORDER BY num_fraud;

-- Q3: Which transaction type has the most fraud transactions?
SELECT 
    transaction_type, COUNT(*) AS num_fraud
FROM
    fraud.transactions
WHERE
    is_fraud = 1
GROUP BY transaction_type
ORDER BY num_fraud DESC;

-- Q4: Which transaction type has the most non-fraud transactions?
SELECT 
    transaction_type, COUNT(*) AS num_fraud
FROM
    fraud.transactions
WHERE
    is_fraud = 0
GROUP BY transaction_type
ORDER BY num_fraud;

-- Q5: Which merchant category has the most fraud transactions?
SELECT 
    merchant_category, COUNT(*) AS num_fraud
FROM
    fraud.transactions
WHERE
    is_fraud = 1
GROUP BY merchant_category
ORDER BY num_fraud DESC;

-- Q6: Which merchant category has the most non-fraud transactions?
SELECT 
    merchant_category, COUNT(*) AS num_fraud
FROM
    fraud.transactions
WHERE
    is_fraud = 0
GROUP BY merchant_category
ORDER BY num_fraud;

-- Q7: Which transaction hour has the most fraud transactions?
SELECT 
    transaction_hour, COUNT(*) AS num_fraud
FROM
    fraud.transactions
WHERE
    is_fraud = 1
GROUP BY transaction_hour
ORDER BY num_fraud DESC;

-- Q8: Which transaction hours have the most non-fraudulent transactions?
SELECT 
    transaction_hour, COUNT(*) AS num_fraud
FROM
    fraud.transactions
WHERE
    is_fraud = 0
GROUP BY transaction_hour
ORDER BY num_fraud;

-- Q9: What is the average fraud amount for each country?
SELECT 
    country, ROUND(AVG(amount), 2) AS avg_fraud_amount
FROM
    fraud.transactions
WHERE
    is_fraud = 1
GROUP BY country;

-- Q10: Which merchant category has multiple fraud offenders and who are the offenders? From which countries are they from?
SELECT 
    user_id, country, merchant_category, COUNT(*) AS num_fraud
FROM
    fraud.transactions
WHERE
    is_fraud = 1
GROUP BY user_id , merchant_category , country
HAVING num_fraud > 1
ORDER BY num_fraud DESC;

-- Q11: Which transaction type has multiple fraud offenders and who are the offenders? From which countries are they from?
SELECT 
    user_id, country, transaction_type, COUNT(*) AS num_fraud
FROM
    fraud.transactions
WHERE
    is_fraud = 1
GROUP BY user_id , transaction_type , country
HAVING num_fraud > 1
ORDER BY num_fraud DESC;

-- Q12: What is the ratio of the average fraudulent transaction amount to the average non-fraudulent transaction amount?
SELECT 
    ROUND(AVG(CASE
                WHEN is_fraud = 1 THEN amount
            END),
            2) AS avg_fraud,
    ROUND(AVG(CASE
                WHEN is_fraud = 0 THEN amount
            END),
            2) AS avg_nonfraud,
    ROUND((SELECT 
                    AVG(amount)
                FROM
                    fraud.transactions
                WHERE
                    is_fraud = 1) / (SELECT 
                    AVG(amount)
                FROM
                    fraud.transactions
                WHERE
                    is_fraud = 0),
            2) AS avg_amount_ratio
FROM
    fraud.transactions
GROUP BY is_fraud;

-- Q13: How does the device risk score affect the  average fraud amount?
SELECT 
    CASE
        WHEN
            device_risk_score >= 0.00
                AND device_risk_score < 0.10
        THEN
            '0.00 to 0.10'
        WHEN
            device_risk_score >= 0.10
                AND device_risk_score < 0.20
        THEN
            '0.10 to 0.20'
        WHEN
            device_risk_score >= 0.20
                AND device_risk_score < 0.30
        THEN
            '0.20 to 0.30'
        WHEN
            device_risk_score >= 0.30
                AND device_risk_score < 0.40
        THEN
            '0.30 to 0.40'
        WHEN
            device_risk_score >= 0.40
                AND device_risk_score < 0.50
        THEN
            '0.40 to 0.50'
        WHEN
            device_risk_score >= 0.50
                AND device_risk_score < 0.60
        THEN
            '0.50 to 0.60'
        WHEN
            device_risk_score >= 0.60
                AND device_risk_score < 0.70
        THEN
            '0.60 to 0.70'
        WHEN
            device_risk_score >= 0.70
                AND device_risk_score < 0.80
        THEN
            '0.70 to 0.80'
        WHEN
            device_risk_score >= 0.80
                AND device_risk_score < 0.90
        THEN
            '0.80 to 0.90'
        WHEN
            device_risk_score >= 0.90
                AND device_risk_score <= 1.00
        THEN
            '0.90 to 1.00'
    END AS device_risk_score_buckets,
    ROUND(AVG(amount), 2) AS avg_amount
FROM
    fraud.transactions
GROUP BY device_risk_score_buckets
ORDER BY device_risk_score_buckets;

-- Q14: How does the IP risk score affect the  average fraud amount?
SELECT 
    CASE
        WHEN
            ip_risk_score >= 0.00
                AND ip_risk_score < 0.10
        THEN
            '0.00 to 0.10'
        WHEN
            ip_risk_score >= 0.10
                AND ip_risk_score < 0.20
        THEN
            '0.10 to 0.20'
        WHEN
            ip_risk_score >= 0.20
                AND ip_risk_score < 0.30
        THEN
            '0.20 to 0.30'
        WHEN
            ip_risk_score >= 0.30
                AND ip_risk_score < 0.40
        THEN
            '0.30 to 0.40'
        WHEN
            ip_risk_score >= 0.40
                AND ip_risk_score < 0.50
        THEN
            '0.40 to 0.50'
        WHEN
            ip_risk_score >= 0.50
                AND ip_risk_score < 0.60
        THEN
            '0.50 to 0.60'
        WHEN
            ip_risk_score >= 0.60
                AND ip_risk_score < 0.70
        THEN
            '0.60 to 0.70'
        WHEN
            ip_risk_score >= 0.70
                AND ip_risk_score < 0.80
        THEN
            '0.70 to 0.80'
        WHEN
            ip_risk_score >= 0.80
                AND ip_risk_score < 0.90
        THEN
            '0.80 to 0.90'
        WHEN
            ip_risk_score >= 0.90
                AND ip_risk_score <= 1.00
        THEN
            '0.90 to 1.00'
    END AS ip_risk_score_buckets,
    ROUND(AVG(amount), 2) AS avg_amount
FROM
    fraud.transactions
GROUP BY ip_risk_score_buckets
ORDER BY ip_risk_score_buckets;

-- Q15: How does the IP risk score affect the  average fraud amount?
SELECT 
    CASE
        WHEN transaction_hour BETWEEN 0 AND 3 THEN '0 to 3'
        WHEN transaction_hour BETWEEN 4 AND 7 THEN '4 to 7'
        WHEN transaction_hour BETWEEN 8 AND 11 THEN '8 to 11'
        WHEN transaction_hour BETWEEN 12 AND 15 THEN '12 to 15'
        WHEN transaction_hour BETWEEN 16 AND 19 THEN '16 to 19'
        WHEN transaction_hour BETWEEN 20 AND 23 THEN '20 to 23'
    END AS transaction_hour_buckets,
    ROUND(AVG(amount), 2) AS amount_avg
FROM
    fraud.transactions
WHERE
    is_fraud = 1
GROUP BY transaction_hour_buckets
ORDER BY transaction_hour_buckets;

-- Q16: How volatile is the transaction amount for fraudulent activity compared to legitimate activity?
SELECT 
    ROUND(STDDEV(CASE
                WHEN is_fraud = 1 THEN amount
            END) / STDDEV(CASE
                WHEN is_fraud = 0 THEN amount
            END),
            2) AS volatility_ratio
FROM
    fraud.transactions;

-- Q17: Which countries, merchants, transaction types have fraud amounts which are higher than the average amount and by how much?
SELECT 
country, 
transaction_type,
merchant_category
fraud_avg, 
ROUND(amount / fraud_avg,2) AS ratio 
FROM 
	(SELECT 
country, 
amount,
transaction_type,
merchant_category,
	AVG(amount) OVER (PARTITION BY country) AS fraud_avg
	FROM fraud.transactions) s
WHERE amount > fraud_avg
ORDER BY ratio DESC;

-- Q18: What are the number of merchant category fraud cases for each country?
SELECT 
    country, merchant_category, COUNT(*) AS merchant_count
FROM
    fraud.transactions
WHERE
    is_fraud = 1
GROUP BY country , merchant_category
ORDER BY merchant_count DESC;

-- Q19: What are the number of transaction type fraud cases for each country?
SELECT 
    country, transaction_type, COUNT(*) AS transaction_count
FROM
    fraud.transactions
WHERE
    is_fraud = 1
GROUP BY country , transaction_type
ORDER BY transaction_count DESC;
