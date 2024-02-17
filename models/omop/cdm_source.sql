select
  '@cdm_source_name' as cdm_source_name,
  '@cdm_source_abbreviation' as cdm_source_abbreviation,
  '@cdm_holder' as cdm_holder,
  '@source_description' as source_description,
  'https://synthetichealth.github.io/synthea/'
    as source_documentation_reference,
  'https://github.com/OHDSI/ETL-Synthea' as cdm_etl_reference,
  getdate() as source_release_date,
  getdate() as cdm_release_date,
  '@cdm_version' as cdm_version,
  vocabulary_version as vocabulary_version,
  75626 as cdm_version_concept_id
from {{ ref('vocabulary') }}
where vocabulary_id = 'None'
