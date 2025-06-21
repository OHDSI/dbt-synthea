SELECT
    p.person_id
    , i.patient_id
    , i.encounter_id
    , vd.provider_id
    , vd.visit_occurrence_id
    , vd.visit_detail_id
    , srctostdvm.target_concept_id AS drug_concept_id
    , {{ dbt.cast("i.immunization_date", api.Column.translate_type("date")) }} AS drug_exposure_start_date
    , i.immunization_date AS drug_exposure_start_datetime
    , {{ dbt.cast("i.immunization_date", api.Column.translate_type("date")) }} AS drug_exposure_end_date
    , i.immunization_date AS drug_exposure_end_datetime
    , {{ dbt.cast("i.immunization_date", api.Column.translate_type("date")) }} AS verbatim_end_date
    , 32827 AS drug_type_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS days_supply
    , i.immunization_code AS drug_source_value
    , srctosrcvm.source_concept_id AS drug_source_concept_id
    , i.immunization_base_cost AS drug_base_cost
    , {{ dbt.cast("null", api.Column.translate_type("numeric")) }} AS drug_paid_by_payer
FROM {{ ref ('stg_synthea__immunizations') }} AS i
INNER JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srctostdvm
    ON
        i.immunization_code = srctostdvm.source_code
        AND srctostdvm.target_domain_id = 'Drug'
        AND srctostdvm.target_vocabulary_id = 'CVX'
        AND srctostdvm.target_standard_concept = 'S'
        AND srctostdvm.target_invalid_reason IS null
INNER JOIN {{ ref ('int__source_to_source_vocab_map') }} AS srctosrcvm
    ON
        i.immunization_code = srctosrcvm.source_code
        AND srctosrcvm.source_vocabulary_id = 'CVX'
INNER JOIN {{ ref ('int__person') }} AS p
    ON i.patient_id = p.person_source_value
LEFT JOIN {{ ref ('int__visit_detail') }} AS vd
    ON i.encounter_id = vd.encounter_id
