# used to generate seed vocabulary subset
# this script saves vocabulary subset tables from a duckdb as csvs

import duckdb
import os

db_file = os.path.expanduser("./data/synthea_omop_etl.duckdb")
output_dir = os.path.expanduser("./data")
source_schema = "vocab_shard"

conn: duckdb.DuckDBPyConnection = duckdb.connect(db_file)

tables_query = f"""
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = '{source_schema}'
    """
    
# Fetch all table names in the schema
tables = conn.sql(tables_query).fetchall()

# Iterate over each table and export to CSV
for table in tables:
    table_name = table[0]
    csv_path = os.path.join(output_dir, f"{table_name}.csv")
    result = conn.execute(f"COPY {source_schema}.{table_name} TO '{csv_path}' (HEADER, DELIMITER ',');")
    print(f"Table '{table_name}' exported to {csv_path}")