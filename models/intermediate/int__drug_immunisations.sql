SELECT
    i.patient_id
    , i.encounter_id
    , srctostdvm.target_concept_id AS drug_concept_id
    , {{ dbt.cast("i.immunization_date", api.Column.translate_type("date")) }} AS drug_exposure_start_date
    , i.immunization_date AS drug_exposure_start_datetime
    , {{ dbt.cast("i.immunization_date", api.Column.translate_type("date")) }} AS drug_exposure_end_date
    , i.immunization_date AS drug_exposure_end_datetime
    , {{ dbt.cast("i.immunization_date", api.Column.translate_type("date")) }} AS verbatim_end_date
    , 32827 AS drug_type_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS stop_reason
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS refills
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS quantity
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS days_supply
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS sig
    , 0 AS route_concept_id
    , '0' AS lot_number
    , i.immunization_code AS drug_source_value
    , srctosrcvm.source_concept_id AS drug_source_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS route_source_value
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS dose_unit_source_value
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
