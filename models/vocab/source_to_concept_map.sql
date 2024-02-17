select
  {{ adapter.quote("SOURCE_CODE") }},
  {{ adapter.quote("SOURCE_CONCEPT_ID") }},
  {{ adapter.quote("SOURCE_VOCABULARY_ID") }},
  {{ adapter.quote("SOURCE_CODE_DESCRIPTION") }},
  {{ adapter.quote("TARGET_CONCEPT_ID") }},
  {{ adapter.quote("TARGET_VOCABULARY_ID") }},
  {{ adapter.quote("valid_start_date") }},
  {{ adapter.quote("valid_end_date") }},
  {{ adapter.quote("invalid_reason") }}
from {{ source('vocab', 'source_to_concept_map') }}
