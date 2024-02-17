select
  {{ adapter.quote("concept_id") }},
  {{ adapter.quote("concept_synonym_name") }},
  {{ adapter.quote("language_concept_id") }}
from {{ source('vocab', 'concept_synonym') }}
