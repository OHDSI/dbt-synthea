with cte as (
  select
    co.condition_occurrence_id,
    ppp.payer_plan_period_id,
    coalesce(sum(case when ct.transfer_type = '1' then ct.transaction_amount end), 0)
      as payer_paid,
    coalesce(sum(case when ct.transfer_type = 'p' then ct.transaction_amount end), 0)
      as patient_paid
  from {{ ref ('stg_synthea__conditions') }} as cn
  inner join {{ ref ('stg_synthea__encounters') }} as e
    on
      cn.encounter_id = e.encounter_id
      and cn.patient_id = e.patient_id
  inner join {{ ref ('person') }} as p
    on cn.patient_id = p.person_source_value
  inner join {{ ref ('visit_occurrence') }} as vo
    on
      p.person_id = vo.person_id
      and e.patient_id = vo.visit_source_value
  inner join {{ ref ('condition_occurrence') }} as co
    on
      cn.condition_code = co.condition_source_value
      and vo.visit_occurrence_id = co.visit_occurrence_id
      and vo.person_id = co.person_id
  left join {{ ref ('payer_plan_period') }} as ppp
    on
      p.person_id = ppp.person_id
      and co.condition_start_date >= ppp.payer_plan_period_start_date
      and co.condition_start_date <= ppp.payer_plan_period_end_date
  inner join {{ ref ('stg_synthea__claims') }} as ca
    on
      cn.patient_id = ca.patient_id
      and cn.condition_code = ca.diagnosis_1
      and cn.condition_start_date = ca.current_illness_date
      and e.encounter_id = ca.encounter_id
      and e.provider_id = ca.provider_id
      and e.payer_id = ca.primary_patient_insurance_id
      and e.encounter_start_datetime = ca.service_date
  inner join {{ ref ('stg_synthea__claims_transactions') }} as ct
    on
      ca.claim_id = ct.claim_id
      and cn.patient_id = ct.patient_id
      and e.encounter_id = ct.encounter_id
      and e.provider_id = ct.provider_id
  where ct.transfer_type in ('1', 'p')
  group by co.condition_occurrence_id, ppp.payer_plan_period_id
)

select
  condition_occurrence_id as cost_event_id,
  'condition' as cost_domain_id,
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
  'unknown / unknown' as revenue_code_source_value,
  0 as drg_concept_id,
  '000' as drg_source_value
from cte
