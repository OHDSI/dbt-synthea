# A script to generate dbt YAML files from the OMOP CDM documentation
#
# Requires `BeautifulSoup4` and `PyYAML` to be installed
# Get the OMOP CDM documentation with:
#   `wget https://raw.githubusercontent.com/OHDSI/CommonDataModel/refs/heads/main/docs/cdm54.html`

import argparse
from dataclasses import dataclass
from pathlib import Path

import yaml
from bs4 import BeautifulSoup

TABLES = [
    "observation_period",
    "visit_occurrence",
    "visit_detail",
    "condition_occurrence",
    "drug_exposure",
    "procedure_occurrence",
    "device_exposure",
    "measurement",
    "observation",
    "death",
    "note",
    "note_nlp",
    "specimen",
    "fact_relationship",
    "location",
    "care_site",
    "provider",
    "payer_plan_period",
    "cost",
    "drug_era",
    "dose_era",
    "condition_era",
    "episode",
    "episode_event",
    "metadata",
    "cdm_source",
    "concept",
    "vocabulary",
    "domain",
    "concept_class",
    "concept_relationship",
    "relationship",
    "concept_synonym",
    "concept_ancestor",
    "source_to_concept_map",
    "drug_strength",
    "cohort",
    "cohort_definition",
]


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


def table_handler(table) -> list:
    """
    Takes a table and returns a list of rows to then be handled
    """
    rows = table.find_all("tr")

    return [row for row in rows]


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


def sentinel_to_bool(text):
    if text == "Yes":
        return True
    else:
        return False


def omop_docs_to_dbt_config(obj: omop_documentation_container):
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


def main(
    cdm_docs_path: Path,
    output_dir: Path,
):
    """
    Main loop to generate dbt YAML files from the OMOP CDM documentation
    """
    with open(cdm_docs_path) as file_handle:
        file = file_handle.read()

    soup = BeautifulSoup(file, features="html.parser")

    for table in TABLES:
        # For each table generate the desired dbt yaml

        # Get desired div with table
        table_handle = soup.find("div", attrs={"id": table})
        tbody_handle = table_handle.find("table").find("tbody")
        parsed_table = table_handler(tbody_handle)

        table_dict = {
            "models": [
                {
                    "name": table,
                    "columns": [omop_docs_to_dbt_config(obj) for obj in parsed_table],
                }
            ]
        }
        # Output YAML for dbt, do not alphabetically sort keys so the names and documentation
        # will be output in our desired order.
        yaml.dump(table_dict, open(f"{output_dir}/{table}.yml", "w"), sort_keys=False)


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

cdm_docs_path.exists() or parser.error(f"File {cdm_docs_path} does not exist")
output_dir.exists() or parser.error(f"Directory {output_dir} does not exist")

main(cdm_docs_path, output_dir)
