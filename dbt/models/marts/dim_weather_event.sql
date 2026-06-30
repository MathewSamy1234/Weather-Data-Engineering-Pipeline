{{ config(materialized='table') }}

select distinct
    md5(
        coalesce(event_type,'') || '|' ||
        coalesce(severity,'')
    ) as weather_event_id,

    event_type,
    severity

from {{ ref('stg_weather_events') }}