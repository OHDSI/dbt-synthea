/* Inpatient visits */
/* Collapse IP claim lines with <=1 day between them into one visit */

with CTE_END_DATES as (
  select
    patient,
    encounterclass,
    dateadd(day, -1, EVENT_DATE) as END_DATE
  from (
    select
      patient,
      encounterclass,
      EVENT_DATE,
      EVENT_TYPE,
      max(START_ORDINAL)
        over (
          partition by patient,
          encounterclass
          order by EVENT_DATE, EVENT_TYPE rows unbounded preceding
        )
        as START_ORDINAL,
      row_number() over (
        partition by patient, encounterclass order by EVENT_DATE, EVENT_TYPE
      ) as OVERALL_ORD
    from (
      select
        patient,
        encounterclass,
        start as EVENT_DATE,
        -1 as EVENT_TYPE,
        row_number() over (
          partition by patient, encounterclass order by start, stop
        ) as START_ORDINAL
      from {{ ref( 'synthea_encounters') }}
      where encounterclass = 'inpatient'
      union all
      select
        patient,
        encounterclass,
        dateadd(day, 1, stop),
        1 as EVENT_TYPE,
        NULL
      from {{ ref( 'synthea_encounters') }}
      where encounterclass = 'inpatient'
    ) as RAWDATA
  ) as E
  where (2 * E.START_ORDINAL - E.OVERALL_ORD = 0)
),

CTE_VISIT_ENDS as (
  select
    min(V.id) as encounter_id,
    V.patient,
    V.encounterclass,
    V.start as VISIT_START_DATE,
    min(E.END_DATE) as VISIT_END_DATE
  from {{ ref( 'synthea_encounters') }} as V
  inner join CTE_END_DATES as E
    on
      V.patient = E.patient
      and V.encounterclass = E.encounterclass
      and V.start <= E.END_DATE
  group by V.patient, V.encounterclass, V.start
)

select
  T2.encounter_id,
  T2.patient,
  T2.encounterclass,
  T2.VISIT_START_DATE,
  T2.VISIT_END_DATE
from (
  select
    encounter_id,
    patient,
    encounterclass,
    min(VISIT_START_DATE) as VISIT_START_DATE,
    VISIT_END_DATE
  from CTE_VISIT_ENDS
  group by encounter_id, patient, encounterclass, VISIT_END_DATE
) as T2;
