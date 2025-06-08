SELECT
    p.person_id
    , m.patient_id
    , m.encounter_id
    , vd.provider_id
    , vd.visit_occurrence_id
    , vd.visit_detail_id
    , srctostdvm.target_concept_id AS drug_concept_id
    , m.medication_start_date AS drug_exposure_start_date
    , m.medication_start_datetime AS drug_exposure_start_datetime
    , coalesce(m.medication_stop_date, m.medication_start_date) AS drug_exposure_end_date
    , coalesce(m.medication_stop_datetime, m.medication_start_datetime) AS drug_exposure_end_datetime
    , m.medication_stop_date AS verbatim_end_date
    , 32838 AS drug_type_concept_id
    , {{ dbt.datediff(
        "m.medication_start_date",
        "m.medication_stop_date", 
        "day") 
    }} AS days_supply
    , 0 AS route_concept_id
    , '0' AS lot_number
    , m.medication_code AS drug_source_value
    , srctosrcvm.source_concept_id AS drug_source_concept_id
    , m.medication_base_cost AS drug_base_cost
    , m.medication_payer_coverage AS drug_paid_by_payer
FROM {{ ref ('stg_synthea__medications') }} AS m
INNER JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srctostdvm
    ON
        m.medication_code = srctostdvm.source_code
        AND srctostdvm.target_domain_id = 'Drug'
        AND srctostdvm.target_vocabulary_id = 'RxNorm'
        AND srctostdvm.target_standard_concept = 'S'
        AND srctostdvm.target_invalid_reason IS null
INNER JOIN {{ ref ('int__source_to_source_vocab_map') }} AS srctosrcvm
    ON
        m.medication_code = srctosrcvm.source_code
        AND srctosrcvm.source_vocabulary_id = 'RxNorm'
INNER JOIN {{ ref ('int__person') }} AS p
    ON m.patient_id = p.person_source_value
LEFT JOIN {{ ref ('int__visit_detail') }} AS vd
    ON m.encounter_id = vd.encounter_id
