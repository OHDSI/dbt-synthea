SELECT
    visit_detail_id
    , person_id
    , visit_detail_concept_id
    , visit_detail_start_date
    , visit_detail_start_datetime
    , visit_detail_end_date
    , visit_detail_end_datetime
    , 32827 AS visit_detail_type_concept_id
    , provider_id
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }}  AS care_site_id
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }} AS admitted_from_concept_id
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }} AS discharged_to_concept_id
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }} AS preceding_visit_detail_id
    , {{ string_truncate("visit_detail_source_value", 50) }} AS visit_detail_source_value
    , 0 AS visit_detail_source_concept_id
    , {{ dbt.cast("NULL", api.Column.translate_type("varchar")) }} AS admitted_from_source_value
    , {{ dbt.cast("NULL", api.Column.translate_type("varchar")) }} AS discharged_to_source_value
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }}  AS parent_visit_detail_id
    , visit_occurrence_id
FROM {{ ref( 'int__visit_detail') }}
