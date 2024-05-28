{% macro lowercase_columns(column_names) %}
    {% for column_name in column_names %} 
        "{{ column_name }}" AS {{ column_name | lower }} 
        {% if not loop.last %},{% endif %} 
    {% endfor %}
{% endmacro %}