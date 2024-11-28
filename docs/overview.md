{% docs __overview__ %}

## dbt-sythnea

dbt-synthea is a project to demonstrate the power of dbt for building OMOP ETLs. Using [Synthea](https://synthetichealth.github.io/synthea/), it is possible to generate a synthetic patient dataset which can be transformed into the OMOP standard.

### Project Structure

dbt uses parameterized SQL files called [“models”](https://docs.getdbt.com/docs/build/models), which are run in a correct order by building a Directed Acyclic Graph (DAG).

The models have been setup with three distinct stages:
 - **Staging**: SQL queries that are 1:1 with the source Synthea and vocabulary tables and are used to adjust data types and column names as needed
 - **Intermediate**: SQL queries used to perform the bulk of the joining and transformation needed to move from source tables into the OMOP CDM, with a focus on joins and transformations which may be reused several times in the final models; for example, source-to-standard concept mappings or modeling of different visit types.
 - **Mart**: SQL queries that are 1:1 with the final OMOP tables.

The data originates from either [seed files](https://github.com/OHDSI/dbt-synthea/tree/main/seeds) or with data loaded into a database system of choice: the [developer setup instructions](https://github.com/OHDSI/dbt-synthea?tab=readme-ov-file#developer-setup) provide more information.

## Navigation
You can use the Project and Database navigation tabs on the left side of the window to explore the models in your project.

### Project Tab
The Project tab mirrors the directory structure of your dbt project. In this tab, you can see all of the models defined in your dbt project, as well as models imported from dbt packages.

### Database Tab
The Database tab also exposes your models, but in a format that looks more like a database explorer. This view shows relations (tables and views) grouped into database schemas. Note that ephemeral models are not shown in this interface, as they do not exist in the database.

### Graph Exploration
You can click the blue icon on the bottom-right corner of the page to view the lineage graph of your models.

On model pages, you'll see the immediate parents and children of the model you're exploring. By clicking the Expand button at the top-right of this lineage pane, you'll be able to see all of the models that are used to build, or are built from, the model you're exploring.

Once expanded, you'll be able to use the --select and --exclude model selection syntax to filter the models in the graph. For more information on model selection, check out the dbt docs.

Note that you can also right-click on models to interactively filter and explore the graph.

## More Information

 - [What is dbt](https://docs.getdbt.com/docs/introduction)?
 - [What is OMOP](https://www.ohdsi.org/data-standardization/)?
 - [What is Synthea](https://synthetichealth.github.io/synthea/)?
 - [Join OHDSI and collaborate](https://www.ohdsi.org/join-the-journey/)
 - [Installation](https://github.com/OHDSI/dbt-synthea?tab=readme-ov-file#developer-setup)
 - [Project Abstract](https://www.ohdsi.org/wp-content/uploads/2024/10/124-Sadowski-dbt-synthea-Abstract-Julien-Nakache.pdf)

![OMOP Logo](assets/OHDSI-logo-with-text-horizontal-colored-white-background.png)

{% enddocs %}