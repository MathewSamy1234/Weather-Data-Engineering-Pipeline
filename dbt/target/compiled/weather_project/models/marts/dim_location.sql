

select distinct
    md5(
        coalesce(airport_code,'') ||
        coalesce(city,'') ||
        coalesce(state,'') ||
        coalesce(zipcode,'')
    ) as location_id,

    airport_code,
    city,
    county,
    state,
    zipcode,
    latitude,
    longitude

from "weather"."gold"."stg_weather_events"