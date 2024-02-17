select
  {{ adapter.quote("id") }},
  {{ adapter.quote("organization") }},
  {{ adapter.quote("name") }},
  {{ adapter.quote("gender") }},
  {{ adapter.quote("speciality") }},
  {{ adapter.quote("address") }},
  {{ adapter.quote("city") }},
  {{ adapter.quote("state") }},
  {{ adapter.quote("zip") }},
  {{ adapter.quote("lat") }},
  {{ adapter.quote("lon") }},
  {{ adapter.quote("utilization") }}
from {{ source('synthea', 'providers') }}
