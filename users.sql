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
