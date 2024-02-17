select
  encounter_id,
  VISIT_OCCURRENCE_ID_NEW
from (
  select
    *,
    row_number() over (partition by encounter_id order by PRIORITY) as RN
  from (
    select
      *,
      case
        when encounterclass in ('emergency', 'urgent')
          then (
            case
              when
                VISIT_TYPE = 'inpatient' and VISIT_OCCURRENCE_ID_NEW is not null
                then 1
              when
                VISIT_TYPE in ('emergency', 'urgent')
                and VISIT_OCCURRENCE_ID_NEW is not null
                then 2
              else 99
            end
          )
        when encounterclass in ('ambulatory', 'wellness', 'outpatient')
          then (
            case
              when
                VISIT_TYPE = 'inpatient' and VISIT_OCCURRENCE_ID_NEW is not null
                then 1
              when
                VISIT_TYPE in ('ambulatory', 'wellness', 'outpatient')
                and VISIT_OCCURRENCE_ID_NEW is not null
                then 2
              else 99
            end
          )
        when
          encounterclass = 'inpatient'
          and VISIT_TYPE = 'inpatient'
          and VISIT_OCCURRENCE_ID_NEW is not null
          then 1
        else 99
      end as PRIORITY
    from {{ ref('stg__assign_all_visit_ids') }}
  ) as T1
) as T2
where RN = 1
