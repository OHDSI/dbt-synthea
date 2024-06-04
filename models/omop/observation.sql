with all_observations as (
  select * from {{ ref('int__observation_allergies') }}
  union all
  select * from {{ ref('int__observation_conditions') }}
  union all
  select * from {{ ref('int__observation_observations') }}
)
select
  row_number() over (order by person_id) as observation_id,
  p.person_id,
  observation_concept_id,
  observation_date,
  observation_datetime,
  observation_type_concept_id,
  cast(null as float) as value_as_number,
  cast(null as varchar) as value_as_string,
  0 as value_as_concept_id,
  0 as qualifier_concept_id,
  0 as unit_concept_id,
  epr.provider_id,
  fv.visit_occurrence_id_new as visit_occurrence_id,
  fv.visit_occurrence_id_new + 1000000 as visit_detail_id,
  observation_source_value,
  observation_source_concept_id,
  cast(null as varchar) as unit_source_value,
  cast(null as varchar) as qualifier_source_value,
  cast(null as varchar) as value_source_value,
  cast(null as bigint) as observation_event_id,
  cast(null as int) as obs_event_field_concept_id
from all_observations as ao
  left join {{ ref ('int__final_visit_ids') }} as fv
    on ao.encounter_id = fv.encounter_id
  left join {{ ref ('int__encounter_provider') }} as epr
    on
      ao.encounter_id = epr.encounter_id
      and ao.patient_id = epr.patient_id
  inner join {{ ref ('person') }} as p
    on ao.patient_id = p.person_source_value
