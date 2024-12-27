SELECT
    p.person_id
    , srctostdvm.target_concept_id AS measurement_concept_id
    , pr.procedure_start_date AS measurement_date
    , pr.procedure_start_datetime AS measurement_datetime
    , {{ dbt.cast("pr.procedure_start_datetime", api.Column.translate_type("time")) }} AS measurement_time
    , 32827 AS measurement_type_concept_id
    , 0 AS operator_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("decimal")) }} AS value_as_number
    , 0 AS value_as_concept_id
    , 0 AS unit_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("decimal")) }} AS range_low
    , {{ dbt.cast("null", api.Column.translate_type("decimal")) }} AS range_high
    , epr.provider_id
    , epr.visit_occurrence_id
    , epr.visit_occurrence_id + 1000000 AS visit_detail_id
    , pr.procedure_code AS measurement_source_value
    , srctosrcvm.source_concept_id AS measurement_source_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS unit_source_value
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS value_source_value
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS unit_source_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("bigint")) }} AS measurement_event_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS meas_event_field_concept_id
FROM {{ ref ('stg_synthea__procedures') }} AS pr
INNER JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srctostdvm
    ON
        pr.procedure_code = srctostdvm.source_code
        AND srctostdvm.target_domain_id = 'Measurement'
        AND srctostdvm.source_vocabulary_id = 'SNOMED'
        AND srctostdvm.target_standard_concept = 'S'
        AND srctostdvm.target_invalid_reason IS null
INNER JOIN {{ ref ('int__source_to_source_vocab_map') }} AS srctosrcvm
    ON
        pr.procedure_code = srctosrcvm.source_code
        AND srctosrcvm.source_vocabulary_id = 'SNOMED'
INNER JOIN {{ ref ('int__person') }} AS p
    ON pr.patient_id = p.person_source_value
LEFT JOIN {{ ref ('int__encounter_provider') }} AS epr
    ON pr.encounter_id = epr.encounter_id
