select
  {{ adapter.quote("concept_class_id") }},
  {{ adapter.quote("concept_class_name") }},
  {{ adapter.quote("concept_class_concept_id") }}
from {{ source('vocab', 'concept_class') }}
