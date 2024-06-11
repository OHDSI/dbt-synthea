{% macro load_data_duckdb(file_dict, vocab_tables) %}

    {% if vocab_tables %}
        {% set target_schema = target.schema %}
    {% else %}
        {% set target_schema = target.schema ~ '_synthea' %}
    {% endif %}

    {% do run_query("CREATE SCHEMA IF NOT EXISTS " ~ target_schema ~ ";") %}

    {% for n, p in file_dict.items() %}
        {% do run_query("DROP TABLE IF EXISTS " ~ target_schema ~ "." ~ n.lower() ~ ";") %}
        {% do run_query("CREATE TABLE IF NOT EXISTS " ~ target_schema ~ "." ~ n.lower() ~ " AS SELECT * FROM read_csv('" ~ p ~ "');") %}
    {% endfor %}

    {% if vocab_tables %}
        {% do run_query("ALTER TABLE " ~ target_schema ~ ".concept ALTER valid_start_date TYPE DATE USING strptime(CAST(valid_start_date AS VARCHAR), '%Y%m%d');") %}
        {% do run_query("ALTER TABLE " ~ target_schema ~ ".concept ALTER valid_end_date TYPE DATE USING strptime(CAST(valid_end_date AS VARCHAR), '%Y%m%d');") %}
    {% else %}
        {% do run_query("ALTER TABLE " ~ target_schema ~ ".medications ALTER CODE TYPE VARCHAR;") %}
        {% do run_query("ALTER TABLE " ~ target_schema ~ ".allergies ALTER CODE TYPE VARCHAR;") %}
        {% do run_query("ALTER TABLE " ~ target_schema ~ ".conditions ALTER CODE TYPE VARCHAR;") %}
        {% do run_query("ALTER TABLE " ~ target_schema ~ ".devices ALTER CODE TYPE VARCHAR;") %}
        {% do run_query("ALTER TABLE " ~ target_schema ~ ".procedures ALTER CODE TYPE VARCHAR;") %}
    {% endif %}

{% endmacro %}