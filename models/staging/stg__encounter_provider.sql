{# This bit of SQL gets reused several times in the OMOP layer #}
select
  e.patient,
  e.id,
  pr.provider_id
from {{ ref ('synthea_encounters') }} as e
inner join {{ ref ('provider') }} as pr
  on e.provider = pr.provider_source_value
