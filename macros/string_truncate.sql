-- macros/string_truncate.sql
{% macro string_truncate(expression, length) %}
  {%- set adapter = target.type -%}
  {% if adapter in ['postgres', 'redshift'] %}
    SUBSTRING({{ expression }} FROM 1 FOR {{ length }})
  {% elif adapter in ['snowflake', 'bigquery', 'databricks', 'mysql', 'sqlserver', 'duckdb'] %}
    SUBSTRING({{ expression }}, 1, {{ length }})
  {% elif adapter in ['sqlite', 'oracle'] %}
    SUBSTR({{ expression }}, 1, {{ length }})
  {% else %}
    {{ exceptions.raise_compiler_error("Unsupported adapter: " ~ adapter) }}
  {% endif %}
{% endmacro %}
