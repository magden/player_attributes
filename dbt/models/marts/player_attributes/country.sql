-- models/player_attributes/country.sql

WITH staging AS (
    SELECT *
    FROM {{ ref('staging_events') }}
)

SELECT
    player_id,
    last_value(country IGNORE NULLS) OVER (PARTITION BY player_id ORDER BY date_utc) AS country
FROM
    staging












{##}
{#select#}
{#    player_id,#}
{#    last_value(country ignore nulls) over (partition by player_id order by timestamp_utc) as country#}
{#from#}
{#    {{ ref('staging_events') }}#}
