# Query 1: Average container shipping price of equipment type 2 from 
# China East Main region to US West Coast region

import duckdb

# Connect to your DuckDB database
conn = duckdb.connect('dev.duckdb')

# Query to get the average container shipping price of equipment type _2_ from China East Main region to US West Coast region?

query =  """
SELECT f.date, AVG(f.average_daily_price) AS average_price_usd
FROM main_final.final_aggregations f
JOIN main_staging.stg_ports p1 ON f.origin_pid = p1.PID
JOIN main_staging.stg_ports p2 ON f.destination_pid = p2.PID
WHERE p1.region_slug = 'china_east_main'
  AND p2.region_slug = 'us_west_coast'
  AND equipment_id = 2
GROUP BY f.date
ORDER BY f.date
"""

# Execute the query and fetch column information
results = conn.execute(query).fetchall()

print(results)
