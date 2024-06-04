select
  row_number() over (order by p.person_id) as condition_occurrence_id,
  p.person_id as person_id,
  srctostdvm.target_concept_id as condition_concept_id,
  c.condition_start_date as condition_start_date,
  c.condition_start_date as condition_start_datetime,
  c.condition_stop_date as condition_end_date,
  c.condition_stop_date as condition_end_datetime,
  32827 as condition_type_concept_id,
  cast(null as varchar) as stop_reason,
  pr.provider_id as provider_id,
  fv.visit_occurrence_id_new as visit_occurrence_id,
  fv.visit_occurrence_id_new + 1000000 as visit_detail_id,
  c.condition_code as condition_source_value,
  srctosrcvm.source_concept_id as condition_source_concept_id,
  null as condition_status_source_value,
  0 as condition_status_concept_id
from {{ ref('stg_synthea__conditions') }} as c
inner join {{ ref ('int__source_to_standard_vocab_map') }} as srctostdvm
  on
    c.condition_code = srctostdvm.source_code
    and srctostdvm.target_domain_id = 'Condition'
    and srctostdvm.target_vocabulary_id = 'SNOMED'
    and srctostdvm.source_vocabulary_id = 'SNOMED'
    and srctostdvm.target_standard_concept = 'S'
    and srctostdvm.target_invalid_reason is null
inner join {{ ref ('int__source_to_source_vocab_map') }} as srctosrcvm
  on
    c.condition_code = srctosrcvm.source_code
    and srctosrcvm.source_vocabulary_id = 'SNOMED'
    and srctosrcvm.source_domain_id = 'Condition'
left join {{ ref ('int__final_visit_ids') }} as fv
  on c.encounter_id = fv.encounter_id
left join {{ ref('stg_synthea__encounters') }} as e
  on
    c.encounter_id = e.encounter_id
    and c.patient_id = e.patient_id
left join {{ ref ('provider') }} as pr
  on e.provider_id = pr.provider_source_value
inner join {{ ref ('person') }} as p
  on c.patient_id = p.person_source_value
