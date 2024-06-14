{% if var('seed_source', true) %}
{{ config(enabled=true) }}
{% else %}
{{ config(enabled=false) }}
{% endif %}

SELECT * FROM {{ ref('stg_vocabulary__vocabulary') }}
