WITH all_measurements AS (
    SELECT * FROM {{ ref ('int__measurement_observations') }}
    UNION ALL
    SELECT * FROM {{ ref ('int__measurement_procedures') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY am.person_id) AS measurement_id
    , am.*
FROM all_measurements AS am
