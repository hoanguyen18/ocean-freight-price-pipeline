with stg_ports__source as (
    select *
    from {{ source('freight', 'ports')}}
),

stg_ports__rename_column as (
    select 
        PID as PID,
        code as port_code,
        slug as region_slug,
        name as port_name,
        country as country_name,
        country_code as country_code
    from stg_ports__source
),

stg_ports__cast_type as (
    select 
        cast(PID as int) as PID,
        cast(port_code as string) as port_code,
        cast(region_slug as string) as region_slug,
        cast(port_name as string) as port_name,
        cast(country_name as string) as country_name,
        cast(country_code as string) as country_code
    from stg_ports__rename_column
)

select *
from stg_ports__cast_type
