select
  {{ adapter.quote("date") }},
  {{ adapter.quote("patient") }},
  {{ adapter.quote("encounter") }},
  {{ adapter.quote("code") }},
  {{ adapter.quote("description") }},
  {{ adapter.quote("base_cost") }},
  {{ adapter.quote("reasoncode") }},
  {{ adapter.quote("reasondescription") }}
from {{ source('synthea', 'procedures') }}
