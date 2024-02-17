select
  row_number() over (order by person_id) as device_exposure_id,
  p.person_id as person_id,
  srctostdvm.target_concept_id as device_concept_id,
  d.start as device_exposure_start_date,
  d.start as device_exposure_start_datetime,
  d.stop as device_exposure_end_date,
  d.stop as device_exposure_end_datetime,
  32827 as device_type_concept_id,
  d.udi as unique_device_id,
  cast(null as varchar) as production_id,
  cast(null as int) as quantity,
  pr.provider_id as provider_id,
  fv.visit_occurrence_id_new as visit_occurrence_id,
  fv.visit_occurrence_id_new + 1000000 as visit_detail_id,
  d.code as device_source_value,
  srctosrcvm.source_concept_id as device_source_concept_id,
  cast(null as int) as unit_concept_id,
  cast(null as varchar) as unit_source_value,
  cast(null as int) as unit_source_concept_id
from {{ ref('synthea_devices') }} as d
inner join {{ ref ('source_to_standard_vocab_map') }} as srctostdvm
  on
    d.code = srctostdvm.source_code
    and srctostdvm.target_domain_id = 'Device'
    and srctostdvm.target_vocabulary_id = 'SNOMED'
    and srctostdvm.source_vocabulary_id = 'SNOMED'
    and srctostdvm.target_standard_concept = 'S'
    and srctostdvm.target_invalid_reason is null
inner join {{ ref ('source_to_source_vocab_map') }} as srctosrcvm
  on
    d.code = srctosrcvm.source_code
    and srctosrcvm.source_vocabulary_id = 'SNOMED'
left join {{ ref ('stg__final_visit_ids') }} as fv
  on d.encounter = fv.encounter_id
left join {{ ref('synthea_encounters') }} as e
  on
    d.encounter = e.id
    and d.patient = e.patient
left join {{ ref ('provider') }} as pr
  on e.provider = pr.provider_source_value
inner join {{ ref ('person') }} as p
  on d.patient = p.person_source_value
