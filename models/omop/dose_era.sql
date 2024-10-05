SELECT
    {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS dose_era_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS person_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS drug_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS unit_concept_id
    , {{ dbt.cast('null', api.Column.translate_type("decimal")) }} AS dose_value
    , {{ dbt.cast('null', api.Column.translate_type("date")) }} AS dose_era_start_date
    , {{ dbt.cast('null', api.Column.translate_type("date")) }} AS dose_era_end_date
WHERE 1 = 0
