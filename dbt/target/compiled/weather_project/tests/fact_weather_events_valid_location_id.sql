select f.*
from "weather"."gold"."fact_weather_events" f
left join "weather"."gold"."dim_location" l
    on f.location_id = l.location_id
where l.location_id is null