/* inpatient visits */
/* collapse ip claim lines with <=1 day between them into one visit */

with cte_end_dates as (
  select
    patient,
    encounterclass,
    dateadd(day, -1, event_date) as end_date
  from (
    select
      patient,
      encounterclass,
      event_date,
      event_type,
      max(start_ordinal)
        over (
          partition by patient,
          encounterclass
          order by event_date, event_type rows unbounded preceding
        )
        as start_ordinal,
      row_number() over (
        partition by patient, encounterclass order by event_date, event_type
      ) as overall_ord
    from (
      select
        patient,
        encounterclass,
        start as event_date,
        -1 as event_type,
        row_number() over (
          partition by patient, encounterclass order by start, stop
        ) as start_ordinal
      from {{ ref( 'synthea_encounters') }}
      where encounterclass = 'inpatient'
      union all
      select
        patient,
        encounterclass,
        dateadd(day, 1, stop),
        1 as event_type,
        null
      from {{ ref( 'synthea_encounters') }}
      where encounterclass = 'inpatient'
    ) as rawdata
  ) as e
  where (2 * e.start_ordinal - e.overall_ord = 0)
),

cte_visit_ends as (
  select
    min(v.id) as encounter_id,
    v.patient,
    v.encounterclass,
    v.start as visit_start_date,
    min(e.end_date) as visit_end_date
  from {{ ref( 'synthea_encounters') }} as v
  inner join cte_end_dates as e
    on
      v.patient = e.patient
      and v.encounterclass = e.encounterclass
      and v.start <= e.end_date
  group by v.patient, v.encounterclass, v.start
)

select
  t2.encounter_id,
  t2.patient,
  t2.encounterclass,
  t2.visit_start_date,
  t2.visit_end_date
from (
  select
    encounter_id,
    patient,
    encounterclass,
    min(visit_start_date) as visit_start_date,
    visit_end_date
  from cte_visit_ends
  group by encounter_id, patient, encounterclass, visit_end_date
) as t2;
