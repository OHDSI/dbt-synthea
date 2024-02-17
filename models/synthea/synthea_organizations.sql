select
  {{ adapter.quote("id") }},
  {{ adapter.quote("name") }},
  {{ adapter.quote("address") }},
  {{ adapter.quote("city") }},
  {{ adapter.quote("state") }},
  {{ adapter.quote("zip") }},
  {{ adapter.quote("lat") }},
  {{ adapter.quote("lon") }},
  {{ adapter.quote("phone") }},
  {{ adapter.quote("revenue") }},
  {{ adapter.quote("utilization") }}
from {{ source('synthea', 'organizations') }}
