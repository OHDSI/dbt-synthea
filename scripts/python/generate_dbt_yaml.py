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

CDM version used is CDM 5.4 which corresponds to the default URLs in the script. 
This is the only CDM version currently supported by this dbt project.
These URLs point to the field-level and table-level CSV files from the OMOP CDM
documentation, and the Data Quality Dashboard (DQD) CSV threshold files.

The script generates dbt YAML files for each OMOP table, including field-level details and table descriptions.

You may optionally download the html files and pass in their paths as arguments.
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

DEFAULT_FIELD_SOURCE_URL = "https://raw.githubusercontent.com/OHDSI/CommonDataModel/refs/heads/main/inst/csv/OMOP_CDMv5.4_Field_Level.csv"
DEFAULT_TABLE_SOURCE_URL = "https://raw.githubusercontent.com/OHDSI/CommonDataModel/refs/heads/main/inst/csv/OMOP_CDMv5.4_Table_Level.csv"
DEFAULT_DATA_QUALITY_FIELD_CONFIG_URL = "https://raw.githubusercontent.com/OHDSI/DataQualityDashboard/refs/heads/main/inst/csv/OMOP_CDMv5.4_Field_Level.csv"
DEFAULT_DATA_QUALITY_TABLE_CONFIG_URL = "https://raw.githubusercontent.com/OHDSI/DataQualityDashboard/refs/heads/main/inst/csv/OMOP_CDMv5.4_Table_Level.csv"

EXCLUDED_TABLES: set[str] = {"cohort", "cohort_definition", "cohort_attribute"}
VOCABULARY_TABLES: set[str] = {"concept", "concept_ancestor", "concept_relationship", "concept_synonym", "concept_class", "domain", "relationship", "vocabulary"}


@dataclass
class OmopFieldDocumentationContainer:
    """Object to store how the CDM docs express each column"""

    table_name: str
    cdm_field: str
    user_guide: str
    datatype: str
    required: bool
    primary_key: bool
    foreign_key: bool
    foreign_key_table: str
    foreign_key_domain: str
    foreign_key_class: str
    standard_concept_record_completeness_threshold: str
    source_concept_record_completeness_threshold: str

@dataclass
class OmopTableDocumentationContainer:
    """Object to store how the CDM docs express each table"""

    table_name: str
    description: str
    person_completeness_threshold: str
    fields: list[OmopFieldDocumentationContainer]

@dataclass
class CliArgs:
    """A dataclass to ensure correct typing of command line arguments"""

    output_dir: Path = Path()
    field_source: str = DEFAULT_FIELD_SOURCE_URL
    table_source: str = DEFAULT_TABLE_SOURCE_URL
    dqd_field_source: str = DEFAULT_DATA_QUALITY_FIELD_CONFIG_URL
    dqd_table_source: str = DEFAULT_DATA_QUALITY_TABLE_CONFIG_URL
    overwrite: bool = False


def is_url(value: str) -> bool:
    """Check if a string is a url."""
    parsed: ParseResult = urlparse(value)
    return parsed.scheme in {"http", "https"} and bool(parsed.netloc)


def download_url_to_temp_file(url: str, output_dir: Path) -> Path:
    """Download a URL to a .tmp file in the output directory and return the local Path."""
    response: requests.Response = requests.get(url)
    response.raise_for_status()  # raises if e.g. 404 or timeout

    with tempfile.NamedTemporaryFile(
        delete=False, dir=output_dir, suffix=".tmp"
    ) as tmp_file:
        _ = tmp_file.write(response.content)
        return Path(tmp_file.name)


