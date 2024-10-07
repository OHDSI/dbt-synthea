{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'devices') ) 
%}


WITH cte_devices_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','devices') }}
)

, cte_devices_rename AS (

    SELECT
        "start" AS device_start_datetime
        , {{ dbt.cast("\"start\"", api.Column.translate_type("date")) }} AS device_start_date
        , "stop" AS device_stop_datetime
        , {{ dbt.cast("\"stop\"", api.Column.translate_type("date")) }} AS device_stop_date
        , patient AS patient_id
        , encounter AS encounter_id
        , code AS device_code
        , description AS device_description
        , udi
    FROM cte_devices_lower

)

SELECT *
FROM cte_devices_rename
