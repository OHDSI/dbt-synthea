select
  {{ adapter.quote("concept_id_1") }},
  {{ adapter.quote("concept_id_2") }},
  {{ adapter.quote("relationship_id") }},
  {{ adapter.quote("valid_start_date") }},
  {{ adapter.quote("valid_end_date") }},
  {{ adapter.quote("invalid_reason") }}
from {{ source('vocab', 'concept_relationship') }}
