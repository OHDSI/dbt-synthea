select
  {{ adapter.quote("id") }},
  {{ adapter.quote("start") }},
  {{ adapter.quote("stop") }},
  {{ adapter.quote("patient") }},
  {{ adapter.quote("organization") }},
  {{ adapter.quote("provider") }},
  {{ adapter.quote("payer") }},
  {{ adapter.quote("encounterclass") }},
  {{ adapter.quote("code") }},
  {{ adapter.quote("description") }},
  {{ adapter.quote("base_encounter_cost") }},
  {{ adapter.quote("total_claim_cost") }},
  {{ adapter.quote("payer_coverage") }},
  {{ adapter.quote("reasoncode") }},
  {{ adapter.quote("reasondescription") }}
from {{ source('synthea', 'encounters') }}
