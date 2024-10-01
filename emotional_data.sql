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
    preceding_event

FROM (
    -- Deduplicate rows based on user_id and timestamp by selecting the earliest entry in case of duplicates
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id, timestamp ORDER BY timestamp) AS row_num
    FROM emotional_data
) AS deduplicated_data
WHERE row_num = 1;
