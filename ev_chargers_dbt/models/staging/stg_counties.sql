with names as (
    select *, str_split(fylkesnavn, ' - ')[1] as county_name from {{source('map_data', 'counties')}}
)
select 
    fylkesnummer as county_id,
    TRIM(county_name) as county,
    st_transform(geom, 'EPSG:25833', 'EPSG:4326') as geom_wgs84
from names