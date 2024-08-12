
SELECT
    DISTINCT country.player_id,
    country.country AS country,
    avg_price_10.avg_price_10 AS avg_price_10,
    weighted.last_weighted_daily_matches_count_10_played_days,
    ad.active_days_since_last_purchase,
    score.score_perc_50_last_5_days as score_perc_50_last_5_days,
FROM
    {{ ref('country') }} AS country
LEFT JOIN
    {{ ref('avg_price_10') }} AS avg_price_10 ON country.player_id = avg_price_10.player_id
LEFT JOIN
    {{ ref('active_days_since_last_purchase') }} AS ad ON country.player_id = ad.player_id  -- Join with active_days model
LEFT JOIN
    {{ ref('score_perc_50_last_5_days') }} AS score ON country.player_id = score.player_id  -- Join with active_days model
LEFT JOIN
    {{ ref('weighted_matches') }} AS weighted ON country.player_id = weighted.player_id  -- Join with active_days model
