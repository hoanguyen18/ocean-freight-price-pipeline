import duckdb
from datetime import datetime

# Connect to DuckDB (this will create a new DuckDB database file)
conn = duckdb.connect('dev.duckdb')

# Create schemas
conn.execute("CREATE SCHEMA IF NOT EXISTS raw")
conn.execute("CREATE SCHEMA IF NOT EXISTS staging")
conn.execute("CREATE SCHEMA IF NOT EXISTS final")

# Dictionary mapping table names to CSV file paths
csv_files = {
    'charges_1': 'input_files/DE_casestudy_charges_1.csv',
    'datapoints_1': 'input_files/DE_casestudy_datapoints_1.csv',
    'charges_2': 'input_files/DE_casestudy_charges_2.csv',
    'datapoints_2': 'input_files/DE_casestudy_datapoints_2.csv',
    'charges_3': 'input_files/DE_casestudy_charges_3.csv',
    'datapoints_3': 'input_files/DE_casestudy_datapoints_3.csv',
    'exchange_rates': 'input_files/DE_casestudy_exchange_rates.csv',
    'ports': 'input_files/DE_casestudy_ports.csv',
    'regions': 'input_files/DE_casestudy_regions.csv',
}

# Get the current timestamp
current_timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

# Iterate over the dictionary and create tables for each CSV file in the 'raw' schema
for table_name, csv_file_path in csv_files.items():
    conn.execute(f"""
        CREATE OR REPLACE TABLE raw.{table_name} AS
        SELECT *, '{current_timestamp}' AS modified_datetime FROM read_csv_auto('{csv_file_path}')
    """)
    print(f"Table 'raw.{table_name}' created or replaced successfully.")

# Query to verify the data has been loaded for one table (e.g., 'ports')
result = conn.execute("SELECT * FROM raw.ports").fetchall()

# Print the result to verify
print("Records from 'raw.ports':")
for row in result:
    print(row)

# Close the connection
conn.close()
