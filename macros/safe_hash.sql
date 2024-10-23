{%- macro safe_hash(columns) -%}
{% set coalesced_columns = [] %}
{%- for column in columns -%}
  {% do coalesced_columns.append("COALESCE(" ~ column.lower() ~ ", '')") %}
{%- endfor -%}
  MD5(
    {{ dbt.concat(coalesced_columns) }}
  )
{%- endmacro -%}
