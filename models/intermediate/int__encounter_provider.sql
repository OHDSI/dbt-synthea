{# This bit of SQL gets reused several times in the OMOP layer #}
select
  e.patient_id,
  e.encounter_id,
  pr.provider_id
from {{ ref ('stg_synthea__encounters') }} as e
inner join {{ ref ('provider') }} as pr
  on e.provider_id = pr.provider_source_value
