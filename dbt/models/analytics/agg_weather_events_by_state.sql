{{ config(materialized='table') }}

select
    l.state,

    count(*) as event_count,

    avg(f.duration_minutes) as avg_duration_minutes,

    sum(
        coalesce(f.precipitation_in, 0)
    ) as total_precipitation_in

from {{ ref('fact_weather_events') }} f

join {{ ref('dim_location') }} l
    on f.location_id = l.location_id

group by
    l.state

order by
    event_count desc