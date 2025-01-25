WITH all_costs AS (

    SELECT
        drug_exposure_id AS cost_event_id
        , 'Drug' AS cost_domain_id
        , drug_base_cost AS total_cost
        , drug_paid_by_payer AS paid_by_payer
    FROM {{ ref('int__drug_exposure') }}
    UNION ALL
    SELECT
        procedure_occurrence_id AS cost_event_id
        , 'Procedure' AS cost_domain_id
        , procedure_base_cost AS total_cost
        , {{ dbt.cast("null", api.Column.translate_type("numeric")) }} AS paid_by_payer
    FROM {{ ref('int__procedure_occurrence') }}
    UNION ALL
    SELECT
        visit_detail_id AS cost_event_id
        , 'Visit' AS cost_domain_id
        , total_encounter_cost AS total_cost
        , encounter_payer_coverage AS paid_by_payer
    FROM {{ ref('int__visit_detail') }}

)

SELECT
    row_number() OVER (ORDER BY cost_domain_id, cost_event_id) AS cost_id
    , cost_event_id
    , cost_domain_id
    , 32814 AS cost_type_concept_id
    , 44818668 AS currency_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("numeric")) }} AS total_charge
    , total_cost
    , {{ dbt.cast("null", api.Column.translate_type("numeric")) }} AS total_paid
    , paid_by_payer
    , {{ dbt.cast("null", api.Column.translate_type("numeric")) }} AS paid_by_patient
    , {{ dbt.cast("null", api.Column.translate_type("numeric")) }} AS paid_patient_copay
    , {{ dbt.cast("null", api.Column.translate_type("numeric")) }} AS paid_patient_coinsurance
    , {{ dbt.cast("null", api.Column.translate_type("numeric")) }} AS paid_patient_deductible
    , {{ dbt.cast("null", api.Column.translate_type("numeric")) }} AS paid_by_primary
    , {{ dbt.cast("null", api.Column.translate_type("numeric")) }} AS paid_ingredient_cost
    , {{ dbt.cast("null", api.Column.translate_type("numeric")) }} AS paid_dispensing_fee
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS payer_plan_period_id
    , {{ dbt.cast("null", api.Column.translate_type("numeric")) }} AS amount_allowed
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS revenue_code_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS revenue_code_source_value
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS drg_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS drg_source_value
FROM all_costs
