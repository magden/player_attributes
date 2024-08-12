WITH last_purchase AS (
    SELECT
        player_id,
        MAX(date_utc) AS last_purchase_date
    FROM
        {{ ref('staging_events') }}
    WHERE
        deposit_amount IS NOT NULL
    GROUP BY
        player_id
),

active_days AS (
    SELECT
        player_id,
        COUNT(DISTINCT DATE(date_utc)) AS active_days_count
    FROM
        {{ ref('staging_events') }}
    WHERE
        DATE(date_utc) > (
            SELECT DATE(MAX(lp.last_purchase_date))
            FROM last_purchase lp
            WHERE lp.player_id = staging_events.player_id
        )
    GROUP BY
        player_id
)

SELECT
    lp.player_id,
    -- Calculate active days since last purchase
    COALESCE(ad.active_days_count, 0) AS active_days_since_last_purchase
FROM
    last_purchase lp
LEFT JOIN
    active_days ad ON lp.player_id = ad.player_id
