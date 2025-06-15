#!/usr/bin/env  -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [ "ruamel-yaml", "requests" ]
# ///

"""
A script to generate dbt YAML files from the OMOP CDM documentation
Requires `ruamel.yaml`, and `requests` to be installed.
If you have uv installed this will be done automatically.

If you make this file executable you should also be able to run it directly using
just the file path/name and the output directory path. e.g:
./generate_dbt_yaml.py <output_dir>

CDM version used is CDM 5.4 which corresponds to the urls referenced below.

This script processes two CSV files:

1. Field-level documentation: Contains details about individual fields in the OMOP CDM tables.
   Default URL: https://raw.githubusercontent.com/OHDSI/CommonDataModel/refs/heads/main/inst/csv/OMOP_CDMv5.4_Field_Level.csv

2. Table-level documentation: Contains descriptions for each OMOP CDM table.
   Default URL: https://raw.githubusercontent.com/OHDSI/CommonDataModel/refs/heads/main/inst/csv/OMOP_CDMv5.4_Table_Level.csv

The script generates dbt YAML files for each table, including field-level details and table descriptions.

If you wish to use a different CDM version, either pass the url in as the --source argument
or download the html file and pass the path in as --source.
For example using wget <url>.
"""

import argparse
import csv
import tempfile
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import ParseResult, urlparse

import requests
from ruamel.yaml import YAML

default_field_source_url = "https://raw.githubusercontent.com/OHDSI/CommonDataModel/refs/heads/main/inst/csv/OMOP_CDMv5.4_Field_Level.csv"
default_table_source_url = "https://raw.githubusercontent.com/OHDSI/CommonDataModel/refs/heads/main/inst/csv/OMOP_CDMv5.4_Table_Level.csv"


@dataclass
class OmopDocumentationContainer:
    """Object to store how the CDM docs express each column"""

    table_name: str
    cdm_field: str
    user_guide: str
    etl_conventions: str
    datatype: str
    required: bool
    primary_key: bool
    foreign_key: bool
    foreign_key_table: str
    foreign_key_domain: str
    foreign_key_class: str


@dataclass
class CliArgs:
    """A dataclass to ensure correct typing of command line arguments"""

    output_dir: Path = Path()
    field_source: str = default_field_source_url
    table_source: str = default_table_source_url
    overwrite: bool = False


def is_url(value: str) -> bool:
    """Check if a string is a url."""
    parsed: ParseResult = urlparse(value)
    return parsed.scheme in {"http", "https"} and bool(parsed.netloc)


def download_url_to_temp_file(url: str, output_dir: Path) -> Path:
    """Download a URL to a .tmp file in the output directory and return the local Path."""
    response = requests.get(url)
    response.raise_for_status()  # raises if e.g. 404 or timeout

    with tempfile.NamedTemporaryFile(
        delete=False, dir=output_dir, suffix=".tmp"
    ) as tmp_file:
        _ = tmp_file.write(response.content)
        return Path(tmp_file.name)


def parse_cli_arguments() -> tuple[Path, str, str]:
    """
    Parse command line arguments.

    Returns:
         CLIArgs DataClass containing cdm_html: str and output_dir: Path().
    """
    parser: argparse.ArgumentParser = argparse.ArgumentParser(
        description="""
        Generate dbt YAML files from the OMOP CDM documentation.
        For example: python generate_dbt_yaml.py cdm54.html ./output
        """
    )

    # Output Directory.
    _ = parser.add_argument(
        "output_dir", type=Path, help="Path to the output directory"
    )

    # Common data model field-level source url.
    _ = parser.add_argument(
        "--field-source",
        "-fs",
        type=str,
        help=f'Path or url to field-level source csv. If none provided defaults to:\n"{default_field_source_url}"',
    )

    # Common data model table-level source url.
    _ = parser.add_argument(
        "--table-source",
        "-ts",
        type=str,
        help=f'Path or url to table-level source csv. If none provided defaults to:\n"{default_table_source_url}"',
    )

    _ = parser.add_argument(
        "--overwrite",
        "-o",
        action="store_true",
        help="""Pass --overwrite or -o to overwrite yaml files in the target directory.
        If not passed then the script will abort if the output directory contains ANY yaml files.""",
    )

    # Store paths in CLIArgs data class.
    args: CliArgs = parser.parse_args(namespace=CliArgs())
    output_dir: Path = args.output_dir.resolve()

    # Check/create output dir. Also includes overwrite check.
    if output_dir.exists():
        if not output_dir.is_dir():
            parser.exit(1, f"{args.output_dir} exists but is not a directory.")
        if not args.overwrite and (
            any(output_dir.glob("*.yaml")) or any(output_dir.glob("*.yml"))
        ):
            parser.exit(
                1,
                f"""Exiting because {args.output_dir} contains .yaml files.
    To overwrite them, pass the --overwrite or -o flag at runtime.""",
            )
    else:
        output_dir.mkdir(parents=True, exist_ok=True)

    return output_dir, args.field_source, args.table_source

