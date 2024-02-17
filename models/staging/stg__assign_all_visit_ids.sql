/*Assign VISIT_OCCURRENCE_ID to all encounters*/

select
  E.id as encounter_id,
  E.patient as person_source_value,
  E.start as date_service,
  E.stop as date_service_end,
  E.encounterclass,
  AV.encounterclass as VISIT_TYPE,
  AV.VISIT_START_DATE,
  AV.VISIT_END_DATE,
  AV.VISIT_OCCURRENCE_ID,
  case
    when E.encounterclass = 'inpatient' and AV.encounterclass = 'inpatient'
      then VISIT_OCCURRENCE_ID
    when E.encounterclass in ('emergency', 'urgent')
      then (
        case
          when AV.encounterclass = 'inpatient' and E.start > AV.VISIT_START_DATE
            then VISIT_OCCURRENCE_ID
          when
            AV.encounterclass in ('emergency', 'urgent')
            and E.start = AV.VISIT_START_DATE
            then VISIT_OCCURRENCE_ID
        end
      )
    when E.encounterclass in ('ambulatory', 'wellness', 'outpatient')
      then (
        case
          when
            AV.encounterclass = 'inpatient' and E.start >= AV.VISIT_START_DATE
            then VISIT_OCCURRENCE_ID
          when AV.encounterclass in ('ambulatory', 'wellness', 'outpatient')
            then VISIT_OCCURRENCE_ID
        end
      )
  end as VISIT_OCCURRENCE_ID_NEW
from {{ ref('synthea_encounters') }}
inner join {{ ref('stg__all_visits') }}
  on
    E.patient = AV.patient
    and E.start >= AV.VISIT_START_DATE
    and E.start <= AV.VISIT_END_DATE
