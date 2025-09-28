SELECT
    row_number()
        OVER (ORDER BY pat.patient_id, pt.coverage_start_datetime)
    AS payer_plan_period_id
    , per.person_id
    , pt.coverage_start_date AS payer_plan_period_start_date
    , pt.coverage_end_date AS payer_plan_period_end_date
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS payer_concept_id
    , {{ string_truncate("pt.payer_id", 50) }} AS payer_source_value
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS payer_source_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS plan_concept_id
    , {{ string_truncate("pay.payer_name", 50) }} AS plan_source_value
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS plan_source_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS sponsor_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS sponsor_source_value
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS sponsor_source_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS family_source_value
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS stop_reason_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS stop_reason_source_value
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS stop_reason_source_concept_id
FROM {{ ref ('stg_synthea__payers') }} AS pay
INNER JOIN {{ ref ('stg_synthea__payer_transitions') }} AS pt
    ON pay.payer_id = pt.payer_id
INNER JOIN {{ ref ('stg_synthea__patients') }} AS pat
    ON pt.patient_id = pat.patient_id
INNER JOIN {{ ref('person') }} AS per
    ON pat.patient_id = per.person_source_value
