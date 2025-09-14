# [Under developement] dbt-synthea
The purpose of this project is to re-create the Synthea-->OMOP ETL implemented in https://github.com/OHDSI/ETL-Synthea using [dbt](https://github.com/dbt-labs/dbt-core).

The project is currently under development and is not yet ready for production use.

[OHDSI Symposium 2024 Abstract](https://www.ohdsi.org/wp-content/uploads/2024/10/124-Sadowski-dbt-synthea-Abstract-Julien-Nakache.pdf)

## Who Is This Project For?

We built dbt-synthea to demonstrate the power of dbt for building OMOP ETLs.  **ETL developers** will benefit from this project because they can use it as inspiration for their own dbt-based OMOP ETL.  **Analysts** will appreciate the transparency of dbt's SQL-based ETL code and utilize this project to better understand how source data may be mapped into the OMOP CDM.  **Software developers** are welcome to use this project to transform a Synthea data of their choosing into OMOP to use for testing.

...and this is just the beginning!  We hope someday to grow the OHDSI dbt ecosystem to include a generic dbt project template and source-specific macros and models.  Stay tuned and please reach out if you are interested in contributing.

## Developer Setup

Currently this project is set up to run an OMOP ETL into either duckdb or Postgres.  Setup instructions for each are provided below.

By default, the project will source the Synthea and OMOP vocabulary data from seed files stored in this repository.  The seed Synthea dataset is a small dataset of 27 patients and their associated clinical data.  The vocabulary seeds contain a subset of the OMOP vocabulary limited only to the concepts relevant to this specific Synthea dataset.

Users are welcomed, however, to utilize their own Synthea and/or OMOP vocabulary tables as sources.  Instructions for the "BYO data" setup are provided below.

### Prerequisites
- See the top of [this page](https://docs.getdbt.com/docs/core/pip-install) for OS & Python requirements.  (Do NOT install dbt yet - see below for project installation and setup.)
- It is recommended to use [VS Code](https://code.visualstudio.com/) as your IDE for developing this project.  Install the `dbt Power User` extension in VS Code to enjoy a plethora of useful features that make dbt development easier
- This project currently only supports **Synthea v3.0.0**
- Python **3.12.0** is the suggested version of Python for this project.

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
3. Set up your [profiles.yml file](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml).  You can either:
   - Create a file in the `~/.dbt/` directory named `profiles.yml` (if you've already got this directory and file, you can skip this step and add profile block(s) for this project to that file)
   - Create a `profiles.yml` file in the root of the `dbt-synthea` repo folder
   - Create the file wherever you wish, following the guidance [here](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles#advanced-customizing-a-profile-directory)

### DuckDB Setup
 1. In your virtual environment install requirements for duckdb (see [here for contents](./requirements/duckdb.in))
```bash
pip3 install -r requirements/duckdb.txt
pre-commit install
```

 2. Add the following block to your `profiles.yml` file:
```yaml
synthea_omop_etl:
  outputs:
    dev:
      type: duckdb
      path: synthea_omop_etl.duckdb
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
 
 7. **[BYO DATA ONLY]** 

 (a) Optional - Convert csv files to parquet files. This will significantly reduce file size and may make the run process faster.
 If using uv:
```bash
uv run scripts/python/convert_to_parquet.py <path/to/synthea/csvs>
uv run scripts/python/convert_to_parquet.py <path/to/synthea/csvs> --vocab
```

If using pip/python:
```bash
python3 scripts/python/convert_to_parquet.py <path/to/synthea/csvs>
python3 scripts/python/convert_to_parquet.py <path/to/synthea/csvs> --vocab
```

>Note: Pass the --vocab or -v flags when converting the vocabulary tables. There is also an --output or -o argument you can pass followed by the path to the desired output directory. If not passed then by default the parquet file directory will be created in the same directory as the csv file directory.

 (b) Load your Synthea and Vocabulary data into the database by running the following commands (modify the commands as needed to specify the path to the folder storing the Synthea and vocabulary files, respectively).  The vocabulary tables will be created in the target schema specified in your profiles.yml for the profile you are targeting.  The Synthea tables will be created in a schema named "<target schema>_synthea".  **NOTE only Synthea v3.0.0 is supported at this time.**

 If using uv:
``` bash
file_dict=$(uv run scripts/python/get_filepaths.py <path/to/synthea/files>)
dbt run-operation load_data_duckdb --args "{file_dict: $file_dict, vocab_tables: false}"
file_dict=$(uv run scripts/python/get_filepaths.py <path/to/vocab/files>)
dbt run-operation load_data_duckdb --args "{file_dict: $file_dict, vocab_tables: true}"
```

If using pip/python:
``` bash
file_dict=$(python3 scripts/python/get_filepaths.py <path/to/synthea/files>)
dbt run-operation load_data_duckdb --args "{file_dict: $file_dict, vocab_tables: false}"
file_dict=$(python3 scripts/python/get_filepaths.py <path/to/vocab/files>)
dbt run-operation load_data_duckdb --args "{file_dict: $file_dict, vocab_tables: true}"
```

 8. Seed the location mapper:
```bash
dbt seed --select states
```

 9. Build and test the OMOP tables:
```bash
dbt run
dbt test
```

### Postgres Setup
 1. In your virtual environment install requirements for Postgres (see [here for contents](./requirements/postgres.in))
```bash
pip3 install -r requirements/postgres.txt
pre-commit install
```
 2. Set up a local Postgres database with a dedicated schema for developing this project (e.g. `dbt_synthea_dev`)

 3. Add the following block to your `profiles.yml` file:
```yaml
synthea_omop_etl:
  outputs:
    dev:
      dbname: <name of local postgres DB>
      host: <host, e.g. localhost>
      user: <username>
      password: <password>
      port: 5432
      schema: dbt_synthea_dev
      threads: 4 # See https://docs.getdbt.com/docs/running-a-dbt-project/using-threads for more details
      type: postgres
  target: dev
```

 4. Ensure your profile is setup correctly using dbt debug:
```bash
dbt debug
```

 5. Load dbt dependencies:
```bash
dbt deps
```

 6. **If you'd like to run the default ETL using the pre-seeded Synthea dataset,** run `dbt seed` to load the CSVs with the Synthea dataset and vocabulary data. This materializes the seed CSVs as tables in your target schema (vocab) and a _synthea schema (Synthea tables).  **Then, skip to step 10 below.**
```bash
dbt seed
```
 
 7. **If you'd like to run the ETL on your own Synthea dataset,** first toggle the `seed_source` variable in `dbt_project.yml` to `false`. This will tell dbt not to look for the source data in the seed schemas.
 
 8. **[BYO DATA ONLY]** Create the empty vocabulary and Synthea tables by running the following commands.  The vocab tables will be created in a schema named "<target schema>_vocab", and the Synthea tables in a schema named "<target schema>_synthea".
``` bash
dbt run-operation create_source_tables --args "{vocab_tables: true}"
dbt run-operation create_source_tables --args "{vocab_tables: false}"
```

 9. **[BYO DATA ONLY]** Use the technology/package of your choice to load the OMOP vocabulary and raw Synthea files into these newly-created tables. **NOTE only Synthea v3.0.0 is supported at this time.**

 10. Seed the location mapper:
```bash
dbt seed --select states
```

 11. Build and test the OMOP tables:
```bash
dbt run
dbt test
```
