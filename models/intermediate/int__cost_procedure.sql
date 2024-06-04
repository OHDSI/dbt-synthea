select distinct
  po.procedure_occurrence_id as cost_event_id,
  'Procedure' as cost_domain_id,
  32814 as cost_type_concept_id,
  44818668 as currency_concept_id,
  e.total_encounter_cost + pr.procedure_base_cost as total_charge,
  e.total_encounter_cost + pr.procedure_base_cost as total_cost,
  e.encounter_payer_coverage + pr.procedure_base_cost as total_paid,
  e.encounter_payer_coverage as paid_by_payer,
  e.total_encounter_cost + pr.procedure_base_cost - e.encounter_payer_coverage as paid_by_patient,
  cast(null as numeric) as paid_patient_copay,
  cast(null as numeric) as paid_patient_coinsurance,
  cast(null as numeric) as paid_patient_deductible,
  cast(null as numeric) as paid_by_primary,
  cast(null as numeric) as paid_ingredient_cost,
  cast(null as numeric) as paid_dispensing_fee,
  ppp.payer_plan_period_id as payer_plan_period_id,
  cast(null as numeric) as amount_allowed,
  0 as revenue_code_concept_id,
  'UNKNOWN / UNKNOWN' as revenue_code_source_value,
  0 as drg_concept_id,
  '000' as drg_source_value
from {{ ref ('stg_synthea__procedures') }} as pr
inner join {{ ref ('stg_synthea__encounters') }} as e
  on
    pr.encounter_id = e.encounter_id
    and pr.patient_id = e.patient_id
inner join {{ ref ('person') }} as p
  on pr.patient_id = p.person_source_value
inner join
  {{ ref ('visit_occurrence') }}
    as vo
  on
    p.person_id = vo.person_id
    and e.encounter_id = vo.visit_source_value
inner join {{ ref ('procedure_occurrence') }} as po
  on
    pr.procedure_code = po.procedure_source_value
    and vo.visit_occurrence_id = po.visit_occurrence_id
    and vo.person_id = po.person_id
left join {{ ref ('payer_plan_period') }} as ppp
  on
    p.person_id = ppp.person_id
    and po.procedure_date >= ppp.payer_plan_period_start_date
    and po.procedure_date <= ppp.payer_plan_period_end_date
