SELECT
    row_number() OVER (ORDER BY state, city, address_1) AS location_id
    , address_1
    , address_2
    , city
    , state
    , zip
    , county
    , location_source_value
    , country_concept_id
    , country_source_value
    , latitude
    , longitude
FROM {{ ref('int__locations') }}
