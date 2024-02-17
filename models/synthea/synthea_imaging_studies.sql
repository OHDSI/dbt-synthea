select
  {{ adapter.quote("id") }},
  {{ adapter.quote("date") }},
  {{ adapter.quote("patient") }},
  {{ adapter.quote("encounter") }},
  {{ adapter.quote("series_uid") }},
  {{ adapter.quote("bodysite_code") }},
  {{ adapter.quote("bodysite_description") }},
  {{ adapter.quote("modality_code") }},
  {{ adapter.quote("modality_description") }},
  {{ adapter.quote("instance_uid") }},
  {{ adapter.quote("SOP_code") }},
  {{ adapter.quote("SOP_description") }},
  {{ adapter.quote("procedure_code") }}
from {{ source('synthea', 'imaging_studies') }}
