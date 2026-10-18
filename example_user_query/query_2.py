# Query 2: Rank the shipping lanes by the number of records with dq_ok = TRUE

import duckdb

# Connect to your DuckDB database
conn = duckdb.connect('dev.duckdb')

# Query 

query =  """
SELECT 
    lane,
    COUNT(*) AS num_dq_ok_records
FROM 
    main_final.final_aggregations
WHERE 
    dq_ok = TRUE
GROUP BY 
    lane,
ORDER BY 
    num_dq_ok_records DESC
Limit 5;
"""

# Execute the query and fetch column information
results = conn.execute(query).fetchall()

print(results)
