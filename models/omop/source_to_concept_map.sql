SELECT
    {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS source_code
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS source_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS source_vocabulary_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS source_code_description
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS target_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS target_vocabulary_id
    , {{ dbt.cast("null", api.Column.translate_type("date")) }} AS valid_start_date
    , {{ dbt.cast("null", api.Column.translate_type("date")) }} AS valid_end_date
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS invalid_reason
WHERE false
