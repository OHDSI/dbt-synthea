{% macro check_if_exists(database, schema, table) %}

{%- set source_relation = adapter.get_relation(
      database=database,
      schema=schema,
      identifier=table) -%}

{% set table_exists=source_relation is not none  %}

{{ return(table_exists) }}

{% endmacro %}