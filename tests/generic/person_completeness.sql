{% test person_completeness(model, threshold) %}

WITH validation AS (

    SELECT DISTINCT
        person.person_id
    FROM {{ ref('person') }} person
        LEFT JOIN {{ model }} model
			ON person.person_id = model.person_id
	WHERE model.person_id IS NULL

),

denominator AS (

    SELECT 
        CASE 
            WHEN COUNT(DISTINCT person_id) = 0 THEN 1
            ELSE COUNT(DISTINCT person_id)
        END AS denom
    FROM {{ ref('person') }}

),

validation_errors AS (

    SELECT 1
    FROM validation
    CROSS JOIN denominator
    GROUP BY denom
    HAVING
        COUNT(DISTINCT person_id) * 100.0 / denom > {{ threshold }}

)

SELECT *
FROM validation_errors

{% endtest %}