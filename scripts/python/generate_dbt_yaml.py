# A script to generate dbt YAML files from the OMOP CDM documentation
#
# Requires `BeautifulSoup4` and `ruamel.yaml` to be installed
# Get the OMOP CDM documentation with e.g.:
#   `wget https://raw.githubusercontent.com/OHDSI/CommonDataModel/refs/heads/main/docs/cdm54.html`

import argparse
from dataclasses import dataclass
from pathlib import Path

from ruamel.yaml import YAML
from bs4 import BeautifulSoup


@dataclass
class omop_documentation_container:
    cdm_field: str
    user_guide: str
    etl_conventions: str
    datatype: str
    required: bool
    primary_key: bool
    foreign_key: bool
    foreign_key_table: str
    foreign_key_domain: str


def table_handler(table) -> list[omop_documentation_container]:
    """
    Takes a table and returns a list of objects that represent the tables in the table.
    """
    rows = table.find_all("tr")

    return [row_handler(row) for row in rows]


def row_handler(rows) -> omop_documentation_container:
    """
    Take each row from a table and handle it, resulting in a object that can neatly
    store how the CDM docs express each column.
    """
    cells = rows.find_all("td")

    cells = {
        "cdm_field": cells[0].text,
        "user_guide": cells[1].text,
        "etl_conventions": cells[2].text,
        "datatype": cells[3].text,
        "required": cells[4].text,
        "primary_key": cells[5].text,
        "foreign_key": cells[6].text,
        "foreign_key_table": cells[7].text,
        "foreign_key_domain": cells[8].text,
    }

    # Remove dangling whitespace and newlines from parsed HTML
    cells = {k: v.replace("\n", "").strip() for k, v in cells.items()}

    # Handle booleans expressed as text
    cells.update(
        {
            "primary_key": sentinel_to_bool(cells["primary_key"]),
            "required": sentinel_to_bool(cells["required"]),
            "foreign_key": sentinel_to_bool(cells["foreign_key"]),
        }
    )

    return omop_documentation_container(**cells)


def sentinel_to_bool(text) -> bool:
    if text == "Yes":
        return True
    else:
        return False


def extract_table_description(table_handle) -> str:
    description = table_handle.find(
        "p", string="Table Description"
    ).next_sibling.next_sibling.text

    return description.replace("\n", "")


def omop_docs_to_dbt_config(obj: omop_documentation_container) -> dict:
    """
    With an OMOP documentation object, we can use some simple string parsing/heuristic
    to create dbt test configs.
    """
    column_config = {
        "name": obj.cdm_field,
        "description": obj.user_guide,
        "data_type": obj.datatype,
    }

    # == Create Tests ==
    tests: list = []

    if obj.required:
        tests.append("not_null")

    if obj.primary_key:
        tests.append("unique")

    if obj.foreign_key:
        if obj.foreign_key_domain == "":
            # Handle simpler cases first, where a domain is not constrained
            test = {
                "relationships": {
                    "to": f"ref('{obj.foreign_key_table.lower()}')",
                    "field": f"{obj.foreign_key_table.lower()}_id",
                }
            }
            tests.append(test)

        else:
            # Add constrained domain tests
            specific_test = {
                "dbt_utils.relationships_where": {
                    "to": f"ref('{obj.foreign_key_table.lower()}')",
                    "field": f"{obj.foreign_key_table.lower()}_id",
                    "from_condition": f"{obj.cdm_field} <> 0",
                    "to_condition": f"domain_id = '{obj.foreign_key_domain}'",
                }
            }
            tests.append(specific_test)

    if tests:
        column_config["tests"] = tests

    return column_config


def extract_table_names(soup_obj: BeautifulSoup) -> list[str]:
    """
    Dynamically extract table names from the OMOP CDM documentation
    """
    table_names = []

    for div in soup_obj.find_all(
        "div", attrs={"class": "section level3 tabset tabset-pills"}
    ):
        table_names.append(div.find("h3").text)
    return table_names


def main(
    cdm_docs_path: Path,
    output_dir: Path,
) -> None:
    """
    Main loop to generate dbt YAML files from the OMOP CDM documentation
    """
    with open(cdm_docs_path) as file_handle:
        file = file_handle.read()

    soup = BeautifulSoup(file, features="html.parser")

    tables = extract_table_names(soup)

    for table in tables:
        # For each table generate the desired dbt yaml
        # Get desired div with table
        table_handle = soup.find("div", attrs={"id": table})

        tbody_handle = table_handle.find("table").find("tbody")
        parsed_table = table_handler(tbody_handle)
        table_description = extract_table_description(table_handle)

        table_dict = {
            "models": [
                {
                    "name": table,
                    "description": table_description,
                    "columns": [omop_docs_to_dbt_config(obj) for obj in parsed_table],
                }
            ]
        }

        yaml = YAML()
        yaml.indent(mapping=2, sequence=4, offset=2)
        yaml.width = 100
        yaml.dump(table_dict, open(f"{output_dir}/{table}.yml", "w"))


# == Handle arguments ==
# Get cdm54.html from the OMOP CDM documentation, using args
parser = argparse.ArgumentParser(
    description="Generate dbt YAML files from the OMOP CDM documentation. For example: python generate_dbt_yaml.py cdm54.html ./output"
)
parser.add_argument(
    "cdm_html", type=str, help="Path to the OMOP CDM documentation HTML"
)
parser.add_argument("output_dir", type=str, help="Path to the output directory")
args = parser.parse_args()

cdm_docs_path = Path(args.cdm_html)
output_dir = Path(args.output_dir)

if not cdm_docs_path.exists():
    parser.error(f"File {cdm_docs_path} does not exist")

if not output_dir.exists():
    parser.error(f"Directory {output_dir} does not exist")

main(cdm_docs_path, output_dir)
