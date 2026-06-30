select f.*
from {{ ref('fact_weather_events') }} f
left join {{ ref('dim_date') }} d
    on f.date_sk = d.date_sk
where d.date_sk is null