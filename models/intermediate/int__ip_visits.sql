/* inpatient visits */
/* collapse ip claim lines with <=1 day between them into one visit */

with cte_end_dates as (
  select
    patient_id,
    encounter_class,
    event_date - interval '1 day' as end_date
  from (
    select
      patient_id,
      encounter_class,
      event_date,
      event_type,
      max(start_ordinal)
        over (
          partition by patient_id,
          encounter_class
          order by event_date, event_type rows unbounded preceding
        )
        as start_ordinal,
      row_number() over (
        partition by patient_id, encounter_class order by event_date, event_type
      ) as overall_ord
    from (
      select
        patient_id,
        encounter_class,
        encounter_start_datetime as event_date,
        -1 as event_type,
        row_number() over (
          partition by patient_id, encounter_class order by encounter_start_datetime, encounter_stop_datetime
        ) as start_ordinal
      from {{ ref( 'stg_synthea__encounters') }}
      where encounter_class = 'inpatient'
      union all
      select
        patient_id,
        encounter_class,
        encounter_stop_datetime + interval '1 day' as event_date,
        1 as event_type,
        NULL
      from {{ ref( 'stg_synthea__encounters') }}
      where encounter_class = 'inpatient'
    ) as rawdata
  ) as e
  where (2 * e.start_ordinal - e.overall_ord = 0)
),

cte_visit_ends as (
  select
    min(v.encounter_id) as encounter_id,
    v.patient_id,
    v.encounter_class,
    v.encounter_start_datetime as visit_start_date,
    min(e.end_date) as visit_end_date
  from {{ ref( 'stg_synthea__encounters') }} as v
  inner join cte_end_dates as e
    on
      v.patient_id = e.patient_id
      and v.encounter_class = e.encounter_class
      and v.encounter_start_datetime <= e.end_date
  group by v.patient_id, v.encounter_class, v.encounter_start_datetime
)

select
  t2.encounter_id,
  t2.patient_id,
  t2.encounter_class,
  t2.visit_start_date,
  t2.visit_end_date
from (
  select
    encounter_id,
    patient_id,
    encounter_class,
    min(visit_start_date) as visit_start_date,
    visit_end_date
  from cte_visit_ends
  group by encounter_id, patient_id, encounter_class, visit_end_date
) as t2
