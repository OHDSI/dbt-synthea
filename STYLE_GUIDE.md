# dbt-synthea Style Guide

## Overview

This style guide outlines the standards and best practices for organizing and writing SQL code within our dbt repository. Following these guidelines ensures consistency, readability, and maintainability of our codebase.  

The style guide will evolve over time as we establish ways of working that best suit our team and project requirements.  Feel free to suggest changes in a PR or GitHub issue. 

## Directory Structure

### Directory Layout

```plaintext
dbt_project/
├── macros/
|   ├── _macros.yml
│   ├── macro_1.sql
├── models/
│   ├── staging/
│   │   ├── source_1/
│   │   │   ├── _source_1__models.yml
│   │   │   ├── _source_1__sources.yml
│   │   │   ├── stg_source_1__table_1.sql
│   │   |   ├── stg_source_1__table_2.sql
│   ├── intermediate/
│   │   ├── category_1/
│   │   |   ├── _category_1__models.yml
│   │   |   ├── int_category_1__table_1.sql
│   │   |   ├── int_category_1__table_2.sql
│   ├── marts/
│   │   ├── mart_1/
│   │   │   ├── _mart_1__models.yml
│   │   │   ├── _mart_1__docs.md
│   │   │   ├── model_1.sql
│   │   │   ├── model_2.sql
├── seeds/
│   ├── source_1/
│   |   ├── seed_data.csv
├── tests/
│   ├── test_1.sql
```

### Directory Definitions

- **models**: Contains all model files.
  - **staging**: Models for pulling raw data into the project and applying basic column cleaning rules (renaming, typecasting).
  - **intermediate**: Intermediate transformation layers.
  - **marts**: Business logic and final output models.
- **seeds**: CSV files that are loaded into the data warehouse.
- **macros**: Custom dbt macros.
- **tests**: Custom test queries.

## SQL Styling

### General SQL Conventions

Note that SQLFluff will enforce these conventions automatically if properly installed.  Pre-commit hooks will ensure all newly-committed SQL code is linted and compliant with conventions.

1. **Uppercase SQL Keywords**:
   - Always use all-caps for SQL keywords for better readability.
   ```sql
   SELECT
       column_1
   FROM table_name
   WHERE
       condition;
   ```

2. **Commas Preceding Each Column**:
   - Place a comma at the beginning of each new line for columns in a SELECT statement.
   ```sql
   SELECT
       column_1
     , column_2
     , column_3
   FROM table_name;
   ```

3. **Indentation**:
   - Use 4 spaces for indentation.
   - Align SQL clauses for readability.
   ```sql
   SELECT
       column_1
     , column_2
   FROM table_name
   WHERE
       condition_1
       AND condition_2;
   ```

### Jinja Syntax

1. **Use Double Curly Braces**:
   - Enclose Jinja expressions with double curly braces `{{ }}`.
   - Pad Jinja expressions with one space on either side within the braces
   ```sql
   SELECT
       {{ dbt_utils.current_timestamp() }}
   ```

## Repository Management

### Version Control

- Commit messages should be clear and descriptive.
- Use feature branches for new development and bug fixes.  Give the branch a short, descriptive name prefixed with your name (e.g. `katy__add_person_mart`).

### Documentation

- Update yaml configs whenever you add or change a model.
- Column descriptions only need to be added when the purpose of the column is not evident from its name.

### Testing

- Add tests where appropriate for all new columns and models.
- Place custom tests in the `tests` directory.
- Ensure `dbt run` completes successfully and that all tests pass before opening a pull request.

## Other

For anything not covered here, refer to the dbt best practices [guide](https://docs.getdbt.com/best-practices).