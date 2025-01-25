WITH all_visits AS (
    SELECT
        visit_id
        , patient_id
        , visit_class
        , visit_start_date
        , visit_end_date
    FROM {{ ref('int__visits_encounters') }}
    WHERE visit_class IN ('outpatient', 'emergency', 'urgentcare', 'ambulatory', 'wellness')

    UNION ALL

    SELECT DISTINCT
        visit_id
        , patient_id
        , visit_class
        , visit_start_date
        , visit_end_date
    FROM {{ ref('int__visits_encounters') }}
    WHERE visit_class IN ('inpatient', 'er+ip')
)

SELECT
    ROW_NUMBER() OVER (ORDER BY patient_id) AS visit_occurrence_id
    , *
FROM all_visits
