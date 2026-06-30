
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  select f.*
from "weather"."gold"."fact_weather_events" f
left join "weather"."gold"."dim_weather_event" w
    on f.weather_event_id = w.weather_event_id
where w.weather_event_id is null
  
  
      
    ) dbt_internal_test