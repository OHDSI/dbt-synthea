{% docs __overview__ %}

## dbt-sythnea

dbt-synthea is a project to demonstrate the power of dbt for building OMOP ETLs. Using [Synthea](https://synthetichealth.github.io/synthea/), it is possible to generate a synthetic patient data which can be transformed into the OMOP standard.

### Project Structure

dbt uses parameterized SQL files called [“models”](https://docs.getdbt.com/docs/build/models), which are run in a correct order by building a Directed Acyclic Graph (DAG).

The models have been setup with three distinct stages:
 - **Staging**: SQL queries that are 1:1 with the source Synthea and vocabulary tables and are used to adjust data types and column names as needed
 - **Intermediate**: SQL queries used to perform the bulk of the joining and transformation needed to move from source tables into the OMOP CDM, with a focus on joins and transformations which may be reused several times in the final models; for example, source-to-standard concept mappings or modeling of different visit types.
 - **Mart**: SQL queries that are 1:1 with the final OMOP tables.

### Exploring the Project

The Project and Database tab on the left can be used to explore the models and the structure of the project.

The graph or lineage of the project can be explored by clicking on the blue button on the bottom right of the screen. The `--select` or `--exclude` options can be used to filter the models that are currently in view. For example, try filtering on `--select` with the query `+omop`.

## More Information

 - [What is dbt](https://docs.getdbt.com/docs/introduction)?
 - [What is OMOP](https://www.ohdsi.org/data-standardization/)?
 - [What is Synthea](https://synthetichealth.github.io/synthea/)?
 - [Join OHDSI and collaborate](https://www.ohdsi.org/join-the-journey/)
 - [Installation](https://github.com/OHDSI/dbt-synthea?tab=readme-ov-file#developer-setup)
 - [Project Abstract](https://www.ohdsi.org/wp-content/uploads/2024/10/124-Sadowski-dbt-synthea-Abstract-Julien-Nakache.pdf)

![OMOP Logo](assets/OHDSI-logo-with-text-horizontal-colored-white-background.png)

{% enddocs %}