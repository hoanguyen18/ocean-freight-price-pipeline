with stg_regions__source as (
    select *
    from {{ source('freight', 'regions')}}
),

stg_regions__rename_column as (
    select 
        slug as region_slug,
        name as region_name,
        parent as parent_slug
    from stg_regions__source
),

stg_regions__cast_type as (
    select 
        cast(region_slug as string) as region_slug,
        cast(region_name as string) as region_name,
        cast(parent_slug as string) as parent_slug
    from stg_regions__rename_column
)

select *
from stg_regions__cast_type
