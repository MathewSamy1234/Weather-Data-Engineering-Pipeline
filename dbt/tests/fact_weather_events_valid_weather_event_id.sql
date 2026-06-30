select f.*
from {{ ref('fact_weather_events') }} f
left join {{ ref('dim_weather_event') }} w
    on f.weather_event_id = w.weather_event_id
where w.weather_event_id is null