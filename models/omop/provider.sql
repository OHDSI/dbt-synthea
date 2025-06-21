SELECT
    provider_id
    , {{ string_truncate("provider_name", 255) }} AS provider_name
    , {{ dbt.cast("null", api.Column.translate_type("varchar(20)")) }} AS npi
    , {{ dbt.cast("null", api.Column.translate_type("varchar(20)")) }} AS dea
    , 0 AS specialty_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS care_site_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS year_of_birth
    , gender_concept_id
    , provider_source_value
    , {{ string_truncate("specialty_source_value", 50) }} AS specialty_source_value
    , 0 AS specialty_source_concept_id
    , gender_source_value
    , gender_source_concept_id
FROM {{ ref( 'int__provider') }}
