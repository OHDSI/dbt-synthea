/*assign visit_occurrence_id to all encounters*/

select
  e.encounter_id,
  e.patient_id as person_source_value,
  e.encounter_start_datetime as date_service,
  e.encounter_stop_datetime as date_service_end,
  e.encounter_class,
  av.encounter_class as visit_type,
  av.visit_start_date,
  av.visit_end_date,
  av.visit_occurrence_id,
  case
    when e.encounter_class = 'inpatient' and av.encounter_class = 'inpatient'
      then visit_occurrence_id
    when e.encounter_class in ('emergency', 'urgent')
      then (
        case
          when av.encounter_class = 'inpatient' and e.encounter_start_datetime > av.visit_start_date
            then visit_occurrence_id
          when
            av.encounter_class in ('emergency', 'urgent')
            and e.encounter_start_datetime = av.visit_start_date
            then visit_occurrence_id
        end
      )
    when e.encounter_class in ('ambulatory', 'wellness', 'outpatient')
      then (
        case
          when
            av.encounter_class = 'inpatient' and e.encounter_start_datetime >= av.visit_start_date
            then visit_occurrence_id
          when av.encounter_class in ('ambulatory', 'wellness', 'outpatient')
            then visit_occurrence_id
        end
      )
  end as visit_occurrence_id_new
from {{ ref('stg_synthea__encounters') }} e
inner join {{ ref('int__all_visits') }} av
  on
    e.patient_id = av.patient_id
    and e.encounter_start_datetime >= av.visit_start_date
    and e.encounter_start_datetime <= av.visit_end_date
