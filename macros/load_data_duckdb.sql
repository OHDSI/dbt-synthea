{% macro load_data_duckdb(file_dict, vocab_tables) %}
{% if vocab_tables %}
    {% set target_schema = target.schema %}
  {% else %}
{% set target_schema = target.schema ~ '_synthea' %}
{% endif %}

{% set first_key, first_val = (file_dict | dictsort | first) %}
{% set parquet = first_val.endswith(".parquet") %}
{% set csv = first_val.endswith(".csv") %}

{% do run_query("CREATE SCHEMA IF NOT EXISTS " ~ target_schema ~ ";") %}

{% for n, p in file_dict.items() %}
    {% set table = n.lower() %}
    {% if parquet %}
        {% do run_query("DROP VIEW IF EXISTS " ~ target_schema ~ "." ~ table ~ ";") %}
        {% do run_query("CREATE VIEW IF NOT EXISTS " ~ target_schema ~ "." ~ table ~ " AS SELECT * FROM read_parquet('" ~ p ~ "');") %}
    {% elif csv %}
        {% do run_query("DROP TABLE IF EXISTS " ~ target_schema ~ "." ~ table ~ ";") %}
        {% do run_query("CREATE TABLE IF NOT EXISTS " ~ target_schema ~ "." ~ table ~ " AS SELECT * FROM read_csv('" ~ p ~ "', quote = '');") %}
    {% endif %}
{% endfor %}

{% if csv %}
    {% if vocab_tables %}
        {% for table in ['concept', 'concept_relationship', 'drug_strength'] %}
            {% do run_query("ALTER TABLE " ~ target_schema ~ "." ~ table ~ " ALTER valid_start_date TYPE DATE USING strptime(CAST(valid_start_date AS VARCHAR), '%Y%m%d');") %}
            {% do run_query("ALTER TABLE " ~ target_schema ~ "." ~ table ~ " ALTER valid_end_date TYPE DATE USING strptime(CAST(valid_end_date AS VARCHAR), '%Y%m%d');") %}
        {% endfor %}
    {% else %}
        {% for table in ['medications', 'allergies', 'conditions', 'devices', 'procedures'] %}
            {% do run_query("ALTER TABLE " ~ target_schema ~ "." ~ table ~ " ALTER CODE TYPE VARCHAR;") %}
        {% endfor %}
    {% endif %}
{% endif %}
{% endmacro %}
