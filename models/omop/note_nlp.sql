SELECT
    {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS note_nlp_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS note_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS section_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS snippet
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS {{ adapter.quote("offset") }}
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS lexical_variant
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS note_nlp_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS note_nlp_source_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS nlp_system
    , {{ dbt.cast("null", api.Column.translate_type("date")) }} AS nlp_date
    , {{ dbt.cast("null", api.Column.translate_type("timestamp")) }} AS nlp_datetime
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS term_exists
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS term_temporal
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS term_modifiers
WHERE 1 = 0
