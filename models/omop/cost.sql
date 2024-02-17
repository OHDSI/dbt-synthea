with all_costs as (

  select * from {{ ref('stg__cost_condition') }}
  union all
  select * from {{ ref('stg__cost_drug_exposure_1') }}
  union all
  select * from {{ ref('stg__cost_drug_exposure_2') }}
  union all
  select * from {{ ref('stg__cost_procedure') }}
)

select
  row_number() over (order by ac.cost_event_id) as cost_id,
  ac.cost_event_id,
  ac.cost_domain_id,
  ac.cost_type_concept_id,
  ac.currency_concept_id,
  ac.total_charge,
  ac.total_cost,
  ac.total_paid,
  ac.paid_by_payer,
  ac.paid_by_patient,
  ac.paid_patient_copay,
  ac.paid_patient_coinsurance,
  ac.paid_patient_deductible,
  ac.paid_by_primary,
  ac.paid_ingredient_cost,
  ac.paid_dispensing_fee,
  ac.payer_plan_period_id,
  ac.amount_allowed,
  ac.revenue_code_concept_id,
  ac.revenue_code_source_value,
  ac.drg_concept_id,
  ac.drg_source_value
from all_costs as ac
