{{ config(materialized='table') }}

select
    w.event_type,
    w.severity,

    count(*) as event_count,

    avg(f.duration_minutes) as avg_duration_minutes,

    sum(
        coalesce(f.precipitation_in, 0)
    ) as total_precipitation_in

from {{ ref('fact_weather_events') }} f

join {{ ref('dim_weather_event') }} w
    on f.weather_event_id = w.weather_event_id

group by
    w.event_type,
    w.severity

order by
    event_count desc