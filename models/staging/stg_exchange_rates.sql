with stg_exchange_rates__source as (
    select *
    from {{ source('freight', 'exchange_rates')}}
),

stg_exchange_rates__rename_column as
(
  select day as day,
  currency as currency_code,
  rate as exchange_rate
  from stg_exchange_rates__source
),

stg_exchange_rates__cast_type as
(
  select cast(day as datetime) as day,
  cast(currency_code as string) as currency_code,
  cast(exchange_rate as double) as exchange_rate
  from stg_exchange_rates__rename_column
)


select *
from stg_exchange_rates__cast_type
