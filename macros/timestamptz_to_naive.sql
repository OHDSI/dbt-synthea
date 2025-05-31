{% macro timestamptz_to_naive(column, target_tz=None) %}
  {%- set target_tz = var("dbt_date:time_zone", "UTC") if target_tz is none else target_tz -%}
  {{ adapter.dispatch('timestamptz_to_naive', 'dbt_date')(column, target_tz) }}
{% endmacro %}

{# 
  Default implementation using `AT TIME ZONE`, 
  which works in PostgreSQL, DuckDB, and Redshift. 
  Converts a TIMESTAMPTZ to a naive TIMESTAMP in the target timezone.
#}

{% macro default__timestamptz_to_naive(column, target_tz) %}
  {{ column }} AT TIME ZONE '{{ target_tz }}'
{% endmacro %}

{% macro snowflake__timestamptz_to_naive(column, target_tz) %}
  CONVERT_TIMEZONE('{{ target_tz }}', {{ column }})::timestamp
{% endmacro %}
