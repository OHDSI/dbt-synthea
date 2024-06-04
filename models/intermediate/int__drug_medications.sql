select
  m.patient_id,
  m.encounter_id,
  srctostdvm.target_concept_id as drug_concept_id,
  m.medication_start_datetime as drug_exposure_start_date,
  m.medication_start_datetime as drug_exposure_start_datetime,
  coalesce(m.medication_stop_datetime, m.medication_start_datetime) as drug_exposure_end_date,
  coalesce(m.medication_stop_datetime, m.medication_start_datetime) as drug_exposure_end_datetime,
  m.medication_stop_datetime as verbatim_end_date,
  32838 as drug_type_concept_id,
  cast(null as varchar) as stop_reason,
  0 as refills,
  0 as quantity,
  coalesce(date_part('day', m.medication_stop_datetime - m.medication_start_datetime), 0) as days_supply,
  cast(null as varchar) as sig,
  0 as route_concept_id,
  0 as lot_number,
  m.medication_code as drug_source_value,
  srctosrcvm.source_concept_id as drug_source_concept_id,
  cast(null as varchar) as route_source_value,
  cast(null as varchar) as dose_unit_source_value
from {{ ref ('stg_synthea__medications') }} as m
inner join {{ ref ('int__source_to_standard_vocab_map') }} as srctostdvm
  on
    m.medication_code = srctostdvm.source_code
    and srctostdvm.target_domain_id = 'Drug'
    and srctostdvm.target_vocabulary_id = 'RxNorm'
    and srctostdvm.target_standard_concept = 'S'
    and srctostdvm.target_invalid_reason is null
inner join {{ ref ('int__source_to_source_vocab_map') }} as srctosrcvm
  on
    m.medication_code = srctosrcvm.source_code
    and srctosrcvm.source_vocabulary_id = 'RxNorm'
