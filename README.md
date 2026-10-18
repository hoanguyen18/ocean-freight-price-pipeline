# Ocean Freight Price Pipeline with dbt + DuckDB

A data pipeline that turns raw shipping contracts, charges in many currencies, and exchange rates into clean USD price aggregates per shipping lane, with incremental loading and a built-in data quality flag.

**Tech stack:** Python · DuckDB · dbt · SQL

## The problem

Each shipping contract has a validity period and several charges in different currencies. Data users want to answer questions like *"What is the average price to ship container type 2 from China East to the US West Coast?"* To get there, the pipeline has to:

1. Expand each contract into one row per valid day
2. Convert every charge to USD using that day's exchange rate
3. Aggregate daily prices per lane (origin → destination) and container type
4. Pick up new contract batches without reprocessing everything
5. Flag prices that come from too few companies or suppliers to be reliable

## Architecture

```
CSV files ──► raw (DuckDB) ──► staging (dbt) ──► final (dbt) ──► example user queries
             Python loader     clean, cast,      prices +
                               test, incremental aggregations
```

| Layer | Models | What happens |
|---|---|---|
| `raw` | ports, regions, exchange_rates, datapoints_*, charges_* | CSVs loaded unchanged by [`py_scripts/load_data.py`](py_scripts/load_data.py), with a load timestamp |
| `staging` | `stg_ports`, `stg_regions`, `stg_exchange_rates`, `stg_datapoint`, `stg_charges` | Renaming, type casting, uniqueness tests. Contracts and charges load **incrementally** |
| `final` | `final_price` | Contracts expanded to daily rows; each charge converted to USD with the matching day's rate and summed per contract |
| `final` | `final_aggregations` | Average and median USD price per **day, lane and container type**, plus company/supplier counts and a `dq_ok` flag |

## Highlights

- **Daily currency conversion:** `generate_series` expands each contract's validity window into daily rows, and each day joins to its own exchange rate
- **Incremental loads:** new contract batches are merged on `d_id`, so each update processes only new data
- **Data quality flag:** `dq_ok = TRUE` only when a lane has at least 5 distinct companies and 2 distinct suppliers on that day, so users can hide prices that rest on too little data. The thresholds are dbt variables, so they can be raised without changing SQL:
  `dbt build --profiles-dir . --vars '{dq_min_companies: 10, dq_min_suppliers: 3}'`
- **Validation:** Python scripts check row and column counts in the raw tables after each load; dbt tests enforce unique contract IDs
- **Self-service examples:** ready-to-run queries in [`example_user_query`](example_user_query)

## How to run

```bash
python3 -m venv .dbtenv && source .dbtenv/bin/activate
pip install -r requirements.txt
python py_scripts/load_data.py      # load CSVs into DuckDB raw schema
dbt build --profiles-dir .          # build models + run tests
python example_user_query/query_1.py
```

Step-by-step notes are in [`documentations.md`](documentations.md).

## Context

Built as a take-home case for a data engineering role, using a small randomized sample of shipping-contract data.

---

**Hoa Nguyen**, Data Analyst / Analytics Engineer · dbt · SQL · BigQuery · Snowflake · Power BI
