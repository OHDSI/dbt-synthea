SELECT
    ROW_NUMBER() OVER (ORDER BY organization_id) AS care_site_id
    , organization_name AS care_site_name
    , 0 AS place_of_service_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS location_id
    , organization_id AS care_site_source_value
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS place_of_service_source_value
FROM {{ ref('stg_synthea__organizations') }}
