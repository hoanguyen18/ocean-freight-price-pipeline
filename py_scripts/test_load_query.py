import duckdb

# Connect to your DuckDB database
conn = duckdb.connect('dev.duckdb')
# Query to select table names and their schemas
query = """
SELECT table_schema, table_name 
FROM information_schema.tables
WHERE table_type = 'BASE TABLE';
"""

# Execute the query and fetch all table names
results = conn.execute(query).fetchall()

# Print the table names
print("Tables in the database:")
for result in results:
    schema_name = result[0]
    table_name = result[1]
    print(f"{schema_name}.{table_name}")

# List of tables to test
tables = [
    'charges_1', 'datapoints_1', 'charges_2', 'datapoints_2', 'charges_3', 'datapoints_3', 'exchange_rates', 'ports', 'regions'
]

# Function to run a query and print the result
def run_query_and_print_result(query, description):
    result = conn.execute(query).fetchall()
    print(description)
    for row in result:
        print(row)
    print()

# Test row counts
for table in tables:
    query = f"SELECT COUNT(*) as row_count FROM raw.{table}"
    run_query_and_print_result(query, f"Row count for table 'raw.{table}':")

# Test column counts
for table in tables:
    query = f"SELECT COUNT(*) as column_count FROM pragma_table_info('raw.{table}')"
    run_query_and_print_result(query, f"Column count for table 'raw.{table}':")

# Close the connection
conn.close()