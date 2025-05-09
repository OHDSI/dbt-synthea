#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [ duckdb ]
# ///

# used to generate seed vocabulary subset
# this script filters the OMOP vocabulary tables to only include concepts found in a CDM
# taken from https://github.com/OHDSI/Tutorial-Hades/blob/main/extras/FilterVocabulary.R

from pathlib import Path
from typing import cast

import duckdb
from duckdb import DuckDBPyConnection, DuckDBPyRelation
from dataclasses import dataclass
import argparse


@dataclass
class CliArgs:
    """A dataclass to ensure correct typing of command line arguments"""

    db_file: Path = Path()
    source_schema: str = ""
    target_schema: str = ""


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


def parse_cli_arguments() -> CliArgs:
    """Parse command line arguments."""
    parser: argparse.ArgumentParser = argparse.ArgumentParser(
        description="""Create a vocab tables for OMOP database filtered to only the needed codes."""
    )

    _ = parser.add_argument(
        "db_file",
        type=Path,
        help="Path to your database file",
    )
    _ = parser.add_argument(
        "source_schema",
        type=str,
        help="Source schema. Example: dbt_synthea_dev_full",
    )
    _ = parser.add_argument(
        "target_schema", type=str, help="Target schema. Example: vocab_shard"
    )

    # Store paths in CLIArgs data class.
    args: CliArgs = parser.parse_args(namespace=CliArgs())

    if args.db_file.resolve().exists():
        if not args.db_file.is_file():
            parser.exit(1, f"{args.db_file} is not a file.")
    else:
        parser.exit(1, f"{args.db_file} does not exist.")

    return args


# TODO: add unit concepts found in drug_strength table.
def collate_concept_ids(conn: DuckDBPyConnection, args: CliArgs) -> None:
    """Read non-vocab tables and collate concept ids into cids table."""
    _ = conn.sql("CREATE TEMPORARY TABLE cids(concept_id INTEGER);")

    for table in non_vocab_tables:
        print(f"Searching table {table}")
        sql_non_vocab: str = f'SELECT "name" FROM pragma_table_info({args.source_schema}.{table}) WHERE "name" LIKE \'%_concept_id\';'
        field_tuples: list[tuple[str]] = cast(
            "list[tuple[str]]", conn.sql(sql_non_vocab).fetchall()
        )
        non_vocab_fields: list[str] = [field for (field,) in field_tuples]
        for field in non_vocab_fields:
            print(f"Searching field {field}")
            concept_ids: DuckDBPyRelation = conn.sql(
                f"SELECT DISTINCT {field} FROM {args.source_schema}.{table};"
            )
            concept_ids.insert_into("cids")


def expand_concept_ids_with_parents(conn: DuckDBPyConnection, args: CliArgs) -> None:
    """Expand concept ids (cids table) with all parents from source_schema"""
    sql_ancestor: str = f"""SELECT DISTINCT ancestor_concept_id 
    FROM {args.source_schema}.concept_ancestor 
    INNER JOIN cids
    ON descendant_concept_id = concept_id;"""
    expanded_ids: DuckDBPyRelation = conn.sql(sql_ancestor)
    expanded_ids.insert_into("cids")


def create_filtered_vocab_tables(conn: DuckDBPyConnection, args: CliArgs) -> None:
    _ = conn.sql(f"CREATE SCHEMA IF NOT EXISTS {args.target_schema}")
    for table in vocab_tables:
        print(f"Filtering table {table}")
        _ = conn.sql(f"DROP TABLE IF EXISTS {args.target_schema}.{table};")
        vocab_fields_tuples: list[tuple[str]] = conn.sql(
            f'SELECT "name" from pragma_table_info({args.source_schema}.{table}) WHERE "name" LIKE \'%concept_id%\';'
        ).fetchall()
        vocab_fields: list[str] = [field for (field,) in vocab_fields_tuples]
        sql_vocab: str = f"CREATE TABLE {args.target_schema}.{table} AS SELECT * FROM {args.source_schema}.{table} WHERE "
        sql_vocab += " AND ".join(
            [f"{field} IN (SELECT concept_id FROM cids)" for field in vocab_fields]
        )
        _ = conn.sql(sql_vocab)


def create_non_filtered_vocab_tables(conn: DuckDBPyConnection, args: CliArgs) -> None:
    for table in vocab_tables_preserve:
        print(f"Migrating table {table}")
        _ = conn.sql(f"DROP TABLE IF EXISTS {args.target_schema}.{table};")
        sql_vocab = f"CREATE TABLE {args.target_schema}.{table} AS SELECT * FROM {args.source_schema}.{table} "
        _ = conn.sql(sql_vocab)


def main() -> None:
    # Parse args.
    args: CliArgs = parse_cli_arguments()

    # Create duckdb connection and generate vocab tables.
    with duckdb.connect(args.db_file) as conn:
        collate_concept_ids(conn, args)
        expand_concept_ids_with_parents(conn, args)
        create_filtered_vocab_tables(conn, args)
        create_non_filtered_vocab_tables(conn, args)


if __name__ == "__main__":
    main()
