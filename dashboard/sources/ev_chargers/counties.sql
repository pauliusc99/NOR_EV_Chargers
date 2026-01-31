install spatial;
load spatial;
install json;
load json;
select
    county_id,
    county,
    ST_AsGeoJSON(geom_wgs84)::JSON as geometry
from dim_counties
