/* emergency visits */
/* collapse er claim lines with no days between them into one visit */

select
  t2.encounter_id,
  t2.patient_id,
  t2.encounter_class,
  t2.visit_start_date,
  t2.visit_end_date
from (
  select
    min(encounter_id) as encounter_id,
    patient_id,
    encounter_class,
    visit_start_date,
    max(visit_end_date) as visit_end_date
  from (
    select
      cl1.encounter_id,
      cl1.patient_id,
      cl1.encounter_class,
      cl1.encounter_start_datetime as visit_start_date,
      cl2.encounter_stop_datetime as visit_end_date
    from {{ ref( 'stg_synthea__encounters') }} as cl1
    inner join {{ ref( 'stg_synthea__encounters') }} as cl2
      on
        cl1.patient_id = cl2.patient_id
        and cl1.encounter_start_datetime = cl2.encounter_start_datetime
        and cl1.encounter_class = cl2.encounter_class
    where cl1.encounter_class in ('emergency', 'urgent')
  ) as t1
  group by patient_id, encounter_class, visit_start_date
) as t2
