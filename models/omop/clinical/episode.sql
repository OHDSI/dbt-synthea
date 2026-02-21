SELECT
    {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS episode_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS person_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS episode_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("date")) }} AS episode_start_date
    , {{ dbt.cast("null", api.Column.translate_type("timestamp")) }} AS episode_start_datetime
    , {{ dbt.cast("null", api.Column.translate_type("date")) }} AS episode_end_date
    , {{ dbt.cast("null", api.Column.translate_type("timestamp")) }} AS episode_end_datetime
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS episode_parent_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS episode_number
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS episode_object_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS episode_type_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS episode_source_value
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS episode_source_concept_id
WHERE 1 = 0
