# [Under developement] dbt-synthea
The purpose of this project is to re-create the Synthea--> OMOP ETL implemented in https://github.com/OHDSI/ETL-Synthea using [dbt](https://github.com/dbt-labs/dbt-core).

The project is currently under development and all documentation is aimed at project contributors.  This project is not yet ready for use.

## Developer Setup

### Prerequisites
- See [here](https://docs.getdbt.com/docs/core/pip-install) for OS & Python requirements.  It is *highly* recommended to install dbt using `pip`, not homebrew, to ensure consistency of setup among developers
- A local Postgres database with a dedicated schema for developing this project (e.g. `dbt_synthea_dev`)
- It is also recommended to use [VS Code](https://code.visualstudio.com/) as your IDE for developing this project.  Install the `dbt Power User` extension in VS Code to enjoy a plethora of useful features that make dbt development easier

### Instructions
 1. Clone this repository to your machine
 2. `cd` into the repo directory and set up a virtual environment per the instructions [here](https://docs.getdbt.com/docs/core/pip-install#using-virtual-environments).  Note that if you're using VS Code, the vscode config in the repo will automatically source the virtualenv each time you open a new terminal in the project
 3. Create a .env file in your repo and add a PYTHONPATH entry for your virtual env (e.g. `PYTHONPATH="~/dbt-synthea/dbt-env/bin/python"`)
 4. In your virtual environment, install dbt-core and the dbt-postgres adapter as follows:
```bash
 pip install dbt-core==1.7.4
 pip install dbt-postgres==1.7.4
```

 5. Set up your [profiles.yml file](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml):
   - Run `touch ~/.dbt/profiles.yml` if you don't already have a profiles.yml file on your machine
   - Add the following block to the file:
```yaml
synthea_omop_etl:
  outputs:
    dev:
      dbname: <name of the local postgres database where you'll be running this project>
      host: localhost
      pass: <postgres user password>
      port: 5432
      schema: <dev schema name for this project>
      threads: 1
      type: postgres
      user: <postgres username>
  target: dev
```

 6. Ensure your profile is setup correctly from the command line:
```bash
$ dbt debug
```

 7. Load the CSVs with the Synthea dataset. This materializes the CSVs as tables in your target schema.
```bash
$ dbt seed
```

 8. Run the models we have so far:
```bash
$ dbt run
```

 9. Test the output of the models:
```bash
$ dbt test
```
