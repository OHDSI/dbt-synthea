WITH all_measurements AS (
    SELECT * FROM {{ ref ('int__measurement_observations') }}
    UNION ALL
    SELECT * FROM {{ ref ('int__measurement_procedures') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY person_id) AS measurement_id
    , person_id
    , measurement_concept_id
    , measurement_date
    , measurement_datetime
    , {{ dbt.cast("measurement_time", api.Column.translate_type("varchar")) }} AS measurement_time -- for some reason CDM spec wants this as varchar
    , 32827 AS measurement_type_concept_id
    , 0 AS operator_concept_id
    , value_as_number
    , value_as_concept_id
    , unit_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("float")) }} AS range_low
    , {{ dbt.cast("null", api.Column.translate_type("float")) }} AS range_high
    , provider_id
    , visit_occurrence_id
    , visit_detail_id
    , {{ string_truncate("measurement_source_value", 50) }} AS measurement_source_value
    , measurement_source_concept_id
    , {{ string_truncate("unit_source_value", 50) }} AS unit_source_value
    , {{ string_truncate("value_source_value", 50) }} AS value_source_value
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS unit_source_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("bigint")) }} AS measurement_event_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS meas_event_field_concept_id
FROM all_measurements
