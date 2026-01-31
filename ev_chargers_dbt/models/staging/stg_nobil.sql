-- Usually staging models are stored as views. 
-- Because read_json is slow to read, we choose to save the model as a table
-- for quicker EDA. 
{{config(materialized='table')}}

-- TODO:
-- 1.Extract table from json
-- 2.Convert Position to actual geometry
-- 3.Trim Municipality

-- Part 1
with raw_data as (
    -- Collecting the raw data 
    select * from {{ source('NOBIL_raw', 'NOBIL_data') }}
),
unnested_base as (
    -- The data is nested in the chargestations
    select unnest(chargerstations) as all_data from raw_data
),
extracted_csmd as (
    -- The data is further nested in csmd
    select all_data.csmd as csmd_struct from unnested_base
),
raw_table as (
    -- Now we have extracted the desired table from the json file
    select csmd_struct.* from extracted_csmd
),
-- Part 2
removed_parantheses as (
    select id, trim(regexp_replace(Position, '[()]', ' ', 'g')) as cleaned_position from raw_table
),
split_coords as(
    select id, regexp_split_to_array(cleaned_position, ',') as coords_list from removed_parantheses        
),
coords as (
    select id, st_point(coords_list[1]::double, coords_list[2]::double) as point from split_coords
)
-- Part 3 as part of the final select
select 
    r.id as id,
    r.name as name,
    r.Zipcode as zipcode,
    r.City as city,
    r.Municipality_ID as municipality_id,
    TRIM(r.Municipality) as municipality,
    r.County_ID as county_id,
    r.County as county,
    r.Operator as operator,
    r.Available_charging_points as available_charging_points,
    r.Created as created,
    r.Updated as updated,
    coords.point as position,
from raw_table as r 
join coords
on r.id = coords.id