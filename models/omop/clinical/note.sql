SELECT
    {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS note_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS person_id
    , {{ dbt.cast("null", api.Column.translate_type("date")) }} AS note_date
    , {{ dbt.cast("null", api.Column.translate_type("timestamp")) }} AS note_datetime
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS note_type_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS note_class_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS note_title
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS note_text
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS encoding_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS language_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS provider_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS visit_occurrence_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS visit_detail_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS note_source_value
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS note_event_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS note_event_field_concept_id
WHERE 1 = 0
