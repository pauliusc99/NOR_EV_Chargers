{{ config(materialized='table')}}

from {{ref('stg_counties')}}