{{
  config(
    materialized = 'table',
    )
}}
select
  c.concept_code as source_code,
  c.concept_id as source_concept_id,
  c.concept_name as source_code_description,
  c.vocabulary_id as source_vocabulary_id,
  c.domain_id as source_domain_id,
  c.concept_class_id as source_concept_class_id,
  c.valid_start_date as source_valid_start_date,
  c.valid_end_date as source_valid_end_date,
  c.invalid_reason as source_invalid_reason,
  c.concept_id as target_concept_id,
  c.concept_name as target_concept_name,
  c.vocabulary_id as target_vocabulary_id,
  c.domain_id as target_domain_id,
  c.concept_class_id as target_concept_class_id,
  c.invalid_reason as target_invalid_reason,
  c.standard_concept as target_standard_concept
from {{ ref( 'concept') }} as c
union
select
  source_code,
  source_concept_id,
  source_code_description,
  source_vocabulary_id,
  c1.domain_id as source_domain_id,
  c2.concept_class_id as source_concept_class_id,
  c1.valid_start_date as source_valid_start_date,
  c1.valid_end_date as source_valid_end_date,
  stcm.invalid_reason as source_invalid_reason,
  target_concept_id,
  c2.concept_name as target_concept_name,
  target_vocabulary_id,
  c2.domain_id as target_domain_id,
  c2.concept_class_id as target_concept_class_id,
  c2.invalid_reason as target_invalid_reason,
  c2.standard_concept as target_standard_concept
from {{ ref( 'source_to_concept_map') }} as stcm
left outer join {{ ref( 'concept') }} as c1
  on stcm.source_concept_id = c1.concept_id
left outer join {{ ref( 'concept') }} as c2
  on stcm.target_concept_id = c2.concept_id
where stcm.invalid_reason is null
