/*assign visit_occurrence_id to all encounters*/

select
  e.id as encounter_id,
  e.patient as person_source_value,
  e.start as date_service,
  e.stop as date_service_end,
  e.encounterclass,
  av.encounterclass as visit_type,
  av.visit_start_date,
  av.visit_end_date,
  av.visit_occurrence_id,
  case
    when e.encounterclass = 'inpatient' and av.encounterclass = 'inpatient'
      then visit_occurrence_id
    when e.encounterclass in ('emergency', 'urgent')
      then (
        case
          when av.encounterclass = 'inpatient' and e.start > av.visit_start_date
            then visit_occurrence_id
          when
            av.encounterclass in ('emergency', 'urgent')
            and e.start = av.visit_start_date
            then visit_occurrence_id
        end
      )
    when e.encounterclass in ('ambulatory', 'wellness', 'outpatient')
      then (
        case
          when
            av.encounterclass = 'inpatient' and e.start >= av.visit_start_date
            then visit_occurrence_id
          when av.encounterclass in ('ambulatory', 'wellness', 'outpatient')
            then visit_occurrence_id
        end
      )
  end as visit_occurrence_id_new
from {{ ref('synthea_encounters') }}
inner join {{ ref('stg__all_visits') }}
  on
    e.patient = av.patient
    and e.start >= av.visit_start_date
    and e.start <= av.visit_end_date
