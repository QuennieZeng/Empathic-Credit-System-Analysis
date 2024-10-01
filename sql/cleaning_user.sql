-- USER DATA 
-- check missingness of data
SELECT 
    'user_id' AS column_name,
    100.0 * SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM users
UNION ALL
SELECT 
    'score' AS column_name,
    100.0 * SUM(CASE WHEN score IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM users
UNION ALL
SELECT 
    'approved_date' AS column_name,
    100.0 * SUM(CASE WHEN approved_date IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM users
UNION ALL
SELECT 
    'denied_date' AS column_name,
    100.0 * SUM(CASE WHEN denied_date IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM users
UNION ALL
SELECT 
    'credit_limit' AS column_name,
    100.0 * SUM(CASE WHEN credit_limit IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM users
UNION ALL
SELECT 
    'interest_rate' AS column_name,
    100.0 * SUM(CASE WHEN interest_rate IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM users
UNION ALL
SELECT 
    'loan_term' AS column_name,
    100.0 * SUM(CASE WHEN loan_term IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM users;

-- user_id has no missing data
-- score, approved_date, credit_limit, interest_rate, and loan_term all have 9.12806539509537% of missingness which is good since if one does not have a score then they will not get a loan
-- this means there is no missingness from human error or a mistake where the data is not recorded
-- denied_date has 75.7493188010899% of missingness. It is good to have missingness of denied_date higher than approved, as the amount of loans given should be higher (less missingness)
-- than loans denied after approval (higher missingness)

-- we will not fill in nulls with n/a to keep sql queries and data visualizations working correctly. 

-- now we can work on data quality checks!
-- -- explored instances of duplicate data, inaccurate data, incomplete data, human error, and more!

-- -- 1. Check for duplicate user_id
-- SELECT user_id, COUNT(*) 
-- FROM users 
-- GROUP BY user_id 
-- HAVING COUNT(*) > 1;

-- -- 2. Check for negative or zero values in credit_limit, interest_rate, score
-- SELECT * 
-- FROM users
-- WHERE credit_limit <= 0 
--    OR interest_rate <= 0 
--    OR score <= 0;

-- -- 3. Check for rows with nulls in important fields
-- SELECT * 
-- FROM users
-- WHERE user_id IS NULL 
--    OR loan_term IS NULL 
--    OR score IS NULL;

-- -- 4. Check for inconsistent approval relationships
-- SELECT * 
-- FROM users
-- WHERE approved_date IS NULL
--    AND (credit_limit IS NOT NULL OR interest_rate IS NOT NULL OR loan_term IS NOT NULL);

-- did not have too many nulls in rows so kept the ones that were null


-- After preformed my own data quality checks for issues. I ran this query to get the csv file. 

-- Extract valid data from users table with all quality checks applied
SELECT *
FROM users
WHERE 
    -- Ensure no null values in critical fields
    user_id IS NOT NULL

    -- Score-specific rules
    AND NOT (score IS NULL AND (approved_date IS NOT NULL OR credit_limit IS NOT NULL OR interest_rate IS NOT NULL OR loan_term IS NOT NULL))

    -- Loan term should be in increments of 3
    AND (loan_term IS NULL OR loan_term % 3 = 0)

    -- Ensure score is a positive decimal
    AND (score IS NULL OR score > 0)

    -- Date format checks (valid date format 'YYYY-MM-DD')
    AND (approved_date IS NULL OR approved_date LIKE '____-__-__')
    AND (denied_date IS NULL OR denied_date LIKE '____-__-__')

    -- Ensure credit_limit is an integer
    AND (credit_limit IS NULL OR CAST(credit_limit AS INTEGER) = credit_limit)

    -- Ensure interest_rate is a non-negative decimal
    AND (interest_rate IS NULL OR interest_rate >= 0)

    -- Ensure loan_term is an integer
    AND (loan_term IS NULL OR CAST(loan_term AS INTEGER) = loan_term)

    -- If approved_date is not null, then credit_limit, interest_rate, and loan_term should also not be null
    AND (approved_date IS NULL OR (credit_limit IS NOT NULL AND interest_rate IS NOT NULL AND loan_term IS NOT NULL))

    -- Handle duplicate users
    AND (user_id) IN (
        SELECT user_id
        FROM users
        GROUP BY user_id
        HAVING COUNT(*) = 1
    );
