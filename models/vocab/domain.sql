select
  {{ adapter.quote("domain_id") }},
  {{ adapter.quote("domain_name") }},
  {{ adapter.quote("domain_concept_id") }}
from {{ source('vocab', 'domain') }}
