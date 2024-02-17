/* emergency visits */
/* collapse er claim lines with no days between them into one visit */

select
  t2.encounter_id,
  t2.patient,
  t2.encounterclass,
  t2.visit_start_date,
  t2.visit_end_date
from (
  select
    min(encounter_id) as encounter_id,
    patient,
    encounterclass,
    visit_start_date,
    max(visit_end_date) as visit_end_date
  from (
    select
      cl1.id as encounter_id,
      cl1.patient,
      cl1.encounterclass,
      cl1.start as visit_start_date,
      cl2.stop as visit_end_date
    from {{ ref( 'synthea_encounters') }} as cl1
    inner join {{ ref( 'synthea_encounters') }} as cl2
      on
        cl1.patient = cl2.patient
        and cl1.start = cl2.start
        and cl1.encounterclass = cl2.encounterclass
    where cl1.encounterclass in ('emergency', 'urgent')
  ) as t1
  group by patient, encounterclass, visit_start_date
) as t2
