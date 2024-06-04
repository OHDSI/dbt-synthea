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
  c1.concept_id as target_concept_id,
  c1.concept_name as target_concept_name,
  c1.vocabulary_id as target_vocabulary_id,
  c1.domain_id as target_domain_id,
  c1.concept_class_id as target_concept_class_id,
  c1.invalid_reason as target_invalid_reason,
  c1.standard_concept as target_standard_concept
from {{ ref( 'stg_vocabulary__concept') }} as c
inner join {{ ref( 'stg_vocabulary__concept_relationship') }} as cr
  on
    c.concept_id = cr.concept_id_1
    and cr.invalid_reason is null
    and lower(cr.relationship_id) = 'maps to'
inner join {{ ref( 'stg_vocabulary__concept') }} as c1
  on
    cr.concept_id_2 = c1.concept_id
    and c1.invalid_reason is null
{# union
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
from {{ ref( 'stg_vocabulary__source_to_concept_map') }} as stcm
left outer join {{ ref( 'stg_vocabulary__concept') }} as c1
  on stcm.source_concept_id = c1.concept_id
left outer join {{ ref( 'stg_vocabulary__concept') }} as c2
  on stcm.target_concept_id = c2.concept_id
where stcm.invalid_reason is null #}
