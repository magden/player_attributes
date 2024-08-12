WITH recent_scores AS (
    SELECT
        player_id,
        tournament_score,
        ROW_NUMBER() OVER (PARTITION BY player_id ORDER BY tournament_score ASC) AS score_rank,
        COUNT(*) OVER (PARTITION BY player_id) AS total_scores
    FROM
        {{ ref('staging_events') }}
    WHERE
        DATE(date_utc) >= DATE_SUB(CURRENT_DATE(), INTERVAL 360 DAY)  -- Consider only the last 5 days
        AND tournament_score IS NOT NULL
),

median_scores AS (
    SELECT
        player_id,
        CASE
            -- If there's an odd number of scores, pick the middle one
            WHEN MOD(total_scores, 2) = 1 THEN (
                SELECT MAX(tournament_score)
                FROM recent_scores rs2
                WHERE rs2.player_id = rs.player_id
                AND rs2.score_rank = (rs.total_scores + 1) / 2
            )
            -- If there's an even number of scores, average the two middle scores
            ELSE (
                SELECT AVG(tournament_score)
                FROM recent_scores rs2
                WHERE rs2.player_id = rs.player_id
                AND rs2.score_rank IN (rs.total_scores / 2, rs.total_scores / 2 + 1)
            )
        END AS score_perc_50_last_5_days
    FROM
        recent_scores rs
    GROUP BY
        player_id, total_scores
)

SELECT
    player_id,
    MAX(score_perc_50_last_5_days) AS score_perc_50_last_5_days
FROM
    median_scores
GROUP BY
    player_id
