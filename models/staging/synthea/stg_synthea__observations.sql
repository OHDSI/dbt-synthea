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
        {{ adapter.quote("date") }} AS observation_datetime
        , {{ dbt.cast(adapter.quote("date"), api.Column.translate_type("date")) }} AS observation_date
        , patient AS patient_id
        , encounter AS encounter_id
        , category AS observation_category
        , code AS observation_code
        , description AS observation_description
        , {{ adapter.quote("value") }} AS observation_value
        , units AS observation_units
        , {{ adapter.quote("type") }} AS observation_value_type
    FROM cte_observations_lower

)

SELECT *
FROM cte_observations_rename
