-- Asserts whether the counties and county_id in nobil data 
-- match the counties definition from the Kartverket data
{{ config(severity='warn', store_failures=true) }}

select nobil.id, nobil.name, nobil.county, counties.county, ST_AsText(nobil.position)
from {{ref('stg_nobil')}} as nobil
join {{ref('stg_counties')}} as counties
on st_within(nobil.position, counties.geom_wgs84)
where nobil.county_id != counties.county_id