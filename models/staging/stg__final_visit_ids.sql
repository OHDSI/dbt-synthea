select
  encounter_id,
  visit_occurrence_id_new
from (
  select
    *,
    row_number() over (partition by encounter_id order by priority) as rn
  from (
    select
      *,
      case
        when encounterclass in ('emergency', 'urgent')
          then (
            case
              when
                visit_type = 'inpatient' and visit_occurrence_id_new is not null
                then 1
              when
                visit_type in ('emergency', 'urgent')
                and visit_occurrence_id_new is not null
                then 2
              else 99
            end
          )
        when encounterclass in ('ambulatory', 'wellness', 'outpatient')
          then (
            case
              when
                visit_type = 'inpatient' and visit_occurrence_id_new is not null
                then 1
              when
                visit_type in ('ambulatory', 'wellness', 'outpatient')
                and visit_occurrence_id_new is not null
                then 2
              else 99
            end
          )
        when
          encounterclass = 'inpatient'
          and visit_type = 'inpatient'
          and visit_occurrence_id_new is not null
          then 1
        else 99
      end as priority
    from {{ ref('stg__assign_all_visit_ids') }}
  ) as t1
) as t2
where rn = 1
