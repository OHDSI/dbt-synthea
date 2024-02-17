select
  row_number() over (order by pat.id, pt.start_year) as payer_plan_period_id,
  per.person_id as person_id,
  cast(pt.start_year as DATE) as payer_plan_period_start_date,
  cast(pt.end_year as DATE) as payer_plan_period_end_date,
  0 as payer_concept_id,
  pt.payer as payer_source_value,
  0 as payer_source_concept_id,
  0 as plan_concept_id,
  pay.name as plan_source_value,
  0 as plan_source_concept_id,
  0 as sponsor_concept_id,
  cast(NULL as VARCHAR) as sponsor_source_value,
  0 as sponsor_source_concept_id,
  cast(NULL as VARCHAR) as family_source_value,
  0 as stop_reason_concept_id,
  cast(NULL as VARCHAR) as stop_reason_source_value,
  0 as stop_reason_source_concept_id
from {{ ref ('synthea_payers') }} as pay
inner join {{ ref ('synthea_payer_transitions') }} as pt
  on pay.id = pt.payer
inner join {{ ref ('synthea_patients') }} as pat
  on pt.patient = pat.id
inner join {{ ref('person') }} as per
  on pat.id = per.person_source_value
