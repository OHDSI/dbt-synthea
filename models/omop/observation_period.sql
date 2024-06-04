select
  row_number() over (order by person_id) as observation_period_id,
  person_id,
  start_date as observation_period_start_date,
  end_date as observation_period_end_date,
  32882 as period_type_concept_id
from (
  select
    p.person_id,
    min(e.encounter_start_datetime) as start_date,
    max(e.encounter_stop_datetime) as end_date
  from {{ ref ('person') }} as p
  inner join {{ ref ('stg_synthea__encounters') }} as e
    on p.person_source_value = e.patient_id
  group by p.person_id
) as tmp
