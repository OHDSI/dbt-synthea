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
        {{ timestamptz_to_naive("\"start\"") }} AS device_start_datetime
        , {{ timestamptz_to_naive("\"stop\"") }} AS device_stop_datetime
        , patient AS patient_id
        , encounter AS encounter_id
        , code AS device_code
        , description AS device_description
        , udi
    FROM cte_devices_lower

)

, cte_devices_date_columns AS (

    SELECT
        device_start_datetime
        , {{ dbt.cast("device_start_datetime", api.Column.translate_type("date")) }} AS device_start_date
        , device_stop_datetime
        , {{ dbt.cast("device_stop_datetime", api.Column.translate_type("date")) }} AS device_stop_date
        , patient_id
        , encounter_id
        , device_code
        , device_description
        , udi
    FROM cte_devices_rename

)

SELECT *
FROM cte_devices_date_columns
