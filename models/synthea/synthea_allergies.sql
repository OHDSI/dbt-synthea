select
  {{ adapter.quote("start") }},
  {{ adapter.quote("stop") }},
  {{ adapter.quote("patient") }},
  {{ adapter.quote("encounter") }},
  {{ adapter.quote("code") }},
  {{ adapter.quote("description") }}
from {{ source('synthea', 'allergies') }}
