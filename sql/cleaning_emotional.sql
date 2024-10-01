-- EMOTIONAL DATA 
-- check missingness of data
SELECT
    -- Total row count
    COUNT(*) AS total_count,

    -- Percentage of missing values for each key column
    (COUNT(CASE WHEN time_of_day IS NULL THEN 1 END) * 100.0 / COUNT(*)) AS pct_missing_time_of_day,
    (COUNT(CASE WHEN primary_emotion IS NULL THEN 1 END) * 100.0 / COUNT(*)) AS pct_missing_primary_emotion,
    (COUNT(CASE WHEN relationship IS NULL THEN 1 END) * 100.0 / COUNT(*)) AS pct_missing_relationship,
    (COUNT(CASE WHEN situation IS NULL THEN 1 END) * 100.0 / COUNT(*)) AS pct_missing_situation,
    (COUNT(CASE WHEN location IS NULL THEN 1 END) * 100.0 / COUNT(*)) AS pct_missing_location,
    (COUNT(CASE WHEN weather IS NULL THEN 1 END) * 100.0 / COUNT(*)) AS pct_missing_weather,
    (COUNT(CASE WHEN physical_state IS NULL THEN 1 END) * 100.0 / COUNT(*)) AS pct_missing_physical_state,
    (COUNT(CASE WHEN preceding_event IS NULL THEN 1 END) * 100.0 / COUNT(*)) AS pct_missing_preceding_event
FROM emotional_data;

-- -- everything but time_of_day, primary_emotion, grade had more than 5 % of missing data

-- -- since the relationship is missing for a significant portion, it could be possible that the user was ‘alone’ however we will not assume for integrity reasons
-- -- since the situation is missing for a significant portion, it could be possible that the user was ‘alone’ however we will not assume for integrity reasons
-- -- since the location is missing for a significant portion, we will keep it null to not affect our visualizations
-- -- since the weather is missing for a significant portion, we will keep it null to not affect our visualizations
-- -- since the physical_state is missing for a significant portion, we will keep it null to not affect our visualizations
-- -- since the preceding_event is missing for a significant portion, we will keep it null to not affect our visualizations


-- now that we dealt with missingness, let's look at other data quality concerns such as duplicate entires or human error 
-- here we looked at duplicates and see that some would have two emotions at the same time 

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

-- here we have 34 rows that are duplicates of each other. For these rows, the locations and weather are not consistent. To maintain integrity, we will not include them. 

SELECT 
    user_id,
    
    -- Ensure the timestamp is in the correct format
    STRFTIME('%Y-%m-%d %H:%M:%S', timestamp) AS timestamp,

    -- Handle outliers for intensity (ensuring intensity is between 0 and 10)
    CASE 
        WHEN intensity < 0 OR intensity > 10 THEN NULL 
        ELSE intensity 
    END AS intensity,

    -- Standardize and check time_of_day for consistency
    CASE 
        WHEN time_of_day NOT IN ('morning', 'afternoon', 'evening', 'night') THEN 'Inconsistent' 
        ELSE LOWER(time_of_day) 
    END AS time_of_day,

    -- Standardize primary_emotion field and ensure consistency
    CASE 
        WHEN primary_emotion IS NULL THEN 'Inconsistent'
        ELSE LOWER(primary_emotion)
    END AS primary_emotion,

    -- Keep relationship as NULL where it was missing
    relationship,

    -- Keep situation as NULL where it was missing
    situation,

    -- Keep location, weather, and physical_state as NULL where they were missing
    location,
    weather,
    physical_state,

    -- Keep preceding_event as NULL where it was missing
    preceding_event,

    -- Keep grade
    grade

FROM (
    -- Deduplicate rows based on user_id and timestamp by selecting the earliest entry in case of duplicates
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id, timestamp ORDER BY timestamp) AS row_num
    FROM emotional_data
) AS deduplicated_data
WHERE row_num = 1;
