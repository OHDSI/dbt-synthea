{% test concept_record_completeness(model, column_name, threshold) %}

WITH validation AS (

    SELECT

        {{ column_name }} AS concept_field

    FROM {{ model }}

),

denominator AS (

    SELECT 
        CASE 
            WHEN COUNT(*) = 0 THEN 1
            ELSE COUNT(*)
        END AS denom
    FROM validation

),

validation_errors AS (

    SELECT 1
    FROM validation
    CROSS JOIN denominator
    GROUP BY denom
    HAVING
        SUM(CASE WHEN concept_field = 0 THEN 1 ELSE 0 END) * 1.0 / denom > {{ threshold }}

)

SELECT *
FROM validation_errors

{% endtest %}