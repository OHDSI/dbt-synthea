#!/usr/bin/env  -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [ duckdb ]
# ///

# used to generate seed vocabulary subset
# this script saves vocabulary subset tables from a duckdb as csvs

from pathlib import Path
from typing import cast

import duckdb

db_file: Path = Path("./data/synthea_omop_etl.duckdb").resolve()
output_dir: Path = Path("./data").resolve()
source_schema: str = "vocab_shard"

conn: duckdb.DuckDBPyConnection = duckdb.connect(db_file)

tables_query: str = f"""
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = '{source_schema}'
    """

# Fetch all table names in schema. Cast as strings for type safety.
raw_rows: list[tuple[str]] = cast(list[tuple[str]], conn.sql(tables_query).fetchall())

# From the list of table names create a list of tuples containing table_name and csv_path.
tables_names_and_paths: list[tuple[str, Path]] = [
    (name, output_dir / f"{name}.csv") for (name,) in raw_rows
]

# Iterate over each table and export to CSV.
for table_name, csv_path in tables_names_and_paths:
    result = conn.execute(
        f"COPY {source_schema}.{table_name} TO '{csv_path}' (HEADER, DELIMITER ',');"
    )
    print(f"Table '{table_name}' exported to {csv_path}")
