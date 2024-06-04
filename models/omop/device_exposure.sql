select
  row_number() over (order by person_id) as device_exposure_id,
  p.person_id as person_id,
  srctostdvm.target_concept_id as device_concept_id,
  d.device_start_datetime as device_exposure_start_date,
  d.device_start_datetime as device_exposure_start_datetime,
  d.device_stop_datetime as device_exposure_end_date,
  d.device_stop_datetime as device_exposure_end_datetime,
  32827 as device_type_concept_id,
  d.udi as unique_device_id,
  cast(null as varchar) as production_id,
  cast(null as int) as quantity,
  pr.provider_id as provider_id,
  fv.visit_occurrence_id_new as visit_occurrence_id,
  fv.visit_occurrence_id_new + 1000000 as visit_detail_id,
  d.device_code as device_source_value,
  srctosrcvm.source_concept_id as device_source_concept_id,
  cast(null as int) as unit_concept_id,
  cast(null as varchar) as unit_source_value,
  cast(null as int) as unit_source_concept_id
from {{ ref('stg_synthea__devices') }} as d
inner join {{ ref ('int__source_to_standard_vocab_map') }} as srctostdvm
  on
    d.device_code = srctostdvm.source_code
    and srctostdvm.target_domain_id = 'Device'
    and srctostdvm.target_vocabulary_id = 'SNOMED'
    and srctostdvm.source_vocabulary_id = 'SNOMED'
    and srctostdvm.target_standard_concept = 'S'
    and srctostdvm.target_invalid_reason is null
inner join {{ ref ('int__source_to_source_vocab_map') }} as srctosrcvm
  on
    d.device_code = srctosrcvm.source_code
    and srctosrcvm.source_vocabulary_id = 'SNOMED'
left join {{ ref ('int__final_visit_ids') }} as fv
  on d.encounter_id = fv.encounter_id
left join {{ ref('stg_synthea__encounters') }} as e
  on
    d.encounter_id = e.encounter_id
    and d.patient_id = e.patient_id
left join {{ ref ('provider') }} as pr
  on e.provider_id = pr.provider_source_value
inner join {{ ref ('person') }} as p
  on d.patient_id = p.person_source_value
