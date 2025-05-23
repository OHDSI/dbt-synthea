SELECT
    visit_detail_id
    , person_id
    , visit_detail_concept_id
    , visit_detail_start_date
    , visit_detail_start_datetime
    , visit_detail_end_date
    , visit_detail_stop_datetime
    , visit_detail_type_concept_id
    , provider_id
    , care_site_id
    , admitted_from_concept_id
    , discharged_to_concept_id
    , preceding_visit_detail_id
    , visit_detail_source_value
    , visit_detail_source_concept_id
    , admitted_from_source_value
    , discharged_to_source_value
    , parent_visit_detail_id
    , visit_occurrence_id
FROM {{ ref( 'int__visit_detail') }}
