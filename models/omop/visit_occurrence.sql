select
  av.visit_occurrence_id,
  p.person_id,
  case lower(av.encounterclass)
    when 'ambulatory' then 9202
    when 'emergency' then 9203
    when 'inpatient' then 9201
    when 'wellness' then 9202
    when 'urgentcare' then 9203
    when 'outpatient' then 9202
    else 0
  end as visit_concept_id,
  av.visit_start_date,
  av.visit_start_date as visit_start_datetime,
  av.visit_end_date,
  av.visit_end_date as visit_end_datetime,
  32827 as visit_type_concept_id,
  pr.provider_id,
  null as care_site_id,
  av.encounter_id as visit_source_value,
  0 as visit_source_concept_id,
  0 as admitted_from_concept_id,
  null as admitted_from_source_value,
  0 as discharged_to_concept_id,
  null as discharged_to_source_value,
  lag(av.visit_occurrence_id)
    over (
      partition by p.person_id
      order by av.visit_start_date
    ) as preceding_visit_occurrence_id
from {{ ref( 'stg__all_visits') }} as av
inner join {{ ref( 'person') }} as p
  on av.patient = p.person_source_value
inner join {{ ref('synthea_encounters') }} as e
  on
    av.encounter_id = e.id
    and av.patient = e.patient
inner join {{ ref( 'provider') }} as pr
  on e.provider = pr.provider_source_value
where av.visit_occurrence_id in (
  select distinct visit_occurrence_id_new
  from {{ ref( 'stg__final_visit_ids') }}
)
