
  
    

  create  table "weather"."gold_analytics"."agg_weather_events_monthly__dbt_tmp"
  
  
    as
  
  (
    select
    d.year,
    d.month,
    d.month_name,

    count(*) as event_count,

    avg(f.duration_minutes) as avg_duration_minutes,

    sum(
        coalesce(f.precipitation_in, 0)
    ) as total_precipitation_in

from "weather"."gold"."fact_weather_events" f

join "weather"."gold"."dim_date" d
    on f.date_sk = d.date_sk

group by
    d.year,
    d.month,
    d.month_name

order by
    d.year,
    d.month
  );
  