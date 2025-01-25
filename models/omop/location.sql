SELECT
    location_id
    , address_1
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS address_2
    , city
    , state
    , zip
    , county
    , location_source_value
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS country_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS country_source_value
    , {{ dbt.cast("null", api.Column.translate_type("decimal")) }} AS latitude
    , {{ dbt.cast("null", api.Column.translate_type("decimal")) }} AS longitude
FROM {{ ref('int__location') }}
