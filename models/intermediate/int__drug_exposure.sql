WITH all_drugs AS (
    SELECT * FROM {{ ref('int__drug_medications') }}
    UNION ALL
    SELECT * FROM {{ ref('int__drug_immunisations') }}
)

SELECT
    row_number() OVER (ORDER BY person_id, drug_concept_id, drug_exposure_start_datetime) AS drug_exposure_id
    , drug_base_cost
    , drug_paid_by_payer
    , person_id
    , drug_concept_id
    , drug_exposure_start_date
    , drug_exposure_start_datetime
    , drug_exposure_end_date
    , drug_exposure_end_datetime
    , verbatim_end_date
    , drug_type_concept_id
    , days_supply
    , route_concept_id
    , lot_number
    , provider_id
    , visit_occurrence_id
    , visit_detail_id
    , drug_source_value
    , drug_source_concept_id
FROM
    all_drugs
