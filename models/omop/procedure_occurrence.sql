select
  row_number() over (order by p.person_id) as procedure_occurrence_id,
  p.person_id as person_id,
  srctostdvm.target_concept_id as procedure_concept_id,
  e.start as procedure_date,
  e.start as procedure_datetime,
  e.stop as procedure_end_date,
  e.stop as procedure_end_datetime,
  32827 as procedure_type_concept_id,
  0 as modifier_concept_id,
  cast(null as integer) as quantity,
  prv.provider_id as provider_id,
  fv.visit_occurrence_id_new as visit_occurrence_id,
  fv.visit_occurrence_id_new + 1000000 as visit_detail_id,
  pr.code as procedure_source_value,
  srctosrcvm.source_concept_id as procedure_source_concept_id,
  null as modifier_source_value
from {{ ref( 'synthea_procedures') }} as pr
inner join {{ ref( 'source_to_standard_vocab_map') }} as srctostdvm
  on
    pr.code = srctostdvm.source_code
    and srctostdvm.target_domain_id = 'Procedure'
    and srctostdvm.target_vocabulary_id = 'SNOMED'
    and srctostdvm.source_vocabulary_id = 'SNOMED'
    and srctostdvm.target_standard_concept = 'S'
    and srctostdvm.target_invalid_reason is null
inner join {{ ref( 'source_to_source_vocab_map') }} as srctosrcvm
  on
    pr.code = srctosrcvm.source_code
    and srctosrcvm.source_vocabulary_id = 'SNOMED'
left join {{ ref( 'stg__final_visit_ids') }} as fv
  on pr.encounter = fv.encounter_id
left join {{ ref( 'synthea_encounters') }} as e
  on
    pr.encounter = e.id
    and pr.patient = e.patient
left join {{ ref( 'provider') }} as prv
  on e.provider = prv.provider_source_value
inner join {{ ref( 'person') }} as p
  on pr.patient = p.person_source_value
