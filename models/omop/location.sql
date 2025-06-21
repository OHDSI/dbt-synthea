SELECT
    location_id
    , {{ string_truncate("address_1", 50) }} AS address_1
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS address_2
    , {{ string_truncate("city", 50) }} AS city
    , state
    , zip
    , {{ string_truncate("county", 20) }} AS county
    , {{ string_truncate("location_source_value", 50) }} AS location_source_value
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS country_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS country_source_value
    , {{ dbt.cast("null", api.Column.translate_type("float")) }} AS latitude
    , {{ dbt.cast("null", api.Column.translate_type("float")) }} AS longitude
FROM {{ ref('int__location') }}
