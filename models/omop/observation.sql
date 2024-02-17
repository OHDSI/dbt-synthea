select
  row_number() over (order by person_id) as observation_id,
  person_id,
  observation_concept_id,
  observation_date,
  observation_datetime,
  observation_type_concept_id,
  value_as_number,
  value_as_string,
  value_as_concept_id,
  qualifier_concept_id,
  unit_concept_id,
  provider_id,
  visit_occurrence_id,
  visit_detail_id,
  observation_source_value,
  observation_source_concept_id,
  unit_source_value,
  qualifier_source_value,
  value_source_value,
  observation_event_id,
  obs_event_field_concept_id

from (
  select
    p.person_id as person_id,
    srctostdvm.target_concept_id as observation_concept_id,
    a.start as observation_date,
    a.start as observation_datetime,
    32827 as observation_type_concept_id,
    cast(null as float) as value_as_number,
    cast(null as varchar) as value_as_string,
    0 as value_as_concept_id,
    0 as qualifier_concept_id,
    0 as unit_concept_id,
    pr.provider_id as provider_id,
    fv.visit_occurrence_id_new as visit_occurrence_id,
    fv.visit_occurrence_id_new + 1000000 as visit_detail_id,
    a.code as observation_source_value,
    srctosrcvm.source_concept_id as observation_source_concept_id,
    cast(null as varchar) as unit_source_value,
    cast(null as varchar) as qualifier_source_value,
    cast(null as varchar) as value_source_value,
    cast(null as bigint) as observation_event_id,
    cast(null as int) as obs_event_field_concept_id
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
  left join {{ ref ('stg__final_visit_ids') }} as fv
    on a.encounter = fv.encounter_id
  left join {{ ref ('synthea_encounters') }} as e
    on
      a.encounter = e.id
      and a.patient = e.patient
  left join {{ ref ('provider') }} as pr
    on e.provider = pr.provider_source_value
  inner join {{ ref ('person') }} as p
    on a.patient = p.person_source_value

  union all

  select
    p.person_id as person_id,
    srctostdvm.target_concept_id as observation_concept_id,
    c.start as observation_date,
    c.start as observation_datetime,
    38000280 as observation_type_concept_id,
    cast(null as float) as value_as_number,
    cast(null as varchar) as value_as_string,
    0 as value_as_concept_id,
    0 as qualifier_concept_id,
    0 as unit_concept_id,
    pr.provider_id as provider_id,
    fv.visit_occurrence_id_new as visit_occurrence_id,
    fv.visit_occurrence_id_new + 1000000 as visit_detail_id,
    c.code as observation_source_value,
    srctosrcvm.source_concept_id as observation_source_concept_id,
    cast(null as varchar) as unit_source_value,
    cast(null as varchar) as qualifier_source_value,
    cast(null as varchar) as value_source_value,
    cast(null as bigint) as observation_event_id,
    cast(null as int) as obs_event_field_concept_id

  from {{ ref ('synthea_conditions') }} as c
  inner join {{ ref ('source_to_standard_vocab_map') }} as srctostdvm
    on
      c.code = srctostdvm.source_code
      and srctostdvm.target_domain_id = 'Observation'
      and srctostdvm.target_vocabulary_id = 'SNOMED'
      and srctostdvm.target_standard_concept = 'S'
      and srctostdvm.target_invalid_reason is null
  inner join {{ ref ('source_to_source_vocab_map') }} as srctosrcvm
    on
      c.code = srctosrcvm.source_code
      and srctosrcvm.source_vocabulary_id = 'SNOMED'
      and srctosrcvm.source_domain_id = 'Observation'
  left join {{ ref ('stg__final_visit_ids') }} as fv
    on c.encounter = fv.encounter_id
  left join {{ ref ('synthea_encounters') }} as e
    on
      c.encounter = e.id
      and c.patient = e.patient
  left join {{ ref ('provider') }} as pr
    on e.provider = pr.provider_source_value
  inner join {{ ref ('person') }} as p
    on c.patient = p.person_source_value

  union all

  select
    p.person_id as person_id,
    srctostdvm.target_concept_id as observation_concept_id,
    o.date as observation_date,
    o.date as observation_datetime,
    38000280 as observation_type_concept_id,
    cast(null as float) as value_as_number,
    cast(null as varchar) as value_as_string,
    0 as value_as_concept_id,
    0 as qualifier_concept_id,
    0 as unit_concept_id,
    pr.provider_id as provider_id,
    fv.visit_occurrence_id_new as visit_occurrence_id,
    fv.visit_occurrence_id_new + 1000000 as visit_detail_id,
    o.code as observation_source_value,
    srctosrcvm.source_concept_id as observation_source_concept_id,
    cast(null as varchar) as unit_source_value,
    cast(null as varchar) as qualifier_source_value,
    cast(null as varchar) as value_source_value,
    cast(null as bigint) as observation_event_id,
    cast(null as int) as obs_event_field_concept_id

  from {{ ref ('synthea_observations') }} as o
  inner join {{ ref ('source_to_standard_vocab_map') }} as srctostdvm
    on
      o.code = srctostdvm.source_code
      and srctostdvm.target_domain_id = 'Observation'
      and srctostdvm.target_vocabulary_id = 'LOINC'
      and srctostdvm.target_standard_concept = 'S'
      and srctostdvm.target_invalid_reason is null
  inner join {{ ref ('source_to_source_vocab_map') }} as srctosrcvm
    on
      o.code = srctosrcvm.source_code
      and srctosrcvm.source_vocabulary_id = 'LOINC'
      and srctosrcvm.source_domain_id = 'Observation'
  left join {{ ref ('stg__final_visit_ids') }} as fv
    on o.encounter = fv.encounter_id
  left join {{ ref ('synthea_encounters') }} as e
    on
      o.encounter = e.id
      and o.patient = e.patient
  left join {{ ref ('provider') }} as pr
    on e.provider = pr.provider_source_value
  inner join {{ ref ('person') }} as p
    on o.patient = p.person_source_value

) as tmp
