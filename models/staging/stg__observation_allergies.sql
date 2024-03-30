select
  a.patient,
  a.encounter,
  srctostdvm.target_concept_id as observation_concept_id,
  a.start as observation_date,
  a.start as observation_datetime,
  32827 as observation_type_concept_id,
  a.code as observation_source_value,
  srctosrcvm.source_concept_id as observation_source_concept_id
from {{ ref ('synthea_allergies') }} as a
inner join {{ ref ('source_to_standard_vocab_map') }} as srctostdvm
  on
    a.code = srctostdvm.source_code
    and srctostdvm.target_domain_id = 'Observation'
    and srctostdvm.target_vocabulary_id = 'SNOMED'
    and srctostdvm.target_standard_concept = 'S'
    and srctostdvm.target_invalid_reason is null
inner join {{ ref ('source_to_source_vocab_map') }} as srctosrcvm
  on
    a.code = srctosrcvm.source_code
    and srctosrcvm.source_vocabulary_id = 'SNOMED'
    and srctosrcvm.source_domain_id = 'Observation'
