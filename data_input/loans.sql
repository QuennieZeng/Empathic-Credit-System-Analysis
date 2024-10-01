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
