
select
    d.year,
    d.month,
    d.month_name,

    count(*) as event_count,

    avg(f.duration_minutes) as avg_duration_minutes,

    sum(
        coalesce(f.precipitation_in, 0)
    ) as total_precipitation_in

from {{ ref('fact_weather_events') }} f

join {{ ref('dim_date') }} d
    on f.date_sk = d.date_sk

group by
    d.year,
    d.month,
    d.month_name

order by
    d.year,
    d.month