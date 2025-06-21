SELECT
    person_id
    , gender_concept_id
    , year_of_birth
    , month_of_birth
    , day_of_birth
    , birth_datetime
    , race_concept_id
    , ethnicity_concept_id
    , location_id
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }}  AS provider_id
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }}  AS care_site_id
    , person_source_value
    , {{ string_truncate("gender_source_value", 50) }} AS gender_source_value
    , 0 AS gender_source_concept_id
    , {{ string_truncate("race_source_value", 50) }} AS race_source_value
    , 0 AS race_source_concept_id
    , {{ string_truncate("ethnicity_source_value", 50) }} AS ethnicity_source_value
    , 0 AS ethnicity_source_concept_id
FROM {{ ref('int__person') }}
