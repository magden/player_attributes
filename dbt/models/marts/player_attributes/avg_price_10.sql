

WITH staging AS (
    SELECT *
    FROM {{ ref('staging_events') }}
)

select
    player_id,
    avg(deposit_amount) as avg_price_10
from (
    select
        player_id,
        deposit_amount,
        row_number() over (partition by player_id order by timestamp_utc desc) as rn
    from
        staging
    where
        deposit_amount is not null
)
where rn <= 10
group by player_id
