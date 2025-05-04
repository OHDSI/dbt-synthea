# used to generate seed vocabulary subset
# this script filters the OMOP vocabulary tables to only include concepts found in a CDM
# taken from https://github.com/OHDSI/Tutorial-Hades/blob/main/extras/FilterVocabulary.R

from pathlib import Path
from typing import cast

import duckdb

db_file: Path = Path("./data/synthea_omop_etl.duckdb").resolve()
source_schema: str = "dbt_synthea_dev_full"
target_schema: str = "vocab_shard"

# Initialize table lists.
vocab_tables: list[str] = [
    "concept",
    "concept_ancestor",
    "concept_relationship",
    "concept_synonym",
    "drug_strength",
]
vocab_tables_preserve: list[str] = [
    "concept_class",
    "domain",
    "relationship",
    "vocabulary",
]
non_vocab_tables: list[str] = [
    "condition_occurrence",
    "cdm_source",
    "condition_era",
    "cost",
    "death",
    "device_exposure",
    "drug_era",
    "drug_exposure",
    "measurement",
    "observation_period",
    "observation",
    "payer_plan_period",
    "person",
    "procedure_occurrence",
    "provider",
    "visit_detail",
    "visit_occurrence",
]

# Create db connection and temporary cids table.
conn: duckdb.DuckDBPyConnection = duckdb.connect(db_file)
_ = conn.sql("CREATE TEMPORARY TABLE cids(concept_id INTEGER);")

# TODO: add unit concepts found in drug_strength table.

# Read non-vocab tables and collate concept ids into cids table.
for table in non_vocab_tables:
    print(f"Searching table {table}")
    sql_non_vocab = f'SELECT "name" FROM pragma_table_info({source_schema}.{table}) WHERE "name" LIKE \'%_concept_id\';'
    field_tuples: list[tuple[str]] = cast(
        "list[tuple[str]]", conn.sql(sql_non_vocab).fetchall()
    )
    non_vocab_fields: list[str] = [field for (field,) in field_tuples]
    for field in non_vocab_fields:
        print(f"Searching field {field}")
        concept_ids = conn.sql(f"SELECT DISTINCT {field} FROM {source_schema}.{table};")
        concept_ids.insert_into("cids")


# Expand with all parents
sql_ancestor: str = f"""SELECT DISTINCT ancestor_concept_id 
FROM {source_schema}.concept_ancestor 
INNER JOIN cids
  ON descendant_concept_id = concept_id;"""
expanded_ids = conn.sql(sql_ancestor)
expanded_ids.insert_into("cids")

# Filter vocab tables
_ = conn.sql(f"CREATE SCHEMA IF NOT EXISTS {target_schema}")
for table in vocab_tables:
    print(f"Filtering table {table}")
    _ = conn.sql(f"DROP TABLE IF EXISTS {target_schema}.{table};")
    vocab_fields_tuples: list[str] = cast(
        "list[str]",
        conn.sql(
            f'SELECT "name" from pragma_table_info({source_schema}.{table}) WHERE "name" LIKE \'concept_id\';'
        ).fetchall(),
    )
    vocab_fields: list[str] = [field for field in vocab_fields_tuples]
    sql_vocab: str = f"CREATE TABLE {target_schema}.{table} AS SELECT * FROM {source_schema}.{table} WHERE "
    sql_vocab += " AND ".join(
        [f"{field} IN (SELECT concept_id FROM cids)" for field in vocab_fields]
    )
    _ = conn.sql(sql_vocab)

# Create non-filtered vocab tables.
for table in vocab_tables_preserve:
    print(f"Migrating table {table}")
    _ = conn.sql(f"DROP TABLE IF EXISTS {target_schema}.{table};")
    sql_vocab = f"CREATE TABLE {target_schema}.{table} AS SELECT * FROM {source_schema}.{table} "
    _ = conn.sql(sql_vocab)

conn.close()
