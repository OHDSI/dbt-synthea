SELECT
    {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS metadata_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS metadata_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS metadata_type_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS {{ adapter.quote("name") }}
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS value_as_string
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS value_as_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("decimal")) }} AS value_as_number
    , {{ dbt.cast("null", api.Column.translate_type("date")) }} AS metadata_date
    , {{ dbt.cast("null", api.Column.translate_type("timestamp")) }} AS metadata_datetime
WHERE 1 = 0
