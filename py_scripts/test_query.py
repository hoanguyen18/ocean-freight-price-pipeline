import duckdb

# Connect to your DuckDB database
conn = duckdb.connect('dev.duckdb')

# Query to get column names of the table
query =  """
SELECT *
FROM main_staging.stg_exchange_rates;
"""

# Execute the query and fetch column information
results = conn.execute(query).fetchall()

print(results)
