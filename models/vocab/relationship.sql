select
  {{ adapter.quote("relationship_id") }},
  {{ adapter.quote("relationship_name") }},
  {{ adapter.quote("is_hierarchical") }},
  {{ adapter.quote("defines_ancestry") }},
  {{ adapter.quote("reverse_relationship_id") }},
  {{ adapter.quote("relationship_concept_id") }}
from {{ source('vocab', 'relationship') }}
