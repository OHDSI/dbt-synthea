{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'medications') ) 
%}


WITH cte_medications_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','medications') }}
)

, cte_medications_rename AS (

    SELECT
        {{ timestamptz_to_naive(adapter.quote("start")) }} AS medication_start_datetime
        , {{ timestamptz_to_naive(adapter.quote("stop")) }} AS medication_stop_datetime
        , patient AS patient_id
        , payer AS payer_id
        , encounter AS encounter_id
        , code AS medication_code
        , description AS medication_description
        , base_cost AS medication_base_cost
        , payer_coverage AS medication_payer_coverage
        , dispenses
        , totalcost AS medication_total_cost
        , reasoncode AS medication_reason_code
        , reasondescription AS medication_reason_description
    FROM cte_medications_lower

)

, cte_medications_date_columns AS (

    SELECT
        medication_start_datetime
        , {{ dbt.cast("medication_start_datetime", api.Column.translate_type("date")) }} AS medication_start_date
        , medication_stop_datetime
        , {{ dbt.cast("medication_stop_datetime", api.Column.translate_type("date")) }} AS medication_stop_date
        , patient_id
        , payer_id
        , encounter_id
        , medication_code
        , medication_description
        , medication_base_cost
        , medication_payer_coverage
        , dispenses
        , medication_total_cost
        , medication_reason_code
        , medication_reason_description
    FROM cte_medications_rename

)

SELECT *
FROM cte_medications_date_columns
