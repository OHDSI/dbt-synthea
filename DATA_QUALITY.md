# Data Quality in dbt-synthea

## Overview

In dbt-synthea we aim to demonstrate best practices around proactive monitoring of data quality in the OMOP ETL.  We plan to implement a comprehensive suite of data and unit tests which will help to detect and prevent ETL bugs as well as to characterize the quality of the input Synthea dataset.

## OMOP CDM Quality

The quality of the OMOP CDM output by dbt-synthea is monitored using `dbt test`, as specified in the OMOP model schema files in [models/omop/_models](./models/omop/_models).

To ensure our quality bar and definition of data quality are consistent with the standards enforced by the OHDSI community, we have implemented the [DataQualityDashboard](https://github.com/OHDSI/DataQualityDashboard) quality checks as dbt tests here in the dbt-synthea project.

The OMOP CDM v5.4 specifications and DQD thresholds are parsed directly from their respective GitHub repositories and transformed into yaml using [generate_dbt_yaml.py](./scripts/python/generate_dbt_yaml.py).

Implementation of the DQD checks is still in progress; so far the following checks are included in `dbt test`:

| DQD Check Name                      | Description                                                                                                                                                                                                                  | dbt test implementation                                    |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `cdmTable`                          | Checks for presence of each OMOP CDM table in the database.                                                                                                                                                                  | `dbt_expectations.expect_column_to_exist`                  |
| `cdmField`                          | Checks for presence of each OMOP CDM column in the database.                                                                                                                                                                 | `dbt_expectations.expect_column_to_exist`                  |
| `cdmDatatype`                       | Checks that each column has the correct data type per the OMOP CDM specification.<br>*NB: The DQD implementation of this check only verifies if integer columns contain digits; in dbt all columns’ data types are checked.* | `dbt_expectations.expect_column_values_to_be_in_type_list` |
| `isPrimaryKey`                      | Checks that primary key columns contain only unique values.                                                                                                                                                                  | `unique` (built-in test)                                   |
| `isForeignKey`                      | Checks that each value in a foreign key column exists in the column it references.                                                                                                                                           | `relationships` (built-in test)                            |
| `isRequired`                        | Checks that there are no NULL values in required columns.                                                                                                                                                                    | `not_null` (built-in test)                                 |
| `fkDomain`                          | Checks that each column restricted to concepts from a specific domain only contains concepts from that domain.                                                                                                               | `relationships_where` (built-in test)                      |
| `fkClass`                           | Checks that each column restricted to concepts from a specific class only contains concepts from that class.                                                                                                                 | `relationships_where` (built-in test)                      |
| `measurePersonCompleteness`         | Measures the percent of persons in the database with no rows in a given table. Fails if the percentage exceeds a specific threshold.                                                                             | custom SQL macro                                           |
| `isStandardValidConcept`            | Checks that all non-zero concepts in a standard concept column are standard and valid.                                                                                                                                       | `relationships_where` (built-in test)                      |
| `standardConceptRecordCompleteness` | Measures the percent of records in a table with a value of 0 in a given standard concept column. Fails if the percentage exceeds a specific threshold.                                                                 | custom SQL macro                                           |
| `sourceConceptRecordCompleteness`   | Measures the percent of records in a table with a value of 0 in a given source concept column. Fails if the percentage exceeds a specific threshold.                                                                   | custom SQL macro                                           |

### generate_dbt_yaml.py

The `generate_dbt_yaml` Python script may be used to generate the OMOP model schema files for *any* OMOP ETL implemented using dbt.  It is agnostic to data source and database system.  Given the right combination of input files, it supports OMOP CDM v5.4 (the default) as well as v5.3.

The script can be found at [scripts/python/generate_dbt_yaml.py](./scripts/python/generate_dbt_yaml.py).  Its dependencies include:

* Python >=3.12
  * ruamel-yaml
  * requests
* [dbt_expectations](https://hub.getdbt.com/metaplane/dbt_expectations/latest/)
* The macros stored in [macros/generate_dbt_yaml](./macros/generate_dbt_yaml)
* The generic data tests stored in [tests/generic](./tests/generic)

## Source Data Quality

TODO

## Unit Tests

TODO