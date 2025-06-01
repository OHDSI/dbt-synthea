{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'procedures') ) 
%}


WITH cte_procedures_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','procedures') }}
)

, cte_procedures_rename AS (

    SELECT
        {{ timestamptz_to_naive(adapter.quote("start")) }} AS procedure_start_datetime
        , {{ timestamptz_to_naive(adapter.quote("stop")) }} AS procedure_stop_datetime
        , patient AS patient_id
        , encounter AS encounter_id
        , code AS procedure_code
        , description AS procedure_description
        , {{ dbt.cast("base_cost", api.Column.translate_type("decimal")) }} AS procedure_base_cost
        , reasoncode AS procedure_reason_code
        , reasondescription AS procedure_reason_description
    FROM cte_procedures_lower

)

, cte_procedures_date_columns AS (

    SELECT
        procedure_start_datetime
        , {{ dbt.cast("procedure_start_datetime", api.Column.translate_type("date")) }} AS procedure_start_date
        , procedure_stop_datetime
        , {{ dbt.cast("procedure_stop_datetime", api.Column.translate_type("date")) }} AS procedure_stop_date
        , patient_id
        , encounter_id
        , procedure_code
        , procedure_description
        , procedure_base_cost
        , procedure_reason_code
        , procedure_reason_description
    FROM cte_procedures_rename

)

SELECT *
FROM cte_procedures_date_columns
