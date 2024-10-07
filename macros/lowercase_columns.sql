{% macro lowercase_columns(column_names) %}
    {# List of SQL Keywords in use by dbt-synthea #}
    {% set sql_keywords = ["start", "stop", "type", "system", "date", "first", "last", "value", "name"] %}
    {% for column_name in column_names %} 
        {% set lowercase_column = column_name | lower %}
        {# If a keyword - quote the output column name so it can be safely used in models #}
        {% if column_name | lower in sql_keywords %}
            "{{ column_name }}" AS "{{ lowercase_column }}"
        {% else %}
        "{{ column_name }}" AS {{ lowercase_column }}
        {% endif %}
        {% if not loop.last %},{% endif %} 
    {% endfor %}
{% endmacro %}