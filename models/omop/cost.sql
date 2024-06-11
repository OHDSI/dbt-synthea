WITH all_costs AS (

    SELECT * FROM {{ ref('int__cost_condition') }}
    UNION ALL
    SELECT * FROM {{ ref('int__cost_drug_exposure_1') }}
    UNION ALL
    SELECT * FROM {{ ref('int__cost_drug_exposure_2') }}
    UNION ALL
    SELECT * FROM {{ ref('int__cost_procedure') }}
)

SELECT
    row_number() OVER (ORDER BY ac.cost_event_id) AS cost_id
    , ac.cost_event_id
    , ac.cost_domain_id
    , ac.cost_type_concept_id
    , ac.currency_concept_id
    , ac.total_charge
    , ac.total_cost
    , ac.total_paid
    , ac.paid_by_payer
    , ac.paid_by_patient
    , ac.paid_patient_copay
    , ac.paid_patient_coinsurance
    , ac.paid_patient_deductible
    , ac.paid_by_primary
    , ac.paid_ingredient_cost
    , ac.paid_dispensing_fee
    , ac.payer_plan_period_id
    , ac.amount_allowed
    , ac.revenue_code_concept_id
    , ac.revenue_code_source_value
    , ac.drg_concept_id
    , ac.drg_source_value
FROM all_costs AS ac
