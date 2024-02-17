select
  {{ adapter.quote("vocabulary_id") }},
  {{ adapter.quote("vocabulary_name") }},
  {{ adapter.quote("vocabulary_reference") }},
  {{ adapter.quote("vocabulary_version") }},
  {{ adapter.quote("vocabulary_concept_id") }}
from {{ source('vocab', 'vocabulary') }}
