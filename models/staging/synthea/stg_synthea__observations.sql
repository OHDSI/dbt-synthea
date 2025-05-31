{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'observations') ) 
%}


WITH cte_observations_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','observations') }}
)

, cte_observations_rename AS (

    SELECT
        {{ timestamptz_to_naive("\"date\"") }} AS observation_datetime
        , patient AS patient_id
        , encounter AS encounter_id
        , category AS observation_category
        , code AS observation_code
        , description AS observation_description
        , "value" AS observation_value
        , units AS observation_units
        , "type" AS observation_value_type
    FROM cte_observations_lower

)

, cte_observation_date_columns AS (

    SELECT
        observation_datetime
        , {{ dbt.cast("observation_datetime", api.Column.translate_type("date")) }} AS observation_date
        , patient_id
        , encounter_id
        , observation_category
        , observation_code
        , observation_description
        , observation_value
        , observation_units
        , observation_value_type
    FROM cte_observations_rename

)

SELECT *
FROM cte_observation_date_columns
