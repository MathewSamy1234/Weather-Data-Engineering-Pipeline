select f.*
from {{ ref('fact_weather_events') }} f
left join {{ ref('dim_location') }} l
    on f.location_id = l.location_id
where l.location_id is null