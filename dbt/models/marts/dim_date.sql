{{ config(materialized='table') }}

{% set start_date = '2000-01-01' %}
{% set end_date = '2049-12-31' %}

with dates as (

select
    generate_series(
        '{{ start_date }}'::date,
        '{{ end_date }}'::date,
        interval '1 day'
    )::date as date_day


),

base as (

select
    to_char(date_day, 'YYYYMMDD')::integer as date_sk,
    date_day as date,

    to_char(date_day, 'DD') as day,

    case
        when extract(day from date_day) in (11,12,13)
            then extract(day from date_day)::text || 'th'
        when right(extract(day from date_day)::text,1) = '1'
            then extract(day from date_day)::text || 'st'
        when right(extract(day from date_day)::text,1) = '2'
            then extract(day from date_day)::text || 'nd'
        when right(extract(day from date_day)::text,1) = '3'
            then extract(day from date_day)::text || 'rd'
        else extract(day from date_day)::text || 'th'
    end as day_suffix,

    trim(to_char(date_day,'Day')) as day_of_week,

    row_number() over (
        partition by
            date_trunc('month', date_day),
            extract(isodow from date_day)
        order by date_day
    ) as dow_in_month,

    extract(doy from date_day)::int as day_of_year,

    extract(week from date_day)::int as week_of_year,

    (
        extract(day from date_day)::int - 1
    ) / 7 + 1 as week_of_month,

    to_char(date_day,'MM') as month,

    trim(to_char(date_day,'Month')) as month_name,

    extract(quarter from date_day)::int as quarter,

    case extract(quarter from date_day)
        when 1 then 'First'
        when 2 then 'Second'
        when 3 then 'Third'
        when 4 then 'Fourth'
    end as quarter_name,

    extract(year from date_day)::text as year,

    to_char(date_day,'MM/DD/YYYY') as standard_date

from dates


),

holidays as (


select
    date_sk,

    case

        when month = '01'
             and day = '01'
        then 'New Year''s Day'

        when month = '02'
             and day = '14'
        then 'Valentine''s Day'

        when month = '03'
             and day = '17'
        then 'Saint Patrick''s Day'

        when month = '07'
             and day = '04'
        then 'Independence Day'

        when month = '10'
             and day = '31'
        then 'Halloween'

        when month = '12'
             and day = '25'
        then 'Christmas Day'

        when month = '01'
             and day_of_week = 'Monday'
             and dow_in_month = 3
             and year::int >= 1983
        then 'Martin Luther King Jr Day'

        when month = '02'
             and day_of_week = 'Monday'
             and dow_in_month = 3
        then 'President''s Day'

        when month = '05'
             and day_of_week = 'Sunday'
             and dow_in_month = 2
        then 'Mother''s Day'

        when month = '06'
             and day_of_week = 'Sunday'
             and dow_in_month = 3
        then 'Father''s Day'

        when month = '09'
             and day_of_week = 'Monday'
             and dow_in_month = 1
        then 'Labor Day'

        when month = '11'
             and day_of_week = 'Thursday'
             and dow_in_month = 4
        then 'Thanksgiving Day'

        when month = '05'
             and day_of_week = 'Monday'
             and date = (
                 select max(b2.date)
                 from base b2
                 where b2.month = '05'
                   and b2.year = base.year
                   and b2.day_of_week = 'Monday'
             )
        then 'Memorial Day'

    end as holiday_text

from base


)

select
b.date_sk,
b.date,
b.day,
b.day_suffix,
b.day_of_week,
b.dow_in_month,
b.day_of_year,
b.week_of_year,
b.week_of_month,
b.month,
b.month_name,
b.quarter,
b.quarter_name,
b.year,
b.standard_date,
h.holiday_text

from base b
left join holidays h
on b.date_sk = h.date_sk
