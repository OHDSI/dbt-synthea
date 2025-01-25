SELECT
    row_number() OVER (ORDER BY p.person_id) AS visit_detail_id
    , p.person_id
    , CASE
        WHEN lower(e.encounter_class) IN ('ambulatory', 'wellness', 'outpatient') THEN 9202
        WHEN lower(e.encounter_class) IN ('emergency', 'urgentcare') THEN 9203
        WHEN lower(e.encounter_class) = 'inpatient' THEN 9201
        ELSE 0
    END AS visit_detail_concept_id
    , e.encounter_start_date AS visit_detail_start_date
    , e.encounter_start_datetime AS visit_detail_start_datetime
    , e.encounter_stop_date AS visit_detail_end_date
    , e.encounter_stop_datetime AS visit_detail_stop_datetime
    , 32827 AS visit_detail_type_concept_id
    , pr.provider_id
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }}  AS care_site_id
    , 0 AS admitted_from_concept_id
    , 0 AS discharged_to_concept_id
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }} AS preceding_visit_detail_id
    , e.encounter_class AS visit_detail_source_value
    , 0 AS visit_detail_source_concept_id
    , {{ dbt.cast("NULL", api.Column.translate_type("varchar")) }} AS admitted_from_source_value
    , {{ dbt.cast("NULL", api.Column.translate_type("varchar")) }} AS discharged_to_source_value
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }}  AS parent_visit_detail_id
    , v.visit_occurrence_id
    , e.total_encounter_cost
    , e.encounter_payer_coverage
FROM {{ ref( 'int__visits_encounters') }} AS ve
INNER JOIN {{ ref ('int__visits') }} AS v
    ON ve.visit_id = v.visit_id
INNER JOIN {{ ref ('stg_synthea__encounters') }} AS e
    ON ve.encounter_id = e.encounter_id
INNER JOIN {{ ref ('int__person') }} AS p
    ON e.patient_id = p.person_source_value
LEFT JOIN {{ ref ('int__provider') }} AS pr
    ON e.provider_id = pr.provider_source_value
