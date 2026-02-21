SELECT
    {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS episode_event_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS episode_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS event_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS episode_event_field_concept_id
WHERE 1 = 0
