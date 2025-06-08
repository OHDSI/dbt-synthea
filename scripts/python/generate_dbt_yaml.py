#!/usr/bin/env  -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [ "beautifulsoup4", "ruamel-yaml", "requests" ]
# ///

"""
A script to generate dbt YAML files from the OMOP CDM documentation
Requires `BeautifulSoup4`, `ruamel.yaml`, and `requests` to be installed.
If you have uv installed this will be done automatically.

If you make this file executable you should also be able to run it directly using
just the file path/name and the output directory path. e.g:
./generate_dbt_yaml.py <output_dir>

CDM version used is CDM 5.4 which corresponds to the url below.
https://raw.githubusercontent.com/OHDSI/CommonDataModel/refs/heads/main/docs/cdm54.html

If you wish to use a different version, either pass the url in as the --source argument
or download the html file and pass the path in as --source.
For example using wget <url>.
"""

import argparse
import tempfile
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import ParseResult, urlparse

import requests
from bs4 import BeautifulSoup
from bs4._typing import _AtMostOneElement  # pyright: ignore[reportPrivateUsage]
from bs4.element import NavigableString, Tag
from ruamel.yaml import YAML
from ruamel.yaml.comments import CommentedSeq

default_source_url = "https://raw.githubusercontent.com/OHDSI/CommonDataModel/refs/heads/main/docs/cdm54.html"


@dataclass
class OmopDocumentationContainer:
    """Object to store how the CDM docs express each column"""

    cdm_field: str
    user_guide: str
    etl_conventions: str
    datatype: str
    required: bool
    primary_key: bool
    foreign_key: bool
    foreign_key_table: str
    foreign_key_domain: str


@dataclass
class CliArgs:
    """A dataclass to ensure correct typing of command line arguments"""

    output_dir: Path = Path()
    source: str = default_source_url
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


def parse_cli_arguments() -> tuple[Path, Path]:
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

    # Common data model url.
    _ = parser.add_argument(
        "--source",
        "-s",
        type=str,
        help=f'Path or url to source html. If none provided defaults to:\n"{default_source_url}"',
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

    # Check on url.
    if is_url(args.source):
        try:
            source_path: Path = download_url_to_temp_file(args.source, args.output_dir)
        except Exception as e:
            parser.exit(1, f"Failed to download from {args.source}: {e}")
    else:
        source_path = Path(args.source)
        if not source_path.exists():
            parser.exit(1, f"Source file does not exist: {source_path}")

    return source_path, output_dir


def table_handler(table: Tag) -> list[OmopDocumentationContainer]:
    """Take a table and returns a list of objects that represent the tables in the table."""
    rows: list[Tag] = [_ensure_tag(div) for div in table.find_all("tr")]

    return [row_handler(row) for row in rows]


def row_handler(row: Tag) -> OmopDocumentationContainer:
    """
    Parses a row from a CDM documentation table into an OmopDocumentationContainer instance.

    Take each row from a table and handle it, resulting in a object that can neatly
    store how the CDM docs express each column.
    """
    cell_tags: list[Tag] = [_ensure_tag(cell) for cell in row.find_all("td")]

    cells_raw: dict[str, str] = {
        "cdm_field": cell_tags[0].get_text(),
        "user_guide": cell_tags[1].get_text(),
        "etl_conventions": cell_tags[2].get_text(),
        "datatype": cell_tags[3].get_text(),
        "required": cell_tags[4].get_text(),
        "primary_key": cell_tags[5].get_text(),
        "foreign_key": cell_tags[6].get_text(),
        "foreign_key_table": cell_tags[7].get_text(),
        "foreign_key_domain": cell_tags[8].get_text(),
    }

    # Remove dangling whitespace and newlines from parsed HTML
    cells_stripped: dict[str, str] = {
        k: v.replace("\n", "").strip().replace("“", "").replace("”", "") for k, v in cells_raw.items()
    }

    # Convert sentinels to booleans. Assign values to omop_documentation_container DataClass.
    return OmopDocumentationContainer(
        cdm_field=cells_stripped["cdm_field"],
        user_guide=cells_stripped["user_guide"],
        etl_conventions=cells_stripped["etl_conventions"],
        datatype=cells_stripped["datatype"],
        required=sentinel_to_bool(cells_stripped["required"]),
        primary_key=sentinel_to_bool(cells_stripped["primary_key"]),
        foreign_key=sentinel_to_bool(cells_stripped["foreign_key"]),
        foreign_key_table=cells_stripped["foreign_key_table"],
        foreign_key_domain=cells_stripped["foreign_key_domain"],
    )


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
                "name": table,
                "description": table_description,
                "columns": [
                    omop_docs_to_dbt_config(doc_container)
                    for doc_container in parsed_table
                ],
            }
        ]
    }
    return table_dict


