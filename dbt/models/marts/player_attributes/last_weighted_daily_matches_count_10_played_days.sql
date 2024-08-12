

select
    player_id,
    sum(weight * matches) / sum(weight) as last_weighted_daily_matches_count_10_played_days
from (
    select
        player_id,
        count(*) as matches,
        row_number() over (partition by player_id order by active_date desc) as rn,
        case
            when row_number() over (partition by player_id order by active_date desc) <= 10 then 11 - row_number() over (partition by player_id order by active_date desc)
            else 0
        end as weight
    from
        {{ ref('staging_events') }}
    group by
        player_id, active_date
)
where weight > 0
group by player_id
