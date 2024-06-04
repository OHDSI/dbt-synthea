select
  row_number() over (order by p.person_id) as procedure_occurrence_id,
  p.person_id as person_id,
  srctostdvm.target_concept_id as procedure_concept_id,
  e.encounter_start_datetime as procedure_date,
  e.encounter_start_datetime as procedure_datetime,
  e.encounter_stop_datetime as procedure_end_date,
  e.encounter_stop_datetime as procedure_end_datetime,
  32827 as procedure_type_concept_id,
  0 as modifier_concept_id,
  cast(null as integer) as quantity,
  prv.provider_id as provider_id,
  fv.visit_occurrence_id_new as visit_occurrence_id,
  fv.visit_occurrence_id_new + 1000000 as visit_detail_id,
  pr.procedure_code as procedure_source_value,
  srctosrcvm.source_concept_id as procedure_source_concept_id,
  null as modifier_source_value
from {{ ref( 'stg_synthea__procedures') }} as pr
inner join {{ ref( 'int__source_to_standard_vocab_map') }} as srctostdvm
  on
    pr.procedure_code = srctostdvm.source_code
    and srctostdvm.target_domain_id = 'Procedure'
    and srctostdvm.target_vocabulary_id = 'SNOMED'
    and srctostdvm.source_vocabulary_id = 'SNOMED'
    and srctostdvm.target_standard_concept = 'S'
    and srctostdvm.target_invalid_reason is null
inner join {{ ref( 'int__source_to_source_vocab_map') }} as srctosrcvm
  on
    pr.procedure_code = srctosrcvm.source_code
    and srctosrcvm.source_vocabulary_id = 'SNOMED'
left join {{ ref( 'int__final_visit_ids') }} as fv
  on pr.encounter_id = fv.encounter_id
left join {{ ref( 'stg_synthea__encounters') }} as e
  on
    pr.encounter_id = e.encounter_id
    and pr.patient_id = e.patient_id
left join {{ ref( 'provider') }} as prv
  on e.provider_id = prv.provider_source_value
inner join {{ ref( 'person') }} as p
  on pr.patient_id = p.person_source_value
