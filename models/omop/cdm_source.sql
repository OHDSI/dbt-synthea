SELECT
    '@cdm_source_name' AS cdm_source_name
    , '@cdm_source_abbreviation' AS cdm_source_abbreviation
    , '@cdm_holder' AS cdm_holder
    , '@source_description' AS source_description
    , 'https://synthetichealth.github.io/synthea/' AS source_documentation_reference
    , 'https://github.com/OHDSI/ETL-Synthea' AS cdm_etl_reference
    , current_date AS source_release_date
    , current_date AS cdm_release_date
    , '@cdm_version' AS cdm_version
    , vocabulary_version
    , 75626 AS cdm_version_concept_id
FROM {{ ref('stg_vocabulary__vocabulary') }}
WHERE vocabulary_id = 'None'
