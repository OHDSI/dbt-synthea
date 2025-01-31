SELECT
    p.person_id
    , a.patient_id
    , a.encounter_id
    , srctostdvm.target_concept_id AS observation_concept_id
    , a.allergy_start_date AS observation_date
    , a.allergy_start_date AS observation_datetime
    , 32827 AS observation_type_concept_id
    , vd.provider_id
    , vd.visit_occurrence_id
    , vd.visit_detail_id
    , a.allergy_code AS observation_source_value
    , srctosrcvm.source_concept_id AS observation_source_concept_id
FROM {{ ref ('stg_synthea__allergies') }} AS a
INNER JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srctostdvm
    ON
        a.allergy_code = srctostdvm.source_code
        AND srctostdvm.target_domain_id = 'Observation'
        AND srctostdvm.target_vocabulary_id = 'SNOMED'
        AND srctostdvm.target_standard_concept = 'S'
        AND srctostdvm.target_invalid_reason IS null
INNER JOIN {{ ref ('int__source_to_source_vocab_map') }} AS srctosrcvm
    ON
        a.allergy_code = srctosrcvm.source_code
        AND srctosrcvm.source_vocabulary_id = 'SNOMED'
        AND srctosrcvm.source_domain_id = 'Observation'
INNER JOIN {{ ref ('int__person') }} AS p
    ON a.patient_id = p.person_source_value
LEFT JOIN {{ ref ('int__visit_detail') }} AS vd
    ON a.encounter_id = vd.encounter_id
