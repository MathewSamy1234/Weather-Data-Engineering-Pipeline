
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  select *
from "weather"."gold"."dim_date"
where date_sk is null
  
  
      
    ) dbt_internal_test