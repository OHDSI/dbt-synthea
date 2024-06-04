/* outpatient visits */

with cte_visits_distinct as (
  select
    min(encounter_id) as encounter_id,
    patient_id,
    encounter_class,
    encounter_start_datetime as visit_start_date,
    encounter_stop_datetime as visit_end_date
  from {{ ref( 'stg_synthea__encounters') }}
  where encounter_class in ('ambulatory', 'wellness', 'outpatient')
  group by patient_id, encounter_class, encounter_start_datetime, encounter_stop_datetime
)

select
  min(encounter_id) as encounter_id,
  patient_id,
  encounter_class,
  visit_start_date,
  max(visit_end_date) as visit_end_date
from cte_visits_distinct
group by patient_id, encounter_class, visit_start_date
