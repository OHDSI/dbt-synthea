/* outpatient visits */

with cte_visits_distinct as (
  select
    min(id) as encounter_id,
    patient,
    encounterclass,
    start as visit_start_date,
    stop as visit_end_date
  from {{ ref( 'synthea_encounters') }}
  where encounterclass in ('ambulatory', 'wellness', 'outpatient')
  group by patient, encounterclass, start, stop
)

select
  min(encounter_id) as encounter_id,
  patient,
  encounterclass,
  visit_start_date,
  max(visit_end_date) as visit_end_date
from cte_visits_distinct
group by patient, encounterclass, visit_start_date
