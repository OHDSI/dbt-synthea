{% test concept_record_completeness(model, column_name, threshold) %}

{%- set model_name = model.identifier -%}

WITH validation AS (

    SELECT

        {{ column_name }} AS concept_field
        {% if column_name == 'unit_concept_id' and (model_name == 'measurement' or model_name == 'observation') %}
        , value_as_number 
        {% endif %}

    FROM {{ model }}

),

denominator AS (

    SELECT 
        CASE 
            WHEN COUNT(*) = 0 THEN 1
            ELSE COUNT(*)
        END AS denom
    FROM validation
    {% if column_name == 'unit_concept_id' and (model_name == 'measurement' or model_name == 'observation') %}
    WHERE value_as_number IS NOT NULL
    {% endif %}

),

validation_errors AS (

    SELECT 1
    FROM validation
    CROSS JOIN denominator
    GROUP BY denom
    HAVING
        SUM(
            CASE 
                WHEN 
                    concept_field = 0 
                    {% if column_name == 'unit_concept_id' and (model_name == 'measurement' or model_name == 'observation') %}
                    AND value_as_number IS NOT NULL
                    {% endif %}
                    THEN 1 
                ELSE 0 
            END
        ) * 100.0 / denom > {{ threshold }}

)

SELECT *
FROM validation_errors

{% endtest %}