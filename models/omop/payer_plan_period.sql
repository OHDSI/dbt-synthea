select
  row_number() over (order by pat.patient_id, pt.coverage_start_year) as payer_plan_period_id,
  per.person_id as person_id,
  cast(concat(cast(pt.coverage_start_year as varchar), '01','01') as DATE) as payer_plan_period_start_date,
  cast(concat(cast(pt.coverage_end_year as varchar), '12','31') as DATE) as payer_plan_period_end_date,
  0 as payer_concept_id,
  pt.payer_id as payer_source_value,
  0 as payer_source_concept_id,
  0 as plan_concept_id,
  pay.payer_name as plan_source_value,
  0 as plan_source_concept_id,
  0 as sponsor_concept_id,
  cast(NULL as VARCHAR) as sponsor_source_value,
  0 as sponsor_source_concept_id,
  cast(NULL as VARCHAR) as family_source_value,
  0 as stop_reason_concept_id,
  cast(NULL as VARCHAR) as stop_reason_source_value,
  0 as stop_reason_source_concept_id
from {{ ref ('stg_synthea__payers') }} as pay
inner join {{ ref ('stg_synthea__payer_transitions') }} as pt
  on pay.payer_id = pt.payer_id
inner join {{ ref ('stg_synthea__patients') }} as pat
  on pt.patient_id = pat.patient_id
inner join {{ ref('person') }} as per
  on pat.patient_id = per.person_source_value
