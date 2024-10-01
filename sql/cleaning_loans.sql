-- LOANS DATA 
-- check missingness of data

SELECT 
    'loan_id' AS column_name,
    100.0 * SUM(CASE WHEN loan_id IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM loans
UNION ALL
SELECT 
    'user_id' AS column_name,
    100.0 * SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM loans
UNION ALL
SELECT 
    'loan_amount' AS column_name,
    100.0 * SUM(CASE WHEN loan_amount IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM loans
UNION ALL
SELECT 
    'total_amount' AS column_name,
    100.0 * SUM(CASE WHEN total_amount IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM loans
UNION ALL
SELECT 
    'issue_date' AS column_name,
    100.0 * SUM(CASE WHEN issue_date IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM loans
UNION ALL
SELECT 
    'due_date' AS column_name,
    100.0 * SUM(CASE WHEN due_date IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM loans
UNION ALL
SELECT 
    'paid_date' AS column_name,
    100.0 * SUM(CASE WHEN paid_date IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM loans
UNION ALL
SELECT 
    'installment_amount' AS column_name,
    100.0 * SUM(CASE WHEN installment_amount IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM loans
UNION ALL
SELECT 
    'loan_amount_paid' AS column_name,
    100.0 * SUM(CASE WHEN loan_amount_paid IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM loans
UNION ALL
SELECT 
    'status' AS column_name,
    100.0 * SUM(CASE WHEN status IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM loans;


-- the only data missing is paid_date, meaning that this is no odd missing data. Data missing in paid_date means the loan was not paid yet
-- we will keep the paid_date as null as putting n/a could affect the way charts related to time are created 

-- we checked whether the loans for users overlap with each other 
-- SELECT l1.*
-- FROM loans l1
-- LEFT JOIN loans l2 
--     ON l1.user_id = l2.user_id
--     AND l1.loan_id != l2.loan_id
--     AND l1.issue_date <= l2.due_date
--     AND l1.due_date >= l2.issue_date
-- WHERE l2.loan_id IS NULL;

-- they did not 

-- -- explored instances of duplicate data, inaccurate data, incomplete data, human error, and more!
-- -- Identify potential duplicate loans based on loan_id, user_id, and issue_date
-- SELECT loan_id, user_id, issue_date, COUNT(*) as count
-- FROM loans
-- GROUP BY loan_id, user_id, issue_date
-- HAVING count > 1;

-- -- Check for negative loan amounts (inaccurate data)
-- SELECT *
-- FROM loans
-- WHERE loan_amount < 0;

-- -- Check for incomplete data where mandatory fields are null
-- SELECT *
-- FROM loans
-- WHERE loan_amount IS NULL
--    OR issue_date IS NULL
--    OR user_id IS NULL;

-- -- Check for human errors where paid_date is earlier than issue_date
-- SELECT *
-- FROM loans
-- WHERE paid_date IS NOT NULL AND paid_date < issue_date;

-- -- Check for invalid input values
-- SELECT *
-- FROM loans
-- WHERE loan_amount < 0 OR total_amount < 0;

-- -- Check for ambiguous status values
-- SELECT DISTINCT status
-- FROM loans;

-- -- Standardize date format (if necessary)
-- UPDATE loans
-- SET issue_date = STRFTIME('%Y-%m-%d', issue_date)
-- WHERE issue_date NOT LIKE '____-__-__';

-- -- Check for conflicting number formats (e.g., interest_rate should be a decimal)
-- SELECT *
-- FROM loans
-- WHERE CAST(installment_amount AS TEXT) LIKE '%[^0-9.]%';

-- -- Check for invalid input values
-- SELECT *
-- FROM loans
-- WHERE loan_amount < 0 OR total_amount < 0;

-- -- Check for inaccurate data entry (e.g., non-numeric loan amounts)
-- SELECT *
-- FROM loans
-- WHERE loan_amount IS NULL OR loan_amount < 0;

-- did not have too many nulls in rows so kept the ones that were null




-- Extract valid data from loans table with all quality checks applied. I ran this query to get the csv file. 
SELECT *
FROM loans
WHERE 
    -- Ensure no null values in critical fields
    loan_id IS NOT NULL
    AND user_id IS NOT NULL
    AND loan_amount IS NOT NULL
    AND total_amount IS NOT NULL
    AND issue_date IS NOT NULL
    AND due_date IS NOT NULL
    AND installment_amount IS NOT NULL
    AND loan_amount_paid IS NOT NULL
    AND status IS NOT NULL

    AND NOT ((status = 'ongoing' OR status = 'late') AND paid_date IS NOT NULL)

    -- Total amount and loan_amount consistency
    AND total_amount > loan_amount
    AND loan_amount_paid <= total_amount

    -- Date consistency
    AND issue_date < due_date
    AND (status != 'paid' OR (paid_date IS NULL OR paid_date <= due_date))

    -- Installment amount logic
    AND installment_amount < total_amount
    AND installment_amount < loan_amount

    -- Format checks (e.g., correct date format)
    AND issue_date LIKE '____-__-__'
    AND due_date LIKE '____-__-__'

    -- Ensure no orphaned data
    AND user_id IN (SELECT user_id FROM users)

    -- Handle duplicate loans
    AND (loan_id, user_id, issue_date) IN (
        SELECT loan_id, user_id, issue_date
        FROM loans
        GROUP BY loan_id, user_id, issue_date
        HAVING COUNT(*) = 1
    );
