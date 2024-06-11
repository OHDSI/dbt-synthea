SELECT
    row_number()
        OVER (ORDER BY pat.patient_id, pt.coverage_start_year)
    AS payer_plan_period_id
    , per.person_id
    , cast(
        concat(cast(pt.coverage_start_year AS varchar), '-01', '-01') AS date
    ) AS payer_plan_period_start_date
    , cast(
        concat(cast(pt.coverage_end_year AS varchar), '-12', '-31') AS date
    ) AS payer_plan_period_end_date
    , 0 AS payer_concept_id
    , pt.payer_id AS payer_source_value
    , 0 AS payer_source_concept_id
    , 0 AS plan_concept_id
    , pay.payer_name AS plan_source_value
    , 0 AS plan_source_concept_id
    , 0 AS sponsor_concept_id
    , cast(NULL AS varchar) AS sponsor_source_value
    , 0 AS sponsor_source_concept_id
    , cast(NULL AS varchar) AS family_source_value
    , 0 AS stop_reason_concept_id
    , cast(NULL AS varchar) AS stop_reason_source_value
    , 0 AS stop_reason_source_concept_id
FROM {{ ref ('stg_synthea__payers') }} AS pay
INNER JOIN {{ ref ('stg_synthea__payer_transitions') }} AS pt
    ON pay.payer_id = pt.payer_id
INNER JOIN {{ ref ('stg_synthea__patients') }} AS pat
    ON pt.patient_id = pat.patient_id
INNER JOIN {{ ref('person') }} AS per
    ON pat.patient_id = per.person_source_value
