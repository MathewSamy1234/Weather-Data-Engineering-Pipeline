
  
    

  create  table "weather"."gold"."dim_weather_event__dbt_tmp"
  
  
    as
  
  (
    

select distinct
    md5(
        coalesce(event_type,'') || '|' ||
        coalesce(severity,'')
    ) as weather_event_id,

    event_type,
    severity

from "weather"."gold"."stg_weather_events"
  );
  