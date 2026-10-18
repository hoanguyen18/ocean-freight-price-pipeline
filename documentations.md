## Step 1: Initial Setup
### 1. Create a new Git repository: 
- Initialize a new repository (currently set as private in GitHub) 
- Bring the input_files, requirements.txt, README.md, Profile.yml (connect to db) from the case study to the repository
- Add a .gitignore file to exclude unnecessary files (e.g., data files, build artifacts).

### 2. Set up dbt project python virtual environment
- Set up a Python environment for developing: python3 -m venv .dbtenv
- Activate dbt virtual environment: source .dbtenv/bin/activate
- Install dependencies: dbt deps
- Install required versions: pip install -r requirements.txt

### 3. Organizing folders according to the dbt project structure:
Create new folders and files as following:
- Models: to store dbt models (staging, final). In each folder there is sources.yml and other sql file for each model.
- Dbt_project.yml: config of model
- Documentations.md: for documentation
- py_scripts: store python scripts to load the raw data, test raw data and test query.
- example_user_query: store example query for users 

### 4. Testing set up:
command: Dbt debug
command: Dbt –version

## Step 2: Initial Data Load 
- Python py_scripts/load_data.py: create schema and load each CSV file into the raw schema of DuckDB.
- Python load_data/test_load_query.py: test and validate the quality of raw data compared to csv

## Step 3: DBT model
### 1. Under staging, there are 5 tables: each table is sourced, re-named, cast data typed and validated with test in sources.yml
stg_charges.sql
stg_datapoints.sql
stg_exchange_rates.sql
stg_ports.sql
stg_regions.sql

### 2. Under final, there are 2 tables: 
- final_price: Expand the datapoint table from period (valid from to) into daily row, join with charge and exchange rate table to convert charge value. Table final_price has daily USD prices for each contract and lane (combine origin and destination port)
- final_aggregations: Aggregate the average and median daily prices for each lane (origin-destination pair) and equipment type.

### 3. Run dbt test:
command: dbt test
 
## Step 4: Add incremental load
- Add column modified_datetime into rawdata
- Set up incremental load in staging table: datapoint and charges

## Step 5: Add Example User Query
- Add Example User Query (Average container shipping price of equipment type 2 from 
China East Main region to US West Coast region): 
- Command: Python example_user_query/query_1.py

## Step 6: Data Quality Checks and dq_ok Column
- In table final_aggregations, Add logic to check if there are at least 5 different companies and 2 different suppliers for each lane and equipment type.
- Add a dq_ok column to indicate if the data meets the quality requirements.

## Step 7: Documentation
command: dbt docs generate (target/catalog.json file)
