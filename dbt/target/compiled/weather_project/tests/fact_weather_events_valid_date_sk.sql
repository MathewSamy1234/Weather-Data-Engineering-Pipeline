select f.*
from "weather"."gold"."fact_weather_events" f
left join "weather"."gold"."dim_date" d
    on f.date_sk = d.date_sk
where d.date_sk is null