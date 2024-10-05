SELECT
    ROW_NUMBER() OVER () AS location_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS address_1
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS address_2
    , p.patient_city AS city
    , s.state_abbreviation AS state
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS county
    , p.patient_zip AS zip
    , p.patient_zip AS location_source_value
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS country_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS country_source_value
    , {{ dbt.cast("null", api.Column.translate_type("decimal")) }} AS latitude
    , {{ dbt.cast("null", api.Column.translate_type("decimal")) }} AS longitude
FROM {{ ref('stg_synthea__patients') }} AS p
LEFT JOIN {{ ref('stg_map__states') }} AS s ON p.patient_state = s.state_name
