-- Creating the database
create database if not exists loandata;

-- Loading the data
LOAD DATA INFILE 'C:/milisa/onedrive/workings/loan_data.csv' 
INTO TABLE loan_staging 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(person_age, person_gender, person_education, person_income, person_emp_exp, 
 person_home_ownership, loan_amnt, loan_intent, loan_int_rate, 
 loan_percent_income, cb_person_cred_hist_length, credit_score, 
 previous_loan_defaults_on_file, loan_status);

-- Create & populate a column for unique row id
ALTER TABLE loandata.loanstaging ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY;

-- Create Person Table
CREATE TABLE loandata.dim_person (
    person_id INT PRIMARY KEY,
    age INT,
    gender VARCHAR(20),
    education VARCHAR(50),
    income DECIMAL(15 , 2 ),
    emp_exp INT,
    home_ownership VARCHAR(50)
);

-- Create Loan Info Table
CREATE TABLE loandata.fact_loan (
    loan_id INT PRIMARY KEY,
    person_id INT,
    loan_amnt DECIMAL(15 , 2 ),
    loan_intent VARCHAR(100),
    loan_int_rate DECIMAL(5 , 2 ),
    loan_percent_income DECIMAL(5 , 2 ),
    loan_status INT,
    FOREIGN KEY (person_id)
        REFERENCES dim_person (person_id)
);

-- Create Credit History Table
CREATE TABLE loandata.dim_credit (
    credit_id INT PRIMARY KEY,
    person_id INT,
    cred_hist_length INT,
    credit_score INT,
    previous_defaults VARCHAR(10),
    FOREIGN KEY (person_id)
        REFERENCES dim_person (person_id)
);

-- Populate Person Table
INSERT INTO loandata.dim_person (person_id, age, gender, education, income, emp_exp, home_ownership)
SELECT row_id, person_age, person_gender, person_education, person_income, person_emp_exp, person_home_ownership
FROM loandata.loanstaging;

-- Populate Loan Table
INSERT INTO loandata.fact_loan (loan_id, person_id, loan_amnt, loan_intent, loan_int_rate, loan_percent_income, loan_status)
SELECT row_id, row_id, loan_amnt, loan_intent, loan_int_rate, loan_percent_income, loan_status
FROM loandata.loanstaging;

-- Populate Credit Table
INSERT INTO loandata.dim_credit (credit_id, person_id, cred_hist_length, credit_score, previous_defaults)
SELECT row_id, row_id, cb_person_cred_hist_length, credit_score, previous_loan_defaults_on_file
FROM loandata.loanstaging;

-- Drop the staging table
DROP TABLE loandata.loanstaging;

-- Q1: Find the average loan amount and the average interest rate for each loan intent.
SELECT 
    loan_intent,
    ROUND(AVG(loan_amnt), 2) AS avg_loan_amnt,
    ROUND(AVG(loan_int_rate), 2) AS avg_int_rate
FROM
    loandata.fact_loan
GROUP BY loan_intent;

-- Q2: How many loan applications exist for each loan intent? What is the percentage of rejected and approved loans?
SELECT 
    loan_intent,
    COUNT(*) AS count_loan_intent,
    ROUND(SUM(CASE
                WHEN loan_status = 1 THEN 1
                ELSE 0
            END) * 100 / COUNT(*),
            2) AS loan_yes_pct,
    ROUND(SUM(CASE
                WHEN loan_status = 0 THEN 1
                ELSE 0
            END) * 100 / COUNT(*),
            2) AS loan_no_pct
FROM
    loandata.fact_loan
GROUP BY loan_intent
ORDER BY count_loan_intent DESC;

-- Q3: List the top 10 highest-earning individuals and their income
SELECT 
    person_id, income
FROM
    loandata.dim_person
ORDER BY income DESC
LIMIT 10;

-- Q4: Find the maximum and minimum years of employment experience
SELECT 
    MAX(emp_exp) AS max_emp_exp, MIN(emp_exp) AS min_emp_exp
FROM
    loandata.dim_person;

