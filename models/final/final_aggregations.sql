{% set min_companies = var('dq_min_companies', 5) %}
{% set min_suppliers = var('dq_min_suppliers', 2) %}

WITH final_price AS (
    SELECT *
    FROM {{ ref('final_price') }}
),

-- Calculate average and median daily prices per lane and equipment type, with data quality check
final_aggregations AS (
    SELECT
        date,
        lane,
        origin_pid,
        destination_pid,
        equipment_id,
        AVG(total_charge) AS average_daily_price,
        MEDIAN(total_charge) AS median_daily_price,
        COUNT(DISTINCT company_id) AS num_companies,
        COUNT(DISTINCT supplier_id) AS num_suppliers,
        COUNT(DISTINCT company_id) >= {{ min_companies }}
            AND COUNT(DISTINCT supplier_id) >= {{ min_suppliers }} AS dq_ok
    FROM final_price
    GROUP BY
        date,
        lane,
        origin_pid,
        destination_pid,
        equipment_id
)

-- Final selection
SELECT *
FROM final_aggregations
