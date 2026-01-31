---
title: Electrical Vehicle Chargers in Norway
---

<Details title='Information about the data source'>

The data on electrical vehicle(ev) chargers is collected from [NOBIL](https://info.nobil.no/). It was first established in 2010 for collection and communication about charging stations for chargable vehicles. These type of vehicles also include gas and bio vehicles, though this project only covers electrical vehicles. 
</Details>

Norway is considered the EV capital of the world. As the adoption of electric vehicles continues to grow, so does the demand for infrastructure to support them. This project analyzes and presents the distribution of EV charging infrastructure in Norway at both national and county levels.

# National Overview

```sql big_value_data
with grouped as(
    select
        year(created)as year,
        count(*) as charging_stations,
        sum(available_charging_points) as num_chargers
    from ev_chargers.chargers
    where year(created) in (2024,2025)
    group by year(created)
)
select
    -- 2024 data
    max(case when year = 2024 then charging_stations end) as stations_2024,
    max(case when year = 2025 then charging_stations end) as stations_2025,
    max(case when year = 2024 then num_chargers end) as chargers_2024,
    max(case when year = 2025 then num_chargers end) as chargers_2025,
    chargers_2025-chargers_2024 as diff_chargers,
    stations_2025-stations_2024 as diff_stations
from grouped
```
<div style="text-align: center;">

<BigValue
    data={big_value_data}
    value=stations_2025
    comparison=diff_stations
    title="2025 Charging Stations"
    comparisonTitle="added since last year"
/>

<BigValue
    data={big_value_data}
    value=chargers_2025
    fmt=num1k
    comparison=diff_chargers
    comparisonFmt=num1k
    title="2025 Total Chargers"
    comparisonTitle="added since last year"
/>
</div>

<Details>

Each charging stations has multiple charging points. <br />
Total chargers refers to the sum of these charging points.
</Details>

There has been an exponential build-out of the ev chargers network during the last year. 
Approximately 71% of the chargers in Norway today were built during last year. While the nation began its infrastructure build-out in the 2010s, this recent surge marks a new level of commitment to a fully electric transport sector.

<!-- Plotting the cumulative growth of the number of charging stations in norway --> 
```sql yearly_created
SELECT 
    year(created) AS year, 
    count(*) AS no_built,
    sum(count(*)) OVER (ORDER BY year(created) ASC) AS cum_sum
FROM ev_chargers.chargers
GROUP BY year
having year(created)<2026
ORDER BY year;
```

<LineChart
    data={yearly_created}
    x=year
    y=cum_sum
    markers=true
    markerShape=emptyCircle
    yAxisTitle="No. Charging Stations"
    title="Total EV Charging Stations by Year"
    xAxisTitle=Year
/>

We see a slow and steady growth in the EV charging network, which suddenly spikes in 2025.

## Geographic Visualisation

<ButtonGroup name=map_toggle>
    <ButtonGroupItem valueLabel="Show All" value="all" />
    <ButtonGroupItem valueLabel="Stations Only" value="stations" default />
    <ButtonGroupItem valueLabel="Regions Only" value="regions" />
</ButtonGroup>

<ButtonGroup name=display_statistics_map>
    <ButtonGroupItem valueLabel="Charging Stations" value="charging_stations" default/>
    <ButtonGroupItem valueLabel="Chargers" value="charging_points" />
</ButtonGroup>

```sql playful
select '${inputs.display_statistics}'
```

```sql stations_per_county
select 
    county_id, 
    ANY_VALUE(county) as county,
    case
        when '${inputs.display_statistics_map}'='charging_stations' 
            then count(*)
        when '${inputs.display_statistics_map}'='charging_points' 
            then sum(available_charging_points)
    end as map_values
from chargers
group by county_id
order by map_values desc;
```

```sql chargers_by_size
select
    name,
    lat,
    lon,
    case
        when available_charging_points<10 then 'small'
        when available_charging_points>=10 and available_charging_points<50 then 'medium'
        when available_charging_points>=50 then 'big'
    end as size_station
from chargers
using sample 500
order by 
    case 
        when available_charging_points < 10 then 1
        when available_charging_points < 50 then 2
        else 3
    end
```
{#if inputs.map_toggle==="all"}

<BaseMap startingLat={64.0} startingLong={12.0} startingZoom={4}>
    <Areas 
        data={stations_per_county} 
        geoJsonUrl="/counties.geojson" 
        areaCol=county 
        geoId=county 
        value=map_values
    />

    <Points
        data={chargers_by_size}
        lat=lat
        long=lon
        pointName=name
        value=size_station
        height=200
        colorPalette= {['#3cb44b','#4363d8','#e6194b']}
    />
</BaseMap>

{:else if inputs.map_toggle==="stations"}

<BaseMap startingLat={64.0} startingLong={12.0} startingZoom={4}>
    <Points
        data={chargers_by_size}
        lat=lat
        long=lon
        pointName=name
        value=size_station
        height=200
        colorPalette= {['#3cb44b','#4363d8','#e6194b']}
    />
</BaseMap>

{:else }

<BaseMap startingLat={64.0} startingLong={12.0} startingZoom={4}>
    <Areas 
        data={stations_per_county} 
        geoJsonUrl="/counties.geojson" 
        areaCol=county 
        geoId=county 
        value=map_values
    />
</BaseMap>

{/if}

<Details>

### Map Methodology & Classification
To ensure map readability and performance, the visualization displays a random sample of 500 charging stations. 

A new sample is drawn each time the page is refreshed. Because "Big" charging stations are the rarest in the dataset, their position and count (typically 1–3 stations) will vary most noticeably between reloads.

**Station Categories:**
* **Small:** Fewer than 10 charging points.
* **Medium:** 10 to 49 charging points.
* **Big:** 50 or more charging points.

</Details>

The fewest charging stations are found in Troms and Finnmark, while Oslo, Akershus, and Vestland have the highest concentration of chargers. A distinct difference in strategy is visible: Oslo emphasizes a dense network of smaller, highly accessible stations, whereas Akershus and Vestland focus on fewer, high-capacity hubs that enable greater throughput per location. South of Trondheim, charging infrastructure is heavily concentrated along the coastline. This pattern follows Norway's natural geography, as most urban centers are situated on the coast while the mountainous inland regions remain less developed.

```sql county_charging_points
select 
    county as name, 
    sum(available_charging_points) as value
from ev_chargers.chargers
group by county
```

<BarChart
    data={county_charging_points}
    x=name
    y=value
    swapXY=true
    title="Total Charging Capacity by County"
    yAxisTitle="Number of Charging Points" 
/>


## Charging Points Deployment Trends by Region 

```sql county_names
select 
    distinct(county)
from ev_chargers.chargers
```

<Dropdown
    data={county_names}
    name=county_dropdown
    value=county
    multiple=True
    defaultValue={["Akershus", "Oslo", "Vestland"]}
/>

```sql selected_county_yearly_created
-- 1. Create a list of all years in your range
with year_scaffold as (
    select range as year_created 
    from range(2010, 2026)
),

-- 2. Get the unique list of selected counties
selected_counties as (
    select distinct county 
    from ev_chargers.chargers
    where county in ${inputs.county_dropdown.value}
),

-- 3. Create the "Grid" (Every county x Every year)
grid as (
    select c.county, y.year_created
    from selected_counties c
    cross join year_scaffold y
),

-- 4. Aggregate actual data
actual_counts as (
    select 
        county, 
        year(created) as year_created, 
        sum(available_charging_points) as no_built
    from ev_chargers.chargers
    where county in ${inputs.county_dropdown.value}
    group by all
)

-- 5. Join them and calculate the cumulative sum
select 
    g.county, 
    g.year_created, 
    coalesce(a.no_built, 0) as no_built,
    sum(coalesce(a.no_built, 0)) over (
        partition by g.county 
        order by g.year_created 
        rows between unbounded preceding and current row
    ) as cum_sum
from grid g
left join actual_counts a 
    on g.county = a.county and g.year_created = a.year_created
order by g.county, g.year_created
```

<LineChart
    data={selected_county_yearly_created}
    x=year_created
    y=cum_sum
    series=county
    yAxisTitle="No. Charging Stations"
    title="Expansion of Charging Infrastructure (2010–2025)"
    xAxisTitle=Year
    xFmt=####
    markers=true
    markerShape=emptyCircle
/>
If you compare Oslo, Akershus and Vestland you can see that Vestland has been the most developed county since 2010, and only in 2025 was it passed by Oslo and Akershus.