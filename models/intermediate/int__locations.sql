{% set address_columns = [
    "address_1", 
    "address_2",
    "city",
    "state",
    "zip",
    "county"
    ]
%}

WITH unioned_location_sources AS (
    SELECT DISTINCT
        p.patient_address AS address_1
        , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS address_2
        , p.patient_city AS city
        , s.state_abbreviation AS state
        , p.patient_zip AS zip
        , p.patient_county AS county
        , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS country_concept_id
        , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS country_source_value
        , p.patient_latitude AS latitude
        , p.patient_longitude AS longitude
    FROM {{ ref("stg_synthea__patients") }} AS p
    LEFT JOIN {{ ref('stg_map__states') }} AS s ON p.patient_state = s.state_name

    UNION

    SELECT DISTINCT
        organization_address AS address_1
        , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS address_2
        , organization_city AS city
        , organization_state AS state
        , organization_zip AS zip
        , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS county
        , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS country_concept_id
        , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS country_source_value
        , organization_latitude AS latitude
        , organization_longitude AS longitude
    FROM
        {{ ref("stg_synthea__organizations") }}
)

SELECT
    address_1
    , address_2
    , city
    , state
    , zip
    , county
    , md5(
        {%- for col in address_columns -%}
        coalesce({{col}}, '') {{ "|| " if not loop.last }}
        {%- endfor -%}
    ) AS location_source_value
    , country_concept_id
    , country_source_value
    , latitude
    , longitude
FROM unioned_location_sources
