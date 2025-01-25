SELECT
    row_number() OVER (ORDER BY p.person_id) AS device_exposure_id
    , p.person_id
    , srctostdvm.target_concept_id AS device_concept_id
    , d.device_start_date AS device_exposure_start_date
    , d.device_start_datetime AS device_exposure_start_datetime
    , d.device_stop_date AS device_exposure_end_date
    , d.device_stop_datetime AS device_exposure_end_datetime
    , 32827 AS device_type_concept_id
    , d.udi AS unique_device_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS production_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS quantity
    , vd.provider_id
    , vd.visit_occurrence_id
    , vd.visit_detail_id
    , d.device_code AS device_source_value
    , srctosrcvm.source_concept_id AS device_source_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS unit_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS unit_source_value
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS unit_source_concept_id
FROM {{ ref('stg_synthea__devices') }} AS d
INNER JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srctostdvm
    ON
        d.device_code = srctostdvm.source_code
        AND srctostdvm.target_domain_id = 'Device'
        AND srctostdvm.target_vocabulary_id = 'SNOMED'
        AND srctostdvm.source_vocabulary_id = 'SNOMED'
        AND srctostdvm.target_standard_concept = 'S'
        AND srctostdvm.target_invalid_reason IS null
INNER JOIN {{ ref ('int__source_to_source_vocab_map') }} AS srctosrcvm
    ON
        d.device_code = srctosrcvm.source_code
        AND srctosrcvm.source_vocabulary_id = 'SNOMED'
INNER JOIN {{ ref ('int__person') }} AS p
    ON d.patient_id = p.person_source_value
LEFT JOIN {{ ref ('int__visit_detail') }} AS vd
    ON d.encounter_id = vd.visit_detail_source_value
