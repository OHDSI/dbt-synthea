select
  {{ adapter.quote("concept_id") }},
  {{ adapter.quote("concept_name") }},
  {{ adapter.quote("domain_id") }},
  {{ adapter.quote("vocabulary_id") }},
  {{ adapter.quote("concept_class_id") }},
  {{ adapter.quote("standard_concept") }},
  {{ adapter.quote("concept_code") }},
  {{ adapter.quote("valid_start_date") }},
  {{ adapter.quote("valid_end_date") }},
  {{ adapter.quote("invalid_reason") }}
from {{ source('vocab', 'concept') }}