def extract_table_description(table_handle: Tag) -> str:
    """Get the table description"""
    sibling_element: _AtMostOneElement = _ensure_tag(
        table_handle.find("p", string="Table Description")
    ).next_sibling
    description_element: _AtMostOneElement = _ensure_navigable_string(
        sibling_element
    ).next_sibling
    description: str = _ensure_tag(description_element).get_text()

    return description.replace("\n", " ")


def omop_docs_to_dbt_config(
    doc_container: OmopDocumentationContainer,
) -> dict[str, str | list[str | dict[str, dict[str, str]]]]:
    """
    Parse an OmopDocumentationContainer object into dbt-config yaml format.

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
        if doc_container.foreign_key_domain == "":
            # Handle simpler cases first, where a domain is not constrained
            test: dict[str, dict[str, str]] = {
                "relationships": {
                    "to": f"ref('{doc_container.foreign_key_table.lower()}')",
                    "field": f"{doc_container.foreign_key_table.lower()}_id",
                }
            }
            tests.append(test)
        else:
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

    if tests:
        column_config["tests"] = tests

    return column_config


def _ensure_tag(element: _AtMostOneElement) -> Tag:
    """
    Ensure that the given element is a BeautifulSoup Tag.

    If the element is not a Tag, raises a ValueError.
    """
    if isinstance(element, Tag):
        return element
    raise ValueError(
        f"No Tag returned from BeautifulSoup query.\nReturn type is {type(element)}"
    )


def _ensure_navigable_string(element: _AtMostOneElement) -> NavigableString:
    """
    Ensure that the given element is a BeautifulSoup NavigableString.

    If the element is not a NavigableString, raises a ValueError.
    """
    if isinstance(element, NavigableString):
        return element
    raise ValueError(
        f"No NavigableString returned from BeautifulSoup query.\nReturn type is {type(element)}"
    )


def extract_omop_table_names(soup_obj: BeautifulSoup) -> list[str]:
    """Dynamically extract table names from the OMOP CDM documentation"""
    headers: list[Tag] = [
        _ensure_tag(div)
        for div in soup_obj.find_all(
            "div", attrs={"class": "section level3 tabset tabset-pills"}
        )
    ]

    table_names: list[str] = []
    for div in headers:
        if div.h3:
            table_names.append(div.h3.get_text())

    # Exclude unwanted tables
    unwanted_tables: set[str] = {"cohort", "cohort_definition"}
    filtered_table_names: list[str] = [
        table for table in table_names if table not in unwanted_tables
    ]
    return filtered_table_names


def main(
    source_path: Path,
    output_dir: Path,
) -> None:
    """Main loop to generate dbt YAML files from the OMOP CDM documentation"""
    with open(source_path) as file_handle:
        file: str = file_handle.read()

    soup: BeautifulSoup = BeautifulSoup(file, features="html.parser")

    tables: list[str] = extract_omop_table_names(soup)
    print(f" Found {len(tables)} tables in the OMOP CDM documentation")

    for table in tables:
        # For each table generate the desired dbt yaml
        # Get desired div with table
        div_handle: Tag = _ensure_tag(soup.find("div", attrs={"id": table}))

        table_handle: Tag = _ensure_tag(div_handle.find("table"))
        tbody_handle: Tag = _ensure_tag(table_handle.find("tbody"))
        parsed_table: list[OmopDocumentationContainer] = table_handler(tbody_handle)

        table_description: str = extract_table_description(div_handle)

        # TODO: Look at turning this structure into a dataclass or pydantic BaseModel class.
        table_dict: dict[
            str,
            list[
                dict[
                    str,
                    str | list[dict[str, str | list[str | dict[str, dict[str, str]]]]],
                ]
            ],
        ] = create_table_dict(table, table_description, parsed_table)

        yaml: YAML = YAML()
        yaml.indent(mapping=2, sequence=4, offset=2)  # pyright: ignore[reportUnknownMemberType]
        yaml.width = 100
        yaml.dump(table_dict, open(f"{output_dir}/{table}.yml", "w"))  # pyright: ignore[reportUnknownMemberType]
        yaml.allow_duplicate_keys

        if source_path.suffix == ".tmp" and source_path.exists():
            source_path.unlink()

    print(f" Exported to `{output_dir}`")
    print("  Done!")


if __name__ == "__main__":
    source, output_dir = parse_cli_arguments()
    main(source, output_dir)
