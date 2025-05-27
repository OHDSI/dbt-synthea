{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'encounters') ) 
%}


WITH cte_encounters_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','encounters') }}
)

, cte_encounters_rename AS (

    SELECT
        id AS encounter_id
        , {{ timestamptz_to_naive("\"start\"") }} AS encounter_start_datetime
        , {{ dbt.cast("\"start\"", api.Column.translate_type("date")) }} AS encounter_start_date
        -- default to start date if stop date is null
        , COALESCE(
            {{ timestamptz_to_naive("\"stop\"") }},
            {{ timestamptz_to_naive("\"start\"") }}
        ) AS encounter_stop_datetime
        , COALESCE(
            {{ dbt.cast("\"stop\"", api.Column.translate_type("date")) }},
            {{ dbt.cast("\"start\"", api.Column.translate_type("date")) }}
        ) AS encounter_stop_date
        , patient AS patient_id
        , organization AS organization_id
        , provider AS provider_id
        , payer AS payer_id
        , encounterclass AS encounter_class
        , code AS encounter_code
        , description AS encounter_description
        , base_encounter_cost
        , {{ dbt.cast("total_claim_cost", api.Column.translate_type("decimal")) }} AS total_encounter_cost
        , {{ dbt.cast("payer_coverage", api.Column.translate_type("decimal")) }} AS encounter_payer_coverage
        , reasoncode AS encounter_reason_code
        , reasondescription AS encounter_reason_description
    FROM cte_encounters_lower

)

, cte_encounters_date_columns AS (

    SELECT
            encounter_id
            , encounter_start_datetime
            , {{ dbt.cast("encounter_start_datetime", api.Column.translate_type("date")) }} AS encounter_start_date
            , encounter_stop_datetime
            , COALESCE(
                {{ dbt.cast("encounter_start_datetime", api.Column.translate_type("date")) }},
                {{ dbt.cast("encounter_stop_datetime", api.Column.translate_type("date")) }}
            ) AS encounter_stop_date
            , patient_id
            , organization_id
            , provider_id
            , payer_id
            , encounter_class
            , encounter_code
            , encounter_description
            , base_encounter_cost
            , total_encounter_cost
            , encounter_payer_coverage
            , encounter_reason_code
            , encounter_reason_description
    FROM cte_encounters_rename

)

SELECT *
FROM cte_encounters_date_columns
