select
  o.patient_id,
  o.encounter_id,
  srctostdvm.target_concept_id as observation_concept_id,
  o.observation_datetime as observation_date,
  o.observation_datetime as observation_datetime,
  38000280 as observation_type_concept_id,
  o.observation_code as observation_source_value,
  srctosrcvm.source_concept_id as observation_source_concept_id
from {{ ref ('stg_synthea__observations') }} as o
inner join {{ ref ('int__source_to_standard_vocab_map') }} as srctostdvm
  on
    o.observation_code = srctostdvm.source_code
    and srctostdvm.target_domain_id = 'Observation'
    and srctostdvm.target_vocabulary_id = 'LOINC'
    and srctostdvm.target_standard_concept = 'S'
    and srctostdvm.target_invalid_reason is null
inner join {{ ref ('int__source_to_source_vocab_map') }} as srctosrcvm
  on
    o.observation_code = srctosrcvm.source_code
    and srctosrcvm.source_vocabulary_id = 'LOINC'
    and srctosrcvm.source_domain_id = 'Observation'
