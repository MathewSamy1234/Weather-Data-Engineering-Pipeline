select *
from {{ ref('dim_date') }}
where date_sk is null