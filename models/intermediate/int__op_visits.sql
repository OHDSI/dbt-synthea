/* outpatient visits */

WITH cte_visits_distinct AS (
    SELECT
        min(encounter_id) AS encounter_id
        , patient_id
        , encounter_class
        , encounter_start_datetime AS visit_start_datetime
        , encounter_stop_datetime AS visit_end_datetime
    FROM {{ ref( 'stg_synthea__encounters') }}
    WHERE encounter_class IN ('ambulatory', 'wellness', 'outpatient')
    GROUP BY
        patient_id
        , encounter_class
        , encounter_start_datetime
        , encounter_stop_datetime
)

SELECT
    min(encounter_id) AS encounter_id
    , patient_id
    , encounter_class
    , visit_start_datetime
    , max(visit_end_datetime) AS visit_end_datetime
FROM cte_visits_distinct
GROUP BY patient_id, encounter_class, visit_start_datetime
