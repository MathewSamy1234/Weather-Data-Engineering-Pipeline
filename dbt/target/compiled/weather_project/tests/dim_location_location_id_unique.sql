select
    location_id,
    count(*)
from "weather"."gold"."dim_location"
group by location_id
having count(*) > 1