select
    location_id,
    count(*)
from {{ ref('dim_location') }}
group by location_id
having count(*) > 1