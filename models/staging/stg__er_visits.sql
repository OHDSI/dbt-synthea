/* Emergency visits */
/* collapse ER claim lines with no days between them into one visit */

select
  T2.encounter_id,
  T2.patient,
  T2.encounterclass,
  T2.VISIT_START_DATE,
  T2.VISIT_END_DATE
from (
  select
    MIN(encounter_id) as encounter_id,
    patient,
    encounterclass,
    VISIT_START_DATE,
    MAX(VISIT_END_DATE) as VISIT_END_DATE
  from (
    select
      CL1.id as encounter_id,
      CL1.patient,
      CL1.encounterclass,
      CL1.start as VISIT_START_DATE,
      CL2.stop as VISIT_END_DATE
    from {{ ref( 'synthea_encounters') }} as CL1
    inner join {{ ref( 'synthea_encounters') }} as CL2
      on
        CL1.patient = CL2.patient
        and CL1.start = CL2.start
        and CL1.encounterclass = CL2.encounterclass
    where CL1.encounterclass in ('emergency', 'urgent')
  ) as T1
  group by patient, encounterclass, VISIT_START_DATE
) as T2
