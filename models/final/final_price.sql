-- Step 1: Expand datapoints date range
with expanded_datapoints as (
    select
        d.d_id,
        d.created_date,
        d.origin_pid,
        d.destination_pid,
        concat(d.origin_pid, '-', d.destination_pid) as lane,
        d.valid_from,
        d.valid_to,
        d.company_id,
        d.supplier_id,
        d.equipment_id,
        d.modified_datetime,
        date
    from {{ ref('stg_datapoint') }} d,
    unnest(generate_series(d.valid_from, d.valid_to, interval '1 day')) as t(date)
),

-- Step 2: Join and convert charges
charges_with_conversion as (
    select
        ed.d_id,
        ed.created_date,
        ed.origin_pid,
        ed.destination_pid,
        ed.lane,
        ed.date,
        ed.company_id,
        ed.supplier_id,
        ed.equipment_id,
        ed.modified_datetime,
        c.currency_code,
        c.charge_value,
        case
            when c.currency_code = 'USD' then c.charge_value
            else c.charge_value / cr.exchange_rate
        end as converted_charge
    from expanded_datapoints ed
    join {{ ref('stg_charges') }} c on ed.d_id = c.d_id
    left join {{ ref('stg_exchange_rates') }} cr on c.currency_code = cr.currency_code and ed.date = cr.day
),

-- Step 3: Aggregate converted charges
final_price as (
    select
        d_id,
        created_date,
        origin_pid,
        destination_pid,
        lane,
        date,
        modified_datetime,
        company_id,
        supplier_id,
        equipment_id,
        sum(converted_charge) as total_charge
    from charges_with_conversion
    group by
        d_id,
        created_date,
        origin_pid,
        destination_pid,
        lane,
        date,
        company_id,
        supplier_id,
        equipment_id,
        modified_datetime
    order by
        d_id,
        date
)

-- Final selection
select *
from final_price
