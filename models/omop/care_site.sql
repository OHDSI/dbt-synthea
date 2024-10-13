{% set address_columns = [
    "organization_address",
    "organization_city",
    "organization_state",
    "organization_zip",
] %}

SELECT
    ROW_NUMBER() OVER (ORDER BY organization_id) AS care_site_id
    , organization_name AS care_site_name
    , 0 AS place_of_service_concept_id
    , loc.location_id
    , organization_id AS care_site_source_value
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS place_of_service_source_value
FROM {{ ref('stg_synthea__organizations') }}
LEFT JOIN {{ ref('location') }} AS loc
    ON
        loc.location_source_value = {{ safe_hash(address_columns) }}