def sentinel_to_bool(text: str) -> bool:
    """Convert sentinel strings to boolean"""
    if text == "Yes":
        return True
    else:
        return False


def create_table_dict(
    table: str,
    table_description: str,
    parsed_table: list[OmopDocumentationContainer],
) -> dict[
    str,
    list[dict[str, str | list[dict[str, str | list[str | dict[str, dict[str, str]]]]]]],
]:
    """Create a table dictionary to mimic the dbt yaml format"""
    table_dict: dict[
        str,
        list[
            dict[
                str, str | list[dict[str, str | list[str | dict[str, dict[str, str]]]]]
            ]
        ],
    ] = {
        "models": [
            {
                "name": table.lower(),  # Ensure table name is lowercase in YAML
                "description": table_description,
                "columns": [
                    omop_docs_to_dbt_config(table, doc_container)
                    for doc_container in parsed_table
                ],
            }
        ]
    }
    return table_dict


def omop_docs_to_dbt_config(
    table: str,
    doc_container: OmopDocumentationContainer,
) -> dict[str, str | list[str | dict[str, dict[str, str]]]]:
    """
    Parse an OmopDocumentationContainer object into dbt-config yaml format.

    With an OMOP documentation object, we can use some simple string parsing/heuristic
    to create dbt test configs.
    """
    column_config: dict[str, str | list[str | dict[str, dict[str, str]]]] = {
        "name": doc_container.cdm_field,
        "description": '' if doc_container.user_guide == 'NA' else doc_container.user_guide.replace('\n', ' '),
        "data_type": doc_container.datatype,
    }

    # Create Tests
    tests: list[str | dict[str, dict[str, str]]] = []

    if doc_container.required:
        tests.append("not_null")

    if doc_container.primary_key:
        tests.append("unique")

    if doc_container.foreign_key:
        if (doc_container.foreign_key_domain == "" or doc_container.foreign_key_domain == "NA") and (doc_container.foreign_key_class == "" or doc_container.foreign_key_class == "NA"):
            # Handle simpler cases first, where domain/class is not constrained
            test: dict[str, dict[str, str]] = {
                "relationships": {
                    "to": f"ref('{doc_container.foreign_key_table.lower()}')",
                    "field": f"{doc_container.foreign_key_table.lower()}_id",
                }
            }
            tests.append(test)
        elif doc_container.foreign_key_domain != "" and doc_container.foreign_key_domain != "NA":
            # Add constrained domain tests
            specific_test: dict[str, dict[str, str]] = {
                "dbt_utils.relationships_where": {
                    "to": f"ref('{doc_container.foreign_key_table.lower()}')",
                    "field": f"{doc_container.foreign_key_table.lower()}_id",
                    "from_condition": f"{doc_container.cdm_field} <> 0",
                    "to_condition": f"domain_id = '{doc_container.foreign_key_domain}'",
                }
            }
            tests.append(specific_test)
        else:
            # Add constrained class tests
            specific_test: dict[str, dict[str, str]] = {
                "dbt_utils.relationships_where": {
                    "to": f"ref('{doc_container.foreign_key_table.lower()}')",
                    "field": f"{doc_container.foreign_key_table.lower()}_id",
                    "from_condition": f"{doc_container.cdm_field} <> 0",
                    "to_condition": f"concept_class_id = '{doc_container.foreign_key_class}'",
                }
            }
            tests.append(specific_test)
    
    # Add dbt_expectations tests
    tests.append("dbt_expectations.expect_column_to_exist")
    if doc_container.datatype.lower() == "integer":
        tests.append({
            "dbt_expectations.expect_column_values_to_be_in_type_list": {
                "column_type_list": "{{ get_type_variants(['bigint', 'integer']) }}"
            }
        })
    elif doc_container.datatype.lower() in {"date", "float"}:
        tests.append({
            "dbt_expectations.expect_column_values_to_be_in_type_list": {
                "column_type_list": f"{{{{ get_equivalent_types('{doc_container.datatype.lower()}') }}}}"
            }
        })
    elif doc_container.datatype.lower() == "datetime":
        tests.append({
            "dbt_expectations.expect_column_values_to_be_in_type_list": {
                "column_type_list": "{{ get_equivalent_types('timestamp') }}"
            }
        })
    elif doc_container.datatype.lower().startswith("varchar"):
        tests.append({
            "dbt_expectations.expect_column_values_to_be_in_type_list": {
                "column_type_list": "{{ get_equivalent_types('varchar') }}"
            }
        })

    if doc_container.cdm_field.endswith("_concept_id") and not doc_container.cdm_field.endswith("_source_concept_id"):
        if table.lower() not in {"concept", "concept_ancestor", "concept_relationship", "concept_synonym", "concept_class", "domain", "relationship", "vocabulary"}:
            tests.append({
                "dbt_utils.relationships_where": {
                    "to": "ref('concept')",
                    "field": "concept_id",
                    "from_condition": f"{doc_container.cdm_field} != 0",
                    "to_condition": "standard_concept = 'S' AND invalid_reason IS NULL",
                }
            })

    if tests:
        column_config["tests"] = tests

    return column_config


