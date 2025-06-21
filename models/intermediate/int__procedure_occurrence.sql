SELECT
    row_number() OVER (ORDER BY p.person_id) AS procedure_occurrence_id
    , p.person_id
    , pr.procedure_base_cost
    , pr.encounter_id
    , srctostdvm.target_concept_id AS procedure_concept_id
    , pr.procedure_start_date AS procedure_date
    , pr.procedure_start_datetime AS procedure_datetime
    , pr.procedure_stop_date AS procedure_end_date
    , pr.procedure_stop_datetime AS procedure_end_datetime
    , pr.procedure_code AS procedure_source_value
    , srctosrcvm.source_concept_id AS procedure_source_concept_id
FROM {{ ref( 'stg_synthea__procedures') }} AS pr
INNER JOIN {{ ref( 'int__source_to_standard_vocab_map') }} AS srctostdvm
    ON
        pr.procedure_code = srctostdvm.source_code
        AND srctostdvm.target_domain_id = 'Procedure'
        AND srctostdvm.target_vocabulary_id = 'SNOMED'
        AND srctostdvm.source_vocabulary_id = 'SNOMED'
        AND srctostdvm.target_standard_concept = 'S'
        AND srctostdvm.target_invalid_reason IS null
INNER JOIN {{ ref( 'int__source_to_source_vocab_map') }} AS srctosrcvm
    ON
        pr.procedure_code = srctosrcvm.source_code
        AND srctosrcvm.source_vocabulary_id = 'SNOMED'
INNER JOIN {{ ref( 'int__person') }} AS p
    ON pr.patient_id = p.person_source_value
