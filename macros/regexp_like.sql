{%- macro regexp_like(subject, pattern) -%}
    {{ return(adapter.dispatch("regexp_like")(subject, pattern)) }}
{%- endmacro -%}

{% macro default__regexp_like(subject, pattern) %}
    {{ subject }} ~ '{{ pattern }}'
{% endmacro %}

{% macro snowflake__regexp_like(subject, pattern) %}
    regexp_like({{ subject }}, '{{ pattern }}')
{% endmacro %}
