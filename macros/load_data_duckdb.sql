{% macro load_data_duckdb(file_dict, vocab_tables) %}
    {% if vocab_tables %}
        {% set schema = target.schema ~ '_vocab' %}
        {% set sources = var('vocab_tables') %}
    {% else %}
        {% set schema = target.schema ~ '_synthea' %}
        {% set sources = var('synthea_tables') %}
    {% endif %}

    {% set first_key, first_val = (file_dict | dictsort | first) %}
    {% set parquet = first_val.endswith(".parquet") %}
    {% set csv = first_val.endswith(".csv") %}

    {% do adapter.create_schema(api.Relation.create(database=database, schema=schema)) %}

    {% set file_table_names = file_dict.keys() | list %}

    {% for n, p in file_dict.items() %}
        {% set table = sources.get(n.lower()) %}  
        {% if not table %}
            {% do log("Warning: Table " ~ n.lower() ~ " not found in YAML configuration.", info=True) %}  
            {% continue %}  
        {% endif %}

        {% if vocab_tables %}
            {% set columns = table %}
        {% else %}
            {% set columns = table['+column_types'] %}
        {% endif %}

        {% set column_casts = [] %}
        {% for column_name, column_type in columns.items() %}
            {% if column_name in ['valid_start_date', 'valid_end_date'] %}
                {% do column_casts.append("CAST(strptime(CAST(" ~ column_name ~ " AS VARCHAR), '%Y%m%d') AS DATE) AS " ~ column_name) %}
            {% elif column_name|lower in ['start', 'stop', 'system', 'type', 'date'] %}
                {% do column_casts.append("CAST(" ~ adapter.quote(column_name) ~ " AS " ~ api.Column.translate_type(column_type) ~ ") AS " ~ adapter.quote(column_name)) %}
            {% else %}
                {% do column_casts.append("CAST(" ~ column_name ~ " AS " ~ api.Column.translate_type(column_type) ~ ") AS " ~ column_name) %}
            {% endif %}
        {% endfor %}

        {% set object_type_query %}
            SELECT table_type 
            FROM information_schema.tables 
            WHERE table_schema = '{{ schema }}' 
            AND table_name = '{{ n.lower() }}'
        {% endset %}
        
        {% set results = run_query(object_type_query) %}
        {% if results.rows %}
            {% set table_type = results.rows[0]['table_type'] %}
            {% if table_type == 'BASE TABLE' %}
                {% do run_query("DROP TABLE " ~ schema ~ "." ~ n.lower()) %}
            {% elif table_type == 'VIEW' %}
                {% do run_query("DROP VIEW " ~ schema ~ "." ~ n.lower()) %}
            {% endif %}
        {% endif %}

        {% if csv %}
            {% set create_table_sql = "CREATE TABLE " ~ schema ~ "." ~ n.lower() ~ " AS SELECT " ~ column_casts | join(', ') ~ " FROM read_csv('" ~ p ~ "', quote = '');" %}
        {% elif parquet %}
            {% set create_table_sql = "CREATE VIEW " ~ schema ~ "." ~ n.lower() ~ " AS SELECT " ~ column_casts | join(', ') ~ " FROM read_parquet('" ~ p ~ "');" %}
        {% endif %}
        {% do run_query(create_table_sql) %}
    {% endfor %}

{% endmacro %}
