
{{ config(
    materialized='incremental',
    unique_key='d_id'
) }}

with stg_datapoints_1 as (
    select *
    from {{ source('freight', 'datapoints_1') }}
),

stg_datapoints_2 as (
    select *
    from {{ source('freight', 'datapoints_2') }}
),

stg_datapoints_3 as (
    select *
    from {{ source('freight', 'datapoints_3') }}
),

combined_datapoints as (
    select * from stg_datapoints_1
    union all
    select * from stg_datapoints_2
    union all
    select * from stg_datapoints_3
),

stg_datapoint__rename_column as (
    select 
        d_id,
        created as created_date,
        origin_pid,
        destination_pid,
        valid_from,
        valid_to,
        company_id,
        supplier_id,
        equipment_id,
        modified_datetime
    from combined_datapoints
),

stg_datapoint__cast_type as (
    select 
        cast(d_id as int) as d_id,
        cast(created_date as timestamp) as created_date,
        cast(origin_pid as int) as origin_pid,
        cast(destination_pid as int) as destination_pid,
        cast(valid_from as timestamp) as valid_from,
        cast(valid_to as timestamp) as valid_to,
        cast(company_id as int) as company_id,
        cast(supplier_id as int) as supplier_id,
        cast(equipment_id as int) as equipment_id,
        cast(modified_datetime as timestamp) as modified_datetime
    from stg_datapoint__rename_column
)
{% if is_incremental() %}
    ,max_modified_datetime as (
        select max(modified_datetime) as max_modified_datetime
        from {{ this }}
    ),
    
    incremental_data as (
        select 
            nd.*
        from 
            stg_datapoint__cast_type nd
        where
            nd.modified_datetime > (select max_modified_datetime from max_modified_datetime)
    )
{% else %}
    ,incremental_data as (
        select * from stg_datapoint__cast_type
    )
{% endif %}

select 
    id.d_id,
    id.created_date,
    id.origin_pid,
    id.destination_pid,
    id.valid_from,
    id.valid_to,
    id.company_id,
    id.supplier_id,
    id.equipment_id,
    id.modified_datetime
from 
    incremental_data id
