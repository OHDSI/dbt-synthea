/* Outpatient visits */

with CTE_VISITS_DISTINCT as (
  select
    MIN(id) as encounter_id,
    patient,
    encounterclass,
    start as VISIT_START_DATE,
    stop as VISIT_END_DATE
  from {{ ref( 'synthea_encounters') }}
  where encounterclass in ('ambulatory', 'wellness', 'outpatient')
  group by patient, encounterclass, start, stop
)

select
  MIN(encounter_id) as encounter_id,
  patient,
  encounterclass,
  VISIT_START_DATE,
  MAX(VISIT_END_DATE) as VISIT_END_DATE
from CTE_VISITS_DISTINCT
group by patient, encounterclass, VISIT_START_DATE
