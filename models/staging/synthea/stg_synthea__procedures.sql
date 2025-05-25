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
        "start" AS procedure_start_datetime
        , {{ dbt.cast(adapter.quote("start"), api.Column.translate_type("date")) }} AS procedure_start_date
        , "stop" AS procedure_stop_datetime
        , {{ dbt.cast(adapter.quote("stop"), api.Column.translate_type("date")) }} AS procedure_stop_date
        , patient AS patient_id
        , encounter AS encounter_id
        , code AS procedure_code
        , description AS procedure_description
        , {{ dbt.cast("base_cost", api.Column.translate_type("decimal")) }} AS procedure_base_cost
        , reasoncode AS procedure_reason_code
        , reasondescription AS procedure_reason_description
    FROM cte_procedures_lower

)

SELECT *
FROM cte_procedures_rename
