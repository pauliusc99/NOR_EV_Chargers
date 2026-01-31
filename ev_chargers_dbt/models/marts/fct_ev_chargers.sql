{{ config(materialized='table')}}

select
    nobil.id,
    nobil.name,
    nobil.operator,
    nobil.available_charging_points,
    nobil.created,
    nobil.updated,
    nobil.position,
    counties.county_id,
    counties.county
from {{ref('stg_nobil')}} as nobil
join {{ref('stg_counties')}} as counties
on st_within(nobil.position, counties.geom_wgs84)