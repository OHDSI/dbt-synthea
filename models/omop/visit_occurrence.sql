SELECT
    visit_occurrence_id
    , person_id
    , CASE
        WHEN lower(visit_class) = 'er+ip' THEN 262
        WHEN lower(visit_class) IN ('ambulatory', 'wellness', 'outpatient') THEN 9202
        WHEN lower(visit_class) IN ('emergency', 'urgentcare') THEN 9203
        WHEN lower(visit_class) = 'inpatient' THEN 9201
        ELSE 0
    END AS visit_concept_id
    , visit_start_date
    , {{ dbt.cast("NULL", api.Column.translate_type("timestamp")) }} AS visit_start_datetime
    , visit_end_date
    , {{ dbt.cast("NULL", api.Column.translate_type("timestamp")) }} AS visit_end_datetime
    , 32827 AS visit_type_concept_id
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }}  AS provider_id
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }}  AS care_site_id
    , {{ string_truncate("visit_class", 50) }} AS visit_source_value
    , 0 AS visit_source_concept_id
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }} AS admitted_from_concept_id
    , {{ dbt.cast("NULL", api.Column.translate_type("varchar")) }} AS admitted_from_source_value
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }} AS discharged_to_concept_id
    , {{ dbt.cast("NULL", api.Column.translate_type("varchar")) }} AS discharged_to_source_value
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }} AS preceding_visit_occurrence_id
FROM {{ ref( 'int__visits') }}
