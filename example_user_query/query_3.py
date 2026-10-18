# Query 3: List Lanes with the Highest Average Daily Price
import duckdb

# Connect to your DuckDB database
conn = duckdb.connect('dev.duckdb')

# Query 

query =  """
SELECT 
    lane,
    origin_pid,
    destination_pid,
    AVG(average_daily_price) AS avg_daily_price
FROM 
    main_final.final_aggregations
GROUP BY 
    lane,
    origin_pid,
    destination_pid
ORDER BY 
    avg_daily_price DESC
LIMIT 10;  
"""

# Execute the query and fetch column information
results = conn.execute(query).fetchall()

print(results)
