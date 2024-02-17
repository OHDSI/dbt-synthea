select
  {{ adapter.quote("ancestor_concept_id") }},
  {{ adapter.quote("descendant_concept_id") }},
  {{ adapter.quote("min_levels_of_separation") }},
  {{ adapter.quote("max_levels_of_separation") }}
from {{ source('vocab', 'concept_ancestor') }}