def parse_cli_arguments() -> tuple[Path, str, str, str, str]:
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
        help=f'Path or url to field-level source csv. If none provided defaults to:\n"{DEFAULT_FIELD_SOURCE_URL}"',
    )

    # Common data model table-level source url.
    _ = parser.add_argument(
        "--table-source",
        "-ts",
        type=str,
        help=f'Path or url to table-level source csv. If none provided defaults to:\n"{DEFAULT_TABLE_SOURCE_URL}"',
    )

    # DQD field-level source url.
    _ = parser.add_argument(
        "--dqd-source-field",
        "-dsf",
        type=str,
        help=f'Path or url to DQD field-level source csv. If none provided defaults to:\n"{DEFAULT_DATA_QUALITY_FIELD_CONFIG_URL}"',
    )

    # DQD table-level source url.
    _ = parser.add_argument(
        "--dqd-source-table",
        "-dst",
        type=str,
        help=f'Path or url to DQD table-level source csv. If none provided defaults to:\n"{DEFAULT_DATA_QUALITY_TABLE_CONFIG_URL}"',
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

    return output_dir, args.field_source, args.table_source, args.dqd_field_source, args.dqd_table_source


def sentinel_to_bool(text: str) -> bool:
    """Convert sentinel strings to boolean"""
    if text == "Yes":
        return True
    else:
        return False


def generate_table_yaml_params(table_container: OmopTableDocumentationContainer) -> dict[str, str | list[dict[str, dict[str, str]]]]:
    """Generate table-level YAML"""
    table_params: dict[str, str | list[dict[str, dict[str, str]]]] = {
        "name": table_container.table_name,
        "description": table_container.description,
    }

    # Dynamically build the 'tests' section
    tests = []
    if table_container.person_completeness_threshold not in {"NA", ""}:
        tests.append({
            "person_completeness": {
                "threshold": table_container.person_completeness_threshold
            }
        })

    # Add 'tests' only if there are valid tests
    if tests:
        table_params["tests"] = tests

    # Add 'columns' after 'tests'
    table_params["columns"] = [
        omop_docs_to_dbt_config(table_container.table_name, field_container)
        for field_container in table_container.fields
    ]

    return table_params


def create_table_dict(
    table_container: OmopTableDocumentationContainer,
) -> dict[str, list[dict[str, str | list[dict[str, str | list[str | dict[str, dict[str, str]]]]]]]]:
    """Create a table dictionary to mimic the dbt yaml format"""
    table_dict: dict[
        str,
        list[
            dict[
                str, str | list[dict[str, str | list[str | dict[str, dict[str, str]]]]]
            ]
        ],
    ] = {
        "models": [generate_table_yaml_params(table_container)]
    }
    return table_dict


def omop_docs_to_dbt_config(
    table: str,
    doc_container: OmopFieldDocumentationContainer,
) -> dict[str, str | list[str | dict[str, dict[str, str]]]]:
    """
    Parse an OmopFieldDocumentationContainer object into dbt-config yaml format.

    With an OMOP documentation object, we can use some simple string parsing/heuristic
    to create dbt test configs.
    """
    column_config: dict[str, str | list[str | dict[str, dict[str, str]]]] = {
        "name": doc_container.cdm_field,
        "description": doc_container.user_guide,
        "data_type": doc_container.datatype,
    }

    # Create Tests
    tests: list[str | dict[str, dict[str, str]]] = []

    if doc_container.required:
        tests.append("not_null")

    if doc_container.primary_key:
        tests.append("unique")

    if doc_container.foreign_key:
        if doc_container.foreign_key_domain == "" and doc_container.foreign_key_class == "":
            # Handle simpler cases first, where domain/class is not constrained
            test: dict[str, dict[str, str]] = {
                "relationships": {
                    "to": f"ref('{doc_container.foreign_key_table.lower()}')",
                    "field": f"{doc_container.foreign_key_table.lower()}_id",
                }
            }
            tests.append(test)
        else: 
            if doc_container.foreign_key_domain != "":
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
            if doc_container.foreign_key_class != "":
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
    
    if doc_container.standard_concept_record_completeness_threshold != "":
        tests.append({
            "concept_record_completeness": {
                "threshold": doc_container.standard_concept_record_completeness_threshold,
            }
        })
    
    if doc_container.source_concept_record_completeness_threshold != "":
        tests.append({
            "concept_record_completeness": {
                "threshold": doc_container.source_concept_record_completeness_threshold,
            }
        })

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
        if table.lower() not in VOCABULARY_TABLES:
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


def parse_and_create_table_containers(
    cdm_field_file_path: Path,
    dqd_field_file_path: Path,
    cdm_table_file_path: Path,
    dqd_table_file_path: Path,
) -> list[OmopTableDocumentationContainer]:
    """Parse all CSV files and create complete table containers with their fields."""
    fields_by_table: dict[str, list[OmopFieldDocumentationContainer]] = {}
    table_containers: list[OmopTableDocumentationContainer] = []

    field_containers = parse_field_containers(cdm_field_file_path, dqd_field_file_path)
    
    table_info = parse_table_info(cdm_table_file_path, dqd_table_file_path)
    
    for field_container in field_containers:
        table_name = field_container.table_name
        if table_name not in fields_by_table:
            fields_by_table[table_name] = []
        fields_by_table[table_name].append(field_container)
    
    for table_name, table_data in table_info.items():
        if table_name.lower() in EXCLUDED_TABLES:
            continue
            
        table_container = OmopTableDocumentationContainer(
            table_name=table_name,
            description=table_data["description"],
            person_completeness_threshold=table_data["person_completeness_threshold"],
            fields=fields_by_table.get(table_name, [])
        )
        table_containers.append(table_container)
    
    return table_containers


def parse_field_containers(
    cdm_file_path: Path,
    dqd_file_path: Path,
) -> list[OmopFieldDocumentationContainer]:
    """Parse the CDM CSV file and enrich the OmopFieldDocumentationContainer objects with additional info from the DQD file."""
    containers: list[OmopFieldDocumentationContainer] = []
    dqd_mapping: dict[tuple[str, str], dict[str, str]] = {}

    # Parse DQD file
    with open(dqd_file_path, mode="r", encoding="utf-8-sig") as dqd_csv_file:
        dqd_reader = csv.DictReader(dqd_csv_file)
        for row in dqd_reader:
            key = (row["cdmTableName"].strip().lower(), row["cdmFieldName"].strip().lower())
            dqd_mapping[key] = {
                "foreign_key_class": '' if row["fkClass"].strip() == 'NA' else row["fkClass"].strip(),
                "standard_concept_record_completeness_threshold": row["standardConceptRecordCompletenessThreshold"].strip(),
                "source_concept_record_completeness_threshold": row["sourceConceptRecordCompletenessThreshold"].strip(),
            }

    # Parse CDM file and enrich containers
    with open(cdm_file_path, mode="r", encoding="utf-8-sig") as cdm_csv_file:
        cdm_reader = csv.DictReader(cdm_csv_file)
        for row in cdm_reader:
            key = (row["cdmTableName"].strip().lower(), row["cdmFieldName"].strip().lower().replace('"', ''))
            dqd_data = dqd_mapping.get(key, {})
            container = OmopFieldDocumentationContainer(
                **{
                    "table_name": row["cdmTableName"].strip().lower(),
                    "cdm_field": row["cdmFieldName"].strip().lower().replace('"', ''),
                    "user_guide": '' if row["userGuidance"].strip() == 'NA' else row["userGuidance"].strip().replace('\n', ' '),
                    "datatype": row["cdmDatatype"].strip(),
                    "required": sentinel_to_bool(row["isRequired"].strip()),
                    "primary_key": sentinel_to_bool(row["isPrimaryKey"].strip()),
                    "foreign_key": sentinel_to_bool(row["isForeignKey"].strip()),
                    "foreign_key_table": '' if row["fkTableName"].strip() == 'NA' else row["fkTableName"].strip().lower(),
                    "foreign_key_domain": '' if row["fkDomain"].strip() == 'NA' else row["fkDomain"].strip(),
                    "foreign_key_class": dqd_data.get("foreign_key_class", ""),
                    "standard_concept_record_completeness_threshold": dqd_data.get("standard_concept_record_completeness_threshold", ""),
                    "source_concept_record_completeness_threshold": dqd_data.get("source_concept_record_completeness_threshold", ""),
                }
            )
            containers.append(container)
    return containers


def parse_table_info(
    cdm_file_path: Path,
    dqd_file_path: Path,
) -> dict[str, dict[str, str]]:
    """Parse the table-level CSV files and return table information."""
    table_info: dict[str, dict[str, str]] = {}
    dqd_mapping: dict[str, dict[str, str]] = {}

    # Parse DQD file
    with open(dqd_file_path, mode="r", encoding="utf-8-sig") as dqd_csv_file:
        dqd_reader = csv.DictReader(dqd_csv_file)
        for row in dqd_reader:
            key = row["cdmTableName"].strip().lower()
            dqd_mapping[key] = {
                "person_completeness_threshold": row["measurePersonCompletenessThreshold"].strip()
            }
    
    # Parse CDM table file
    with open(cdm_file_path, mode="r", encoding="utf-8-sig") as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            table_name = row["cdmTableName"].strip().lower()
            dqd_data = dqd_mapping.get(table_name, {})
            table_info[table_name] = {
                "description": '' if row["tableDescription"].strip() == 'NA' else row["tableDescription"].strip().replace('\n', ' '),
                "person_completeness_threshold": dqd_data.get("person_completeness_threshold", ""),
            }
    
    return table_info


def resolve_source_path(source: str, output_dir: Path) -> Path:
    """Resolve the source path by downloading if it's a URL or validating if it's a local file."""
    source_path: Path
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


def cleanup_temp_files(*file_paths: Path) -> None:
    """Clean up temporary files."""
    for file_path in file_paths:
        if file_path.suffix == ".tmp" and file_path.exists():
            file_path.unlink()


def main(
    field_source: str,
    table_source: str,
    dqd_field_source: str,
    dqd_table_source: str,
    output_dir: Path,
) -> None:
    """Main loop to generate dbt YAML files from the OMOP CDM documentation"""
    
    # Resolve all source paths
    field_source_path = resolve_source_path(field_source, output_dir)
    dqd_field_source_path = resolve_source_path(dqd_field_source, output_dir)
    table_source_path = resolve_source_path(table_source, output_dir)
    dqd_table_source_path = resolve_source_path(dqd_table_source, output_dir)

    # Parse and create complete table containers
    table_containers = parse_and_create_table_containers(
        cdm_field_file_path=field_source_path,
        dqd_field_file_path=dqd_field_source_path,
        cdm_table_file_path=table_source_path,
        dqd_table_file_path=dqd_table_source_path
    )

    print(f" Found {len(table_containers)} tables in the OMOP CDM documentation after excluding {len(EXCLUDED_TABLES)} excluded tables.")

    # Generate YAML files for each table
    for table_container in table_containers:
        table_dict = create_table_dict(table_container)

        yaml: YAML = YAML()
        yaml.indent(mapping=2, sequence=4, offset=2)  # pyright: ignore[reportUnknownMemberType]
        yaml.width = 100
        yaml.allow_duplicate_keys = True
        
        output_file = output_dir / f"{table_container.table_name.lower()}.yml"
        with open(output_file, "w") as f:
            yaml.dump(table_dict, f)

    # Clean up temporary files
    cleanup_temp_files(
        field_source_path,
        dqd_field_source_path,
        table_source_path,
        dqd_table_source_path
    )

    print(f" Exported to `{output_dir}`")
    print("  Done!")


if __name__ == "__main__":
    output_dir, field_source, table_source, dqd_field_source, dqd_table_source = parse_cli_arguments()
    main(field_source, table_source, dqd_field_source, dqd_table_source, output_dir)