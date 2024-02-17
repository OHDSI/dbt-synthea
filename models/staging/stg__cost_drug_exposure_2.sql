select distinct
  de.drug_exposure_id as cost_event_id,
  'Drug' as cost_domain_id,
  32814 as cost_type_concept_id,
  44818668 as currency_concept_id,
  e.total_claim_cost + m.base_cost as total_charge,
  e.total_claim_cost + m.base_cost as total_cost,
  e.payer_coverage + m.base_cost as total_paid,
  e.payer_coverage as paid_by_payer,
  e.total_claim_cost + m.base_cost - e.payer_coverage as paid_by_patient,
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
from {{ ref ('synthea_medications') }} as m
inner join {{ ref ('synthea_encounters') }} as e
  on
    m.encounter = e.id
    and m.patient = e.patient
inner join {{ ref ('person') }} as p
  on m.patient = p.person_source_value
inner join {{ ref ('visit_occurrence') }} as vo
  on
    p.person_id = vo.person_id
    and e.id = vo.visit_source_value
inner join {{ ref ('drug_exposure') }} as de
  on
    m.code = de.drug_source_value
    and vo.visit_occurrence_id = de.visit_occurrence_id
    and vo.person_id = de.person_id
left join {{ ref ('payer_plan_period') }} as ppp
  on
    p.person_id = ppp.person_id
    and de.drug_exposure_start_date >= ppp.payer_plan_period_start_date
    and de.drug_exposure_start_date <= ppp.payer_plan_period_end_date
