{{ config(
    materialized='incremental',
    unique_key='d_id'
) }}

with stg_charges_1 as (
    select *
    from {{ source('freight', 'charges_1') }}
),

stg_charges_2 as (
    select *
    from {{ source('freight', 'charges_2') }}
),

stg_charges_3 as (
    select *
    from {{ source('freight', 'charges_3') }}
),

combined_charges as (
    select * from stg_charges_1
    union all
    select * from stg_charges_2
    union all
    select * from stg_charges_3
),

stg_charges__rename_column as (
    select 
        d_id as d_id,
        currency as currency_code,
        charge_value as charge_value,
        modified_datetime
    from combined_charges
),

stg_charges__cast_type as (
    select 
        cast(d_id as int) as d_id,
        cast(currency_code as string) as currency_code,
        cast(charge_value as double) as charge_value,
        cast(modified_datetime as timestamp) as modified_datetime
    from stg_charges__rename_column
)

{% if is_incremental() %}
    ,max_modified_datetime as (
        select max(modified_datetime) as max_modified_datetime
        from {{ this }}
    )
    ,incremental_data as (
        select 
            nd.*
        from 
            stg_charges__cast_type nd
        where
            nd.modified_datetime > (select max_modified_datetime from max_modified_datetime)
    )
{% else %}
    ,incremental_data as (
        select * from stg_charges__cast_type
    )
{% endif %}

select 
    id.d_id,
    id.currency_code,
    id.charge_value,
    id.modified_datetime
from 
    incremental_data id
