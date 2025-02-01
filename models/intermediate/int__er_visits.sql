/*
emergency visits
*/

SELECT
    encounter_id AS visit_id
    , encounter_id
    , patient_id
    , encounter_class AS visit_class
    , encounter_start_date AS visit_start_date
    , encounter_stop_date AS visit_end_date
FROM {{ ref( 'stg_synthea__encounters') }}
WHERE encounter_class IN ('emergency', 'urgentcare')
-- only include single-day visits
AND encounter_start_date = encounter_stop_date