-- Q5: Calculate the average income for each education level. Which group earns the most?
SELECT 
    dp.education, ROUND(AVG(income), 2) AS avg_income
FROM
    loandata.dim_person dp
        INNER JOIN
    loandata.fact_loan fl ON dp.person_id = fl.loan_id
GROUP BY dp.education
ORDER BY avg_income DESC;

-- Q6: What is the average loan amount for each credit score bucket
SELECT 
    CASE
        WHEN credit_score < 580 THEN 'Poor (<580)'
        WHEN credit_score < 670 THEN 'Fair (580-669)'
        WHEN credit_score < 740 THEN 'Good (670-739)'
        WHEN credit_score >= 740 THEN 'Excellent (740+)'
    END AS credit_tier,
    ROUND(AVG(loan_amnt), 2) AS avg_loan_amnt
FROM
    loandata.fact_loan fl
        INNER JOIN
    loandata.dim_credit dc ON fl.person_id = dc.person_id
GROUP BY credit_tier;

-- Q7: What is the average credit score for each loan status?
SELECT 
    loan_status, ROUND(AVG(credit_score), 2) AS avg_credit_score
FROM
    loandata.fact_loan fl
        INNER JOIN
    loandata.dim_credit dc ON fl.person_id = dc.credit_id
GROUP BY fl.loan_status;

-- Q8: Show the average credit score for people who have previously defaulted vs. those who haven't.
SELECT 
    previous_defaults,
    ROUND(AVG(credit_score), 2) AS avg_credit_score
FROM
    loandata.dim_credit
GROUP BY previous_defaults;

-- Q9: What is the average amount of money loaned to each gender and what is their average credit score?
SELECT 
    gender,
    ROUND(AVG(loan_amnt), 2) AS avg_loan_amnt,
    ROUND(AVG(credit_score), 2) AS avg_credit_score
FROM
    loandata.dim_person dp
        INNER JOIN
    loandata.fact_loan fl ON dp.person_id = fl.person_id
        INNER JOIN
    loandata.dim_credit dc ON dp.person_id = dc.person_id
GROUP BY dp.gender;

-- Q10: What is the average credit score for loans that were approved versus those that were rejected?
SELECT 
    loan_status, ROUND(AVG(credit_score), 2) AS avg_credit_score
FROM
    loandata.fact_loan fl
        INNER JOIN
    loandata.dim_credit dc ON fl.person_id = dc.person_id
GROUP BY loan_status;

-- Q11: What is the average interest rate for each previous default?
SELECT 
    previous_defaults,
    ROUND(AVG(loan_int_rate), 2) AS avg_int_rate
FROM
    loandata.dim_credit dc
        INNER JOIN
    loandata.fact_loan fl ON dc.person_id = fl.person_id
GROUP BY previous_defaults;

-- Q12: Does housing stability strictly correlate with higher income in this data?
SELECT 
    home_ownership, ROUND(AVG(income), 2) AS avg_income
FROM
    loandata.dim_person
GROUP BY home_ownership
ORDER BY avg_income DESC;

-- Q13: Does employment experience actually lead to higher credit scores, or is age a bigger factor?
SELECT 
    CASE
        WHEN credit_score < 580 THEN 'Poor (<580)'
        WHEN credit_score < 670 THEN 'Fair (580-669)'
        WHEN credit_score < 740 THEN 'Good (670-739)'
        WHEN credit_score >= 740 THEN 'Excellent (740+)'
    END AS credit_tier,
    CASE
        WHEN age < 35 THEN '20 - 35'
        WHEN age < 51 THEN '36 - 50'
        WHEN age < 66 THEN '51 - 66'
        WHEN age < 82 THEN '67 - 81'
        WHEN age < 97 THEN '97+'
    END AS age_range,
    ROUND(AVG(credit_score), 2) AS avg_credit_score
FROM
    loandata.dim_person dp
        INNER JOIN
    loandata.dim_credit dc ON dp.person_id = dc.person_id
GROUP BY credit_tier , age_range;

