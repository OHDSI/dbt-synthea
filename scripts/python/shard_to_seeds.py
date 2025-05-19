#!/usr/bin/env  -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [ duckdb ]
# ///

# used to generate seed vocabulary subset
# this script saves vocabulary subset tables from a duckdb as csvs

import argparse
from dataclasses import dataclass
from pathlib import Path
from typing import cast

import duckdb

@dataclass
class CliArgs:
    """A dataclass to ensure correct typing of command line arguments"""

    db_file: Path = Path()
    output_dir: Path = Path()
    source_schema: str = "vocab_shard"
    overwrite: bool = False

def parse_cli_arguments() -> tuple[Path, Path]:
    """
    Parse command line arguments.

    Returns:
         CLIArgs DataClass containing cdm_html: str and output_dir: Path().
    """
    parser: argparse.ArgumentParser = argparse.ArgumentParser(
        description="""
        Export vocabulary shard tables to csvs to use as dbt seeds.
        For example: python shard_to_seeds.py synthea_omop_etl.duckdb ./data
        """
    )

    # duckdb database file.
    _ = parser.add_argument(
        "db_file", type=Path, help="Path to the duckdb database where the vocabulary shard is stored"
    )

    # Output Directory.
    _ = parser.add_argument(
        "output_dir", type=Path, help="Path to the output directory"
    )

    # Source schema.
    _ = parser.add_argument(
        "source_schema", type=str, help="Name of schema to export from."
    )

    _ = parser.add_argument(
        "--overwrite",
        "-o",
        action="store_true",
        help="""Pass --overwrite or -o to overwrite csv files in the target directory.
        If not passed then the script will abort if the output directory contains ANY csv files.""",
    )

    # Store paths in CLIArgs data class.
    args: CliArgs = parser.parse_args(namespace=CliArgs())
    output_dir: Path = args.output_dir.resolve()
    db_file: Path = args.db_file.resolve()
    source_schema: str = args.source_schema

    # Check/create output dir. Also includes overwrite check.
    if output_dir.exists():
        if not output_dir.is_dir():
            parser.exit(1, f"{args.output_dir} exists but is not a directory.")
        if not args.overwrite and (
            any(output_dir.glob("*.csv"))
        ):
            parser.exit(
                1,
                f"""Exiting because {args.output_dir} contains .csv files.
    To overwrite them, pass the --overwrite or -o flag at runtime.""",
            )
    else:
        output_dir.mkdir(parents=True, exist_ok=True)

    # Check on url.
    db_file = Path(args.db_file)
    if not db_file.exists():
        parser.exit(1, f"Source database does not exist: {db_file}")   

    return db_file, output_dir, source_schema

def main(
    db_file: Path,
    output_dir: Path,
    source_schema: str,
) -> None:
    """Main function to export vocabulary shard tables from a duckdb database to csv files."""
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
    
    print(f" Exported all to `{output_dir}`")
    print("  Done!")

if __name__ == "__main__":
    db_file, output_dir, source_schema = parse_cli_arguments()
    main(db_file, output_dir, source_schema)
