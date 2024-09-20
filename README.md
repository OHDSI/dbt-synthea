[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/OHDSI/dbt-synthea)

# [Under developement] dbt-synthea

The purpose of this project is to re-create the Synthea-->OMOP ETL implemented in <https://github.com/OHDSI/ETL-Synthea> using [dbt](https://github.com/dbt-labs/dbt-core).

The project is currently under development and is not yet ready for production use.

## Who Is This Project For?

We built dbt-synthea to demonstrate the power of dbt for building OMOP ETLs.  **ETL developers** will benefit from this project because they can use it as inspiration for their own dbt-based OMOP ETL.  **Analysts** will appreciate the transparency of dbt's SQL-based ETL code and utilize this project to better understand how source data may be mapped into the OMOP CDM.  **Software developers** are welcome to use this project to transform a Synthea data of their choosing into OMOP to use for testing.

...and this is just the beginning!  We hope someday to grow the OHDSI dbt ecosystem to include a generic dbt project template and source-specific macros and models.  Stay tuned and please reach out if you are interested in contributing.

## Devcontainer development

The project supports quick experimentation for developers wishing to test the entire dbt workflow on synthetic data using [DuckDb](https://duckdb.org/) through the use of a [dev container](https://containers.dev/).
This also allows the use of a consistent, pre-configured development environment that can also be used in [GitHub Codespaces](https://github.com/features/codespaces).

## Developer Setup

Currently this project is set up to run an OMOP ETL into either duckdb or Postgres.  Setup instructions for each are provided below.

By default, the project will source the Synthea and OMOP vocabulary data from seed files stored in this repository.  The seed Synthea dataset is a small dataset of 27 patients and their associated clinical data.  The vocabulary seeds contain a subset of the OMOP vocabulary limited only to the concepts relevant to this specific Synthea dataset.

Users are welcomed, however, to utilize their own Synthea and/or OMOP vocabulary tables as sources.  Instructions for the "BYO data" setup are provided below.

### Prerequisites

- See the top of [this page](https://docs.getdbt.com/docs/core/pip-install) for OS & Python requirements.  (Do NOT install dbt yet - see below for project installation and setup.)
- It is recommended to use [VS Code](https://code.visualstudio.com/) as your IDE for developing this project.  Install the `dbt Power User` extension in VS Code to enjoy a plethora of useful features that make dbt development easier
- This project currently only supports **Synthea v3.0.0**

### Repo Setup

 1. Clone this repository to your machine
 2. `cd` into the repo directory and set up a virtual environment:

 ```bash
 python3 -m venv dbt-env
 ```

- If you are using VS Code, create a .env file in  the root of your repo workspace (`touch .env`) and add a PYTHONPATH entry for your virtual env (for example, if you cloned your repo in your computer's home directory, the entry will read as: `PYTHONPATH="~/dbt-synthea/dbt-env/bin/python"`)
- Now, in VS Code, once you set this virtualenv as your preferred interpreter for the project, the vscode config in the repo will automatically source this env each time you open a new terminal in the project.  Otherwise, each time you open a new terminal to use dbt for this project, run:

```bash
source dbt-env/bin/activate         # activate the environment for Mac and Linux OR
dbt-env\Scripts\activate            # activate the environment for Windows
```

 4. In your virtual environment, install dbt and other required dependencies as follows:

```bash
pip3 install -r requirements.txt
pre-commit install
```

- This will install dbt-core, the dbt duckdb and postgres adapters, SQLFluff (a SQL linter),  pre-commit (in order to run SQLFluff on all newly-committed code in this repo), duckdb (to support bootstrapping scripts), and various dependencies for the listed packages

### DuckDB Setup

 1. Create a duckdb database in this repo's `data` directory (e.g. `data/synthea_omop_etl.duckdb`)

 2. Set up your [profiles.yml file](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml):

- Create a directory `.dbt` in your root directory if one doesn't exist already, then create a `profiles.yml` file in `.dbt`
- Add the following block to the file:

```yaml
  synthea_omop_etl:
  outputs:
    dev:
      type: duckdb
      path: ./data/synthea_omop_etl.duckdb
      schema: dbt_synthea_dev
  target: dev
```

 3. Ensure your profile is setup correctly using dbt debug:

```bash
dbt debug
```

 4. Load dbt dependencies:

```bash
dbt deps
```

 5. **If you'd like to run the default ETL using the pre-seeded Synthea dataset,** run `dbt seed` to load the CSVs with the Synthea dataset and vocabulary data. This materializes the seed CSVs as tables in your target schema (vocab) and a _synthea schema (Synthea tables).  **Then, skip to step 9 below.**

```bash
dbt seed
```

 6. **If you'd like to run the ETL on your own Synthea dataset,** first toggle the `seed_source` variable in `dbt_project.yml` to `false`. This will tell dbt not to look for the source data in the seed schemas.

 7. **[BYO DATA ONLY]** Load your Synthea and Vocabulary data into the database by running the following commands (modify the commands as needed to specify the path to the folder storing the Synthea and vocabulary csv files, respectively).  The vocabulary tables will be created in the target schema specified in your profiles.yml for the profile you are targeting.  The Synthea tables will be created in a schema named "<target schema>_synthea".  **NOTE only Synthea v3.0.0 is supported at this time.**

``` bash
file_dict=$(python3 scripts/python/get_csv_filepaths.py path/to/synthea/csvs)
dbt run-operation load_data_duckdb --args "{file_dict: $file_dict, vocab_tables: false}"
file_dict=$(python3 scripts/python/get_csv_filepaths.py path/to/vocab/csvs)
dbt run-operation load_data_duckdb --args "{file_dict: $file_dict, vocab_tables: true}"
```

 8. Seed the location mapper and currently unused empty OMOP tables:

```bash
dbt seed --select states omop
```

 9. Build the OMOP tables:

```bash
dbt run
```

 10. Run tests:

```bash
dbt test
```

### Postgres Setup

 1. Set up a local Postgres database with a dedicated schema for developing this project (e.g. `dbt_synthea_dev`)

 2. Set up your [profiles.yml file](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml):

- Create a directory `.dbt` in your root directory if one doesn't exist already, then create a `profiles.yml` file in `.dbt`
- Add the following block to the file:

```yaml
  synthea_omop_etl:
  outputs:
    dev:
      dbname: <name of local postgres DB>
      host: <host, e.g. localhost>
      pass: <password>
      port: 5432
      schema: dbt_synthea_dev
      threads: 1
      type: postgres
      user: <username>
  target: dev
```

 3. Ensure your profile is setup correctly using dbt debug:

```bash
dbt debug
```

 4. Load dbt dependencies:

```bash
dbt deps
```

 5. **If you'd like to run the default ETL using the pre-seeded Synthea dataset,** run `dbt seed` to load the CSVs with the Synthea dataset and vocabulary data. This materializes the seed CSVs as tables in your target schema (vocab) and a _synthea schema (Synthea tables).  **Then, skip to step 10 below.**

```bash
dbt seed
```

 6. **If you'd like to run the ETL on your own Synthea dataset,** first toggle the `seed_source` variable in `dbt_project.yml` to `false`. This will tell dbt not to look for the source data in the seed schemas.

 7. **[BYO DATA ONLY]** Create the empty vocabulary and Synthea tables by running the following commands.  The vocabulary tables will be created in the target schema specified in your profiles.yml for the profile you are targeting.  The Synthea tables will be created in a schema named "<target schema>_synthea".

``` bash
dbt run-operation create_vocab_tables
dbt run-operation create_synthea_tables
```

 8. **[BYO DATA ONLY]** Use the technology/package of your choice to load the OMOP vocabulary and raw Synthea files into these newly-created tables. **NOTE only Synthea v3.0.0 is supported at this time.**

 9. Seed the location mapper and currently unused empty OMOP tables:

```bash
dbt seed --select states omop
```

 10. Build the OMOP tables:

```bash
dbt run
```

 11. Run tests:

```bash
dbt test
```