-- Q14: What is the average interest rate for credit scores?
SELECT 
    CASE
        WHEN credit_score < 580 THEN 'Poor (<580)'
        WHEN credit_score < 670 THEN 'Fair (580-669)'
        WHEN credit_score < 740 THEN 'Good (670-739)'
        WHEN credit_score >= 740 THEN 'Excellent (740+)'
    END AS credit_tier,
    ROUND(AVG(loan_int_rate), 2) AS avg_int_rate
FROM
    loandata.fact_loan fl
        INNER JOIN
    loandata.dim_credit dc ON fl.person_id = dc.person_id
GROUP BY credit_tier;

-- Q15: Calculate the "Interest-to-Risk" ratio.
SELECT 
    FLOOR(credit_score / 50) * 50 AS score_bracket,
    ROUND(AVG(loan_int_rate), 2) AS avg_interest_rate,
    COUNT(*) AS total_borrowers
FROM
    loandata.dim_credit c
        JOIN
    loandata.fact_loan l ON c.person_id = l.person_id
GROUP BY score_bracket
ORDER BY score_bracket ASC;

-- Q16: What is the approval rate for each home ownership type?
SELECT 
    home_ownership,
    ROUND(AVG(loan_status) * 100, 2) AS approval_rate
FROM
    loandata.dim_person dp
        INNER JOIN
    loandata.fact_loan fl ON dp.person_id = fl.person_id
GROUP BY home_ownership
ORDER BY approval_rate DESC;

-- Q17: Which loan_intent has the highest percentage of approvals?
SELECT 
    loan_intent,
    ROUND(AVG(loan_status) * 100, 2) AS approval_rate
FROM
    loandata.fact_loan
GROUP BY loan_intent
ORDER BY approval_rate DESC;

-- Q18: Does a long employment history correlate with a longer credit history, and which one is a better predictor of a high credit score?
SELECT 
    CASE
        WHEN emp_exp < 25 THEN '0 to 25'
        WHEN emp_exp < 50 THEN '25 to 50'
        WHEN emp_exp < 75 THEN '50 to 75'
        WHEN emp_exp < 100 THEN '75 to 100'
        WHEN emp_exp >= 100 THEN '100 to 125'
    END AS experience_buckets,
    ROUND(AVG(cred_hist_length), 2) AS avg_cred_hist,
    ROUND(AVG(credit_score), 2) AS avg_credit_score
FROM
    loandata.dim_person dp
        INNER JOIN
    loandata.dim_credit dc ON dp.person_id = dc.person_id
GROUP BY experience_buckets;

-- Q19: What is the relationship between "Debt Load" (loan amount relative to income) and the interest rate?
SELECT 
    CASE
        WHEN loan_percent_income < 0.22 THEN '0 to 0.22'
        WHEN loan_percent_income < 0.44 THEN '0.22 to 0.44'
        WHEN loan_percent_income >= 0.44 THEN '0.44 to 0.66'
    END AS lpct_buckets,
    ROUND(AVG(loan_int_rate), 2) AS avg_int_rate
FROM
    fact_loan
GROUP BY lpct_buckets;

-- Q20: Within the same income bracket, does having more employment experience (person_emp_exp) lead to lower interest rates?
SELECT 
    CASE
        WHEN income < 1446553.2 THEN '8000 to 1446553'
        WHEN income < 2885106.4 THEN '1446553 to 2885106'
        WHEN income < 4323659.6 THEN '2885106 to 4323660'
        WHEN income < 5762212.8 THEN '4323660 to 5762213'
        WHEN income >= 5762212.8 THEN '5762213 to 7200766'
    END AS income_buckets,
    CASE
        WHEN emp_exp < 25 THEN '0 to 25'
        WHEN emp_exp < 50 THEN '25 to 50'
        WHEN emp_exp < 75 THEN '50 to 75'
        WHEN emp_exp < 100 THEN '75 to 100'
        WHEN emp_exp >= 100 THEN '100 to 125'
    END AS experience_buckets,
    ROUND(AVG(loan_int_rate), 2) AS avg_int_rate
FROM
    loandata.dim_person dp
        INNER JOIN
    loandata.fact_loan fl ON dp.person_id = fl.person_id
GROUP BY income_buckets , experience_buckets;
