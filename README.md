# Empathic Credit System Analysis


This project aims to analyze the relationship between loan disbursement and user emotions. I perform data cleaning, quality checks, and explore the connections between emotional patterns and loan behaviors over time.

## Setup Instructions

### Prerequisites

- **SQLite**: Use SQLite to run SQL queries and work with databases.
- **DB Browser for SQLite**: I recommend using DB Browser for SQLite to easily manage and query SQLite databases.
- **Python Environment**: Ensure you have a Python environment with libraries such as `pandas`, `matplotlib`, `seaborn`, and other required libraries installed for analysis.

### Steps

1. **Setting Up the Database**:
    - Use **DB Browser for SQLite** to open and explore the SQLite database provided in the repository.
    - Run the SQL queries provided in the `data_input` folder (`emotional_data.sql`, `loans.sql`, and `users.sql`) to generate the data for analysis.
    - These SQL scripts will perform data quality checks, handle missing data, and output cleaned data for use in the analysis notebook.

2. **Data Frames**:
    - After running the SQL scripts, export the resulting tables as CSV files for further analysis.
    - The CSV files are located in the `data_input` folder. You can use them in the analysis notebook for visualization and reporting.

3. **Run the Analysis**:
    - Open the analysis notebook (`analysis_notebook.ipynb`) located in the `analysis` folder on Jupyter and execute the cells.
    - The notebook contains code for visualizations, data cleaning steps, and the final analysis. You can choose to use either the SQL scripts or the CSV files for the analysis.

---

## Assumptions

### Loans Data

- **Null Values**: In the `loans` data, the `paid_date` column has null values where loans were not paid. I kept these as null because filling them with placeholder values could affect time-related visualizations.
- **Data Cleaning**:
    - I checked for overlapping loans, ensuring no user had two loans issued with overlapping dates.
    - Duplicates in the data were handled by identifying repeated loan records based on the same `loan_id`, `user_id`, and `issue_date`.
    - Inaccurate loan amounts, invalid statuses, and other potential data errors were checked and cleaned.

### Emotional Data

- **Duplicates**: I assumed that duplicate emotional records with the same timestamp from the same user were data entry errors. These were removed to avoid skewing the analysis.
- **Missing Data**:
    - I kept missing values as null in columns like `relationship`, `location`, and `weather`, assuming that users did not provide this information.
    - In cases of missing `primary_emotion` or `time_of_day`, I flagged these records for potential errors but did not remove them, as they were critical for the emotional analysis.

### Users Data

- **Missing Data**: I assumed that missing values in fields like `score`, `approved_date`, `credit_limit`, and `interest_rate` indicated that users did not receive loans.
- **Null Values**: I maintained nulls for fields like `denied_date`, assuming that loans without this value were not denied yet.

---

## Data Cleaning Process

For more detailed information on the data cleaning process, refer to the SQL scripts provided in the `sql_queries` folder, which include:

- **loans.sql**: Covers the missingness analysis, quality checks for loan data, and cleaning steps.
- **emotional_data.sql**: Includes steps for handling missingness, duplicates, and data integrity checks in emotional data.
- **users.sql**: Describes data quality checks and cleaning steps for the user data.

### SQL Queries

The SQL scripts in the `sql` folder checks many data cleaning situations and perform various data quality checks, such as:

#### Loans Data:
- Missing value analysis.
- Checking for overlapping loans.
- Identifying duplicate loan records.
- Verifying loan amount consistency and valid date ranges.

#### Emotional Data:
- Handling missing values for `primary_emotion`, `time_of_day`, and other columns.
- Dealing with duplicate emotional records with the same timestamp for the same user.

#### Users Data:
- Handling missing values for fields like `score`, `credit_limit`, and `interest_rate`.
- Ensuring valid date formats for `approved_date` and `denied_date`.

### Example Queries:

#### Missing Value Analysis in Loan Data:

```sql
SELECT 
    'loan_id' AS column_name,
    100.0 * SUM(CASE WHEN loan_id IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM loans
UNION ALL
SELECT 
    'user_id' AS column_name,
    100.0 * SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS missing_percentage
FROM loans;

```
 
## Duplicate Emotions Query in Emotional Data:

```sql
WITH DuplicateEntries AS (
    SELECT 
        user_id,
        timestamp,
        COUNT(*) as duplicate_count
    FROM emotional_data
    GROUP BY user_id, timestamp
    HAVING COUNT(*) > 1
)
SELECT *
FROM emotional_data
WHERE (user_id, timestamp) IN (
    SELECT user_id, timestamp
    FROM DuplicateEntries
);
```


## Conclusion

This project applies robust data cleaning techniques and in-depth analysis to explore the relationship between emotional patterns and loan performance. By following the instructions and running the provided scripts and notebook, you will be able to reproduce the insights generated and visualize key findings.

If you encounter any issues, feel free to submit them in the Issues section of this repository.

