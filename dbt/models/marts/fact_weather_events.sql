{{ config(materialized='table') }}

select
    e.event_id,

    l.location_id,
    d.date_sk,
    e.airport_code,
    w.weather_event_id,
    e.start_time,
    e.end_time,
    e.duration_minutes,
    e.precipitation_in
   

from {{ ref('stg_weather_events') }} e

   left join {{ ref('dim_location') }} l
    on coalesce(e.airport_code, '') = coalesce(l.airport_code, '')
   and coalesce(e.city, '') = coalesce(l.city, '')
   and coalesce(e.county, '') = coalesce(l.county, '')
   and coalesce(e.state, '') = coalesce(l.state, '')
   and coalesce(e.zipcode, '') = coalesce(l.zipcode, '')
left join {{ref('dim_date')}} d
    on make_date(e.year, e.month, e.day) = d.date

left join {{ ref('dim_weather_event') }} w
    on e.event_type = w.event_type
   and e.severity = w.severity