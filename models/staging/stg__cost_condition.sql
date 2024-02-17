with cte as (
  select
    co.condition_occurrence_id,
    ppp.payer_plan_period_id,
    coalesce(sum(case when ct.transfertype = '1' then ct.amount end), 0)
      as payer_paid,
    coalesce(sum(case when ct.transfertype = 'p' then ct.amount end), 0)
      as patient_paid
  from {{ ref ('synthea_conditions') }} as cn
  inner join {{ ref ('synthea_encounters') }} as e
    on
      cn.encounter = e.id
      and cn.patient = e.patient
  inner join {{ ref ('person') }} as p
    on cn.patient = p.person_source_value
  inner join {{ ref ('visit_occurrence') }} as vo
    on
      p.person_id = vo.person_id
      and e.id = vo.visit_source_value
  inner join {{ ref ('condition_occurrence') }} as co
    on
      cn.code = co.condition_source_value
      and vo.visit_occurrence_id = co.visit_occurrence_id
      and vo.person_id = co.person_id
  left join {{ ref ('payer_plan_period') }} as ppp
    on
      p.person_id = ppp.person_id
      and co.condition_start_date >= ppp.payer_plan_period_start_date
      and co.condition_start_date <= ppp.payer_plan_period_end_date
  inner join {{ ref ('synthea_claims') }} as ca
    on
      cn.patient = ca.patientid
      and cn.code = ca.diagnosis1
      and cn.start = ca.currentillnessdate
      and e.id = ca.appointmentid
      and e.provider = ca.providerid
      and e.payer = ca.primarypatientinsuranceid
      and e.start = ca.servicedate
  inner join {{ ref ('synthea_claims_transactions') }} as ct
    on
      ca.id = ct.claimid
      and cn.patient = ct.patientid
      and e.id = ct.appointmentid
      and e.provider = ct.providerid
  where ct.transfertype in ('1', 'p')
  group by co.condition_occurrence_id, ppp.payer_plan_period_id
)

select
  condition_occurrence_id as cost_event_id,
  'Condition' as cost_domain_id,
  32814 as cost_type_concept_id,
  44818668 as currency_concept_id,
  payer_paid + patient_paid as total_charge,
  payer_paid + patient_paid as total_cost,
  payer_paid + patient_paid as total_paid,
  payer_paid as paid_by_payer,
  patient_paid as paid_by_patient,
  cast(null as numeric) as paid_patient_copay,
  cast(null as numeric) as paid_patient_coinsurance,
  cast(null as numeric) as paid_patient_deductible,
  payer_paid as paid_by_primary,
  cast(null as numeric) as paid_ingredient_cost,
  cast(null as numeric) as paid_dispensing_fee,
  payer_plan_period_id as payer_plan_period_id,
  cast(null as numeric) as amount_allowed,
  0 as revenue_code_concept_id,
  'UNKNOWN / UNKNOWN' as revenue_code_source_value,
  0 as drg_concept_id,
  '000' as drg_source_value
from cte
