with all_drugs as (
  select * from {{ ref('int__drug_medications') }}
  union all
  select * from {{ ref('int__drug_immunisations') }}
)
select
  row_number() over (order by p.person_id) as drug_exposure_id,
  p.person_id,
  drug_concept_id,
  drug_exposure_start_date,
  drug_exposure_start_datetime,
  drug_exposure_end_date,
  drug_exposure_end_datetime,
  verbatim_end_date,
  drug_type_concept_id,
  stop_reason,
  refills,
  quantity,
  days_supply,
  sig,
  route_concept_id,
  lot_number,
  pr.provider_id as provider_id,
  fv.visit_occurrence_id_new as visit_occurrence_id,
  fv.visit_occurrence_id_new + 1000000 as visit_detail_id,
  drug_source_value,
  drug_source_concept_id,
  route_source_value,
  dose_unit_source_value
from 
  all_drugs as ad
  left join {{ ref ('int__final_visit_ids') }} as fv
    on ad.encounter_id = fv.encounter_id
  left join {{ ref ('stg_synthea__encounters') }} as e
    on
      ad.encounter_id = e.encounter_id
      and ad.patient_id = e.patient_id
  left join {{ ref ('provider') }} as pr
    on e.provider_id = pr.provider_source_value
  inner join {{ ref ('person') }} as p
    on ad.patient_id = p.person_source_value