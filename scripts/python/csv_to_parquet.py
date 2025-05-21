#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = ["duckdb<=1.2.2"]
# ///

"""
Script to convert Synthea or Athena-Vocab csv files to parquet for use with dbt-synthea.

Specific columns will be cast to the correct type ready for use.

Set to convert Synthea files by default, if converting vocab files then pass the -v or --vocab flags.

Output directory can be specified.
If it is not specified then files will be saved insynthea_parquet/vocab_parquet directories in
the same directory as the input directory.
"""

from pathlib import Path

import duckdb
from duckdb import DuckDBPyConnection, DuckDBPyRelation
from dataclasses import dataclass, field
import argparse


@dataclass
class CliArgs:
    """A dataclass to ensure correct typing of command line arguments"""

    input_directory: Path = Path()
    vocab: bool = False
    output_dir: Path | None = None


@dataclass
class BaseInfo:
    """Base class for Info dataclasses."""

    output_dir_name: str
    table_cast_list: list[str]
    column_cast_list: list[str]
    new_type: str
    date_format: str


@dataclass
class VocabInfo(BaseInfo):
    """Dataclass to store info for Vocab -> parquet conversion."""

    output_dir_name: str = "vocab_parquet"
    table_cast_list: list[str] = field(
        default_factory=lambda: [
            "concept",
            "concept_relationship",
            "drug_strength",
        ]
    )
    column_cast_list: list[str] = field(
        default_factory=lambda: ["valid_start_date", "valid_end_date"]
    )
    new_type: str = "DATE"
    date_format: str = "%Y%m%d"


@dataclass
class SyntheaInfo(BaseInfo):
    """Dataclass to store info for Synthea -> parquet conversion."""

    output_dir_name: str = "synthea_parquet"
    table_cast_list: list[str] = field(
        default_factory=lambda: [
            "medications",
            "allergies",
            "conditions",
            "devices",
            "procedures",
        ]
    )
    column_cast_list: list[str] = field(default_factory=lambda: ["CODE"])
    new_type: str = "VARCHAR"
    date_format: str = "%Y-%m-%d"


def parse_cli_arguments() -> CliArgs:
    """
    Parse command line arguments.

    Returns:
         CLIArgs DataClass containing input_directory: Path() vocab: bool and output_dir: Path | None.
    """
    parser: argparse.ArgumentParser = argparse.ArgumentParser(
        description="""Convert Synthea or Athena-Vocab csv files to parquet files, ready to be used with dbt-synthea."""
    )

    _ = parser.add_argument(
        "input_directory",
        type=Path,
        help="Path to the input directory e.g. the synthea csv output.",
    )
    _ = parser.add_argument(
        "--vocab",
        "-v",
        action="store_true",
        help="""Pass --vocab or -v to indicate the input is a directory of vocab files.
        If not passed then the input will be assumed to be a directory of synthea csv files.
        """,
    )
    _ = parser.add_argument(
        "--output_dir",
        "-o",
        type=Path,
        help="""Optional output directory.
        If not passed then an output directory will be created in the same directory as the input directory.
        Default names are synthea_parquet or vocab_parquet.
        """,
    )

    # Store paths in CLIArgs data class.
    args: CliArgs = parser.parse_args(namespace=CliArgs())

    input_dir: Path = args.input_directory.resolve()
    if input_dir.exists():
        args.input_directory = input_dir
    else:
        parser.exit(1, f"{args.input_directory} does not exist.")

    if args.output_dir:
        args.output_dir = args.output_dir.resolve()

    return args


def get_column_type_dict(conn: DuckDBPyConnection, file_path: Path) -> dict[str, str]:
    """Create a dictionary of columns and their types for the given CSV file."""
    csv_file: DuckDBPyRelation = conn.read_csv(str(file_path))
    columns: list[str] = csv_file.columns
    types: list[str] = [str(type) for type in csv_file.types]
    column_type_dict: dict[str, str] = dict(zip(columns, types))
    return column_type_dict


def alter_type_dict(column_dict: dict[str, str], alter_list: list[str], new_type: str):
    """Alter the data types of the specified columns in the column dict"""
    for column in alter_list:
        column_dict[column] = new_type


def create_relation(
    conn: DuckDBPyConnection,
    table_dict: dict[str, str],
    file_path: Path,
    date_format: str,
) -> DuckDBPyRelation:
    """Create a DuckDBPyRelation of the target csv file using using the specified date format."""
    relation: DuckDBPyRelation = conn.read_csv(
        str(file_path), columns=table_dict, date_format=date_format
    )
    return relation


def convert_to_parquet(
    input_directory: Path, vocab: bool = False, output_dir: Path | None = None
) -> None:
    """Main function for the vocab_to_parquet script"""

    # Initialize input specific variables.
    if vocab:
        info: BaseInfo = VocabInfo()
    else:
        info = SyntheaInfo()

    # Create dictionary of csv files.
    file_dict: dict[str, Path] = {
        file.stem.lower(): file
        for file in input_directory.iterdir()
        if file.suffix == ".csv"
    }

    # Create duckdb connection.
    conn: DuckDBPyConnection = duckdb.connect()

    # Create output_directory.
    if output_dir:
        output_directory: Path = output_dir
    else:
        output_directory = input_directory.with_name(info.output_dir_name)
    output_directory.mkdir(exist_ok=True, parents=True)

    # Process tables that need to be altered.
    for table in info.table_cast_list:
        # Initialize file path and output path.
        file_path: Path = file_dict.pop(table)
        output_path: Path = (
            output_directory / file_path.with_suffix(".parquet").name.lower()
        )

        # Create the file column dictionary and alter the specified columns.
        column_type_dict: dict[str, str] = get_column_type_dict(conn, file_path)
        alter_type_dict(column_type_dict, info.column_cast_list, info.new_type)

        # Create relation and convert to parquet.
        rel: DuckDBPyRelation = create_relation(
            conn, column_type_dict, file_path, info.date_format
        )
        _ = rel.to_parquet(str(output_path))

    # Process the remaining files.
    for file_path in file_dict.values():
        output_path = output_directory / file_path.with_suffix(".parquet").name.lower()
        _ = conn.read_csv(str(file_path)).to_parquet(str(output_path))


if __name__ == "__main__":
    args: CliArgs = parse_cli_arguments()
    convert_to_parquet(args.input_directory, args.vocab, args.output_dir)
