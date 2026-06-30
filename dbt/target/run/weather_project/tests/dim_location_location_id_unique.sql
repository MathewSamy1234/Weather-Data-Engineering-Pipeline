
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  select
    location_id,
    count(*)
from "weather"."gold"."dim_location"
group by location_id
having count(*) > 1
  
  
      
    ) dbt_internal_test