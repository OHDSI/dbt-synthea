select
  {{ adapter.quote("date") }},
  {{ adapter.quote("patient") }},
  {{ adapter.quote("encounter") }},
  {{ adapter.quote("code") }},
  {{ adapter.quote("description") }},
  {{ adapter.quote("value") }},
  {{ adapter.quote("units") }},
  {{ adapter.quote("type") }}
from {{ source('synthea', 'observations') }}
