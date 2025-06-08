{% macro create_source_tables(vocab_tables) %}
    {% set database = target.database %}

    {% if vocab_tables %}
        {% set sources = var('vocab_tables') %}
        {% set schema = target.schema ~ '_vocab' %}
    {% else %}
        {% set sources = var('synthea_tables') %}
        {% set schema = target.schema ~ '_synthea' %}
    {% endif %}

    {% do adapter.create_schema(api.Relation.create(database=database, schema=schema)) %}

    {% for table_name, table_config in sources.items() %}
        {% if table_name.startswith('+') %}
            {% continue %}
        {% endif %}
        {% if vocab_tables %}
            {% set columns = table_config %}
        {% else %}
            {% set columns = table_config['+column_types'] %}
        {% endif %}

        {% if not check_if_exists(database, schema, table_name) %}
            {% set column_definitions = [] %}
            {% for column_name, column_type in columns.items() %}
                {% if column_name|lower in ['start', 'stop', 'system', 'type', 'date'] %}
                    {% do column_definitions.append(adapter.quote(column_name) ~ ' ' ~ api.Column.translate_type(column_type)) %}
                {% else %}
                    {% do column_definitions.append(column_name ~ ' ' ~ api.Column.translate_type(column_type)) %}
                {% endif %}
            {% endfor %}

            {% set create_table_sql = "CREATE TABLE " ~ schema ~ "." ~ table_name ~ " (" ~ column_definitions | join(',\n                ') ~ ");" %}

            {% do run_query(create_table_sql) %}
        {% endif %}
    {% endfor %}

    {% do run_query("COMMIT;") %}
{% endmacro %}