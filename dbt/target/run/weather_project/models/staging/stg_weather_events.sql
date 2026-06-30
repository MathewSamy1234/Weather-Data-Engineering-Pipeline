
  create view "weather"."gold"."stg_weather_events__dbt_tmp"
    
    
  as (
    select
    event_id,
    event_type,
    severity,
    start_time,
    end_time,
    duration_minutes,
    precipitation_in,
    airport_code,
    latitude,
    longitude,
    city,
    county,
    state,
    zipcode,
    month,
    day,
    year
from "weather"."silver"."weather_events"
  );