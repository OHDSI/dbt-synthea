{% set address_columns = [
    "address_1", 
    "city",
    "state",
    "zip",
    "county"
] %}

WITH unioned_location_sources AS (
    SELECT DISTINCT
        p.patient_address AS address_1
        , p.patient_city AS city
        , s.state_abbreviation AS state
        , p.patient_zip AS zip
        , p.patient_county AS county
    FROM {{ ref("stg_synthea__patients") }} AS p
    LEFT JOIN {{ ref('stg_map__states') }} AS s ON p.patient_state = s.state_name

    UNION

    SELECT DISTINCT
        organization_address AS address_1
        , organization_city AS city
        , organization_state AS state
        , organization_zip AS zip
        , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS county
    FROM
        {{ ref("stg_synthea__organizations") }}
)

SELECT
    row_number() OVER (ORDER BY state, city, address_1) AS location_id
    , address_1
    , city
    , state
    , zip
    , county
    , {{ safe_hash(address_columns) }} AS location_source_value
FROM unioned_location_sources
