-- This macro returns a list of equivalent data types for a given standard type
{% macro get_equivalent_types(standard_type) %}
  
  {% set type_mappings = {
    'varchar': {
      'postgres': ['character varying', 'varchar', 'text'],
      'snowflake': ['string', 'text', 'nvarchar', 'nvarchar2', 'char varying', 'nchar varying'],
      'duckdb': ['varchar', 'char', 'bpchar', 'text', 'string']
    },
    'integer': {
      'postgres': ['integer', 'int4', 'int'],
      'snowflake': ['number', 'int', 'integer'],
      'duckdb': ['integer', 'int4', 'int', 'signed']
    },
    'bigint': {
      'postgres': ['bigint', 'int8'],
      'snowflake': ['number', 'int', 'integer', 'bigint'],
      'duckdb': ['bigint', 'int8', 'long']
    },
    'float': {
      'postgres': ['real', 'float', 'float4', 'double precision', 'float8'],
      'snowflake': ['float', 'float4', 'float8', 'double', 'double precision', 'real'],
      'duckdb': ['real', 'float', 'float4', 'double', 'float8']
    },
    'boolean': {
      'postgres': ['boolean'],
      'snowflake': ['boolean'],
      'duckdb': ['boolean', 'bool']
    },
    'timestamp': {
      'postgres': ['timestamp without time zone', 'timestamp'],
      'snowflake': ['timestamp_ntz', 'timestampntz', 'datetime', 'timestamp without time zone'],
      'duckdb': ['timestamp without time zone', 'timestamp', 'datetime']
    },
    'timestamptz': {
      'postgres': ['timestamptz', 'timestamp with time zone'],
      'snowflake': ['timestamp_tz', 'timestamp with time zone', 'timestamptz'],
      'duckdb': ['timestamptz', 'timestamp with time zone']
    },
    'date': {
      'postgres': ['date'],
      'snowflake': ['date'],
      'duckdb': ['date']
    }
  } %}

  {% set current_adapter = adapter.type() %}
  
  {% if standard_type in type_mappings %}
    {% if current_adapter in type_mappings[standard_type] %}
      {% set raw_types = type_mappings[standard_type][current_adapter] %}
      {% set normalized_types = [] %}
      
      {% for db_type in raw_types %}
        {% set normalized_type = normalize_parameterized_type(db_type) %}
        {% do normalized_types.append(normalized_type) %}
      {% endfor %}
      
      {{ return(normalized_types | unique | list) }}
    {% else %}
      {# Fallback to the standard type if adapter not found #}
      {% set normalized_standard = normalize_parameterized_type(api.Column.translate_type(standard_type)) %}
      {{ return([normalized_standard]) }}
    {% endif %}
  {% else %}
    {# Return the normalized original type if not in our mapping #}
    {% set normalized_standard = normalize_parameterized_type(api.Column.translate_type(standard_type)) %}
    {{ return([normalized_standard]) }}
  {% endif %}

{% endmacro %}


-- Macro to get all equivalent types for a list of standard types
{% macro get_type_variants(standard_types) %}
  {% set all_variants = [] %}
  
  {% for standard_type in standard_types %}
    {% set variants = get_equivalent_types(standard_type) %}
    {% for variant in variants %}
      {% do all_variants.append(variant) %}
    {% endfor %}
  {% endfor %}
  
  {{ return(all_variants | unique | list) }}
{% endmacro %}


-- Macro to handle parameterized types (like varchar(255), decimal(10,2))
{% macro normalize_parameterized_type(db_type) %}
  {% set base_type = db_type.split('(')[0] | trim %}
  {{ return(base_type) }}
{% endmacro %}
