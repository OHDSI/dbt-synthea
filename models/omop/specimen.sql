SELECT
    {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS specimen_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS person_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS specimen_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS specimen_type_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("date")) }} AS specimen_date
    , {{ dbt.cast("null", api.Column.translate_type("timestamp")) }} AS specimen_datetime
    , {{ dbt.cast("null", api.Column.translate_type("decimal")) }} AS quantity
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS unit_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS anatomic_site_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS disease_status_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS specimen_source_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS specimen_source_value
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS unit_source_value
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS anatomic_site_source_value
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS disease_status_source_value
WHERE 1 = 0
