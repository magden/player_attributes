{% set num_days = 10 %}  -- Define the number of days here

WITH active_days AS (
    SELECT
        player_id,
        DATE(date_utc) AS active_date,
        COUNT(*) AS match_count
    FROM
        {{ ref('staging_events') }}
    WHERE
        DATE(date_utc) >= DATE_SUB(CURRENT_DATE(), INTERVAL {{ num_days }} DAY)
    GROUP BY
        player_id, active_date
),

ranked_days AS (
    SELECT
        player_id,
        active_date,
        match_count,
        ROW_NUMBER() OVER (PARTITION BY player_id ORDER BY active_date DESC) AS day_rank
    FROM
        active_days
    WHERE
        match_count > 0
),

weighted_counts AS (
    SELECT
        player_id,
        SUM(match_count * ({{ num_days }}+1 - day_rank)) AS weighted_sum,
        COUNT(*) AS active_day_count
    FROM
        ranked_days
    WHERE
        day_rank <= {{ num_days }}  -- Use the injected variable here
    GROUP BY
        player_id
)

SELECT
    player_id,
    CASE
        WHEN active_day_count = 0 THEN NULL
        ELSE weighted_sum / (active_day_count * (active_day_count + 1) / 2)  -- Calculate weighted average
    END AS last_weighted_daily_matches_count_10_played_days
FROM
    weighted_counts