def parse_csv_file(file_path: Path) -> list[OmopDocumentationContainer]:
    """Parse the CSV file and return a list of OmopDocumentationContainer objects."""
    containers = []
    with open(file_path, mode="r", encoding="utf-8-sig") as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            containers.append(
                OmopDocumentationContainer(
                    table_name=row["cdmTableName"].strip(),
                    cdm_field=row["cdmFieldName"].strip().replace('"', ''),
                    user_guide=row["userGuidance"].strip(),
                    etl_conventions=row["etlConventions"].strip(),
                    datatype=row["cdmDatatype"].strip(),
                    required=sentinel_to_bool(row["isRequired"].strip()),
                    primary_key=sentinel_to_bool(row["isPrimaryKey"].strip()),
                    foreign_key=sentinel_to_bool(row["isForeignKey"].strip()),
                    foreign_key_table=row["fkTableName"].strip(),
                    foreign_key_domain=row["fkDomain"].strip(),
                    foreign_key_class=row["fkClass"].strip(),
                )
            )
    return containers


def parse_table_descriptions(file_path: Path) -> dict[str, str]:
    """Parse the CSV file containing table descriptions and return a dictionary mapping table names to descriptions."""
    table_descriptions = {}
    with open(file_path, mode="r", encoding="utf-8-sig") as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            table_name = row["cdmTableName"].strip().lower()
            description = row["tableDescription"].strip()
            table_descriptions[table_name] = description
    return table_descriptions


def resolve_source_path(source: str, output_dir: Path) -> Path:
    """Resolve the source path by downloading if it's a URL or validating if it's a local file."""
    if is_url(source):
        try:
            return download_url_to_temp_file(source, output_dir)
        except Exception as e:
            raise ValueError(f"Failed to download from {source}: {e}")
    else:
        source_path = Path(source)
        if not source_path.exists():
            raise ValueError(f"Source file does not exist: {source_path}")
        return source_path

def main(
    field_source: str,
    table_source: str,
    output_dir: Path,
) -> None:
    """Main loop to generate dbt YAML files from the OMOP CDM documentation"""
    field_source_path = resolve_source_path(field_source, output_dir)
    containers = parse_csv_file(field_source_path)

    table_source_path = resolve_source_path(table_source, output_dir)
    table_descriptions = parse_table_descriptions(table_source_path)

    tables = {container.table_name for container in containers}

    unwanted_tables: set[str] = {"cohort", "cohort_definition", "cohort_attribute"}
    filtered_table_names: list[str] = [
        table for table in tables if table.lower() not in unwanted_tables
    ]

    print(f" Found {len(tables)} tables in the OMOP CDM documentation, filtered to {len(filtered_table_names)} tables.")

    for table in filtered_table_names:
        table_containers = [c for c in containers if c.table_name == table]
        table_description = table_descriptions.get(table.lower(), '')
        if table_description == 'NA':
            table_description = ''

        table_dict = create_table_dict(table, table_description, table_containers)

        yaml: YAML = YAML()
        yaml.indent(mapping=2, sequence=4, offset=2)  # pyright: ignore[reportUnknownMemberType]
        yaml.width = 100
        yaml.dump(table_dict, open(f"{output_dir}/{table.lower()}.yml", "w"))
        yaml.allow_duplicate_keys

        if field_source_path.suffix == ".tmp" and field_source_path.exists():
            field_source_path.unlink()

        if table_source_path.suffix == ".tmp" and table_source_path.exists():
            table_source_path.unlink()

    print(f" Exported to `{output_dir}`")
    print("  Done!")


if __name__ == "__main__":
    output_dir, field_source, table_source = parse_cli_arguments()
    main(field_source, table_source, output_dir)
