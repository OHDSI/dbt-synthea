select
    m.patient,
    m.encounter,
    srctostdvm.target_concept_id as drug_concept_id,
    m.start as drug_exposure_start_date,
    m.start as drug_exposure_start_datetime,
    coalesce(m.stop, m.start) as drug_exposure_end_date,
    coalesce(m.stop, m.start) as drug_exposure_end_datetime,
    m.stop as verbatim_end_date,
    32838 as drug_type_concept_id,
    cast(null as varchar) as stop_reason,
    0 as refills,
    0 as quantity,
    coalesce(datediff(day, m.start, m.stop), 0) as days_supply,
    cast(null as varchar) as sig,
    0 as route_concept_id,
    0 as lot_number,
    m.code as drug_source_value,
    srctosrcvm.source_concept_id as drug_source_concept_id,
    cast(null as varchar) as route_source_value,
    cast(null as varchar) as dose_unit_source_value
  from {{ ref ('synthea_medications') }} as m
  inner join {{ ref ('source_to_standard_vocab_map') }} as srctostdvm
    on
      m.code = srctostdvm.source_code
      and srctostdvm.target_domain_id = 'Drug'
      and srctostdvm.target_vocabulary_id = 'RxNorm'
      and srctostdvm.target_standard_concept = 'S'
      and srctostdvm.target_invalid_reason is null
  inner join {{ ref ('source_to_source_vocab_map') }} as srctosrcvm
    on
      m.code = srctosrcvm.source_code
      and srctosrcvm.source_vocabulary_id = 'RxNorm'
