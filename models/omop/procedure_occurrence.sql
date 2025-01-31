SELECT
    po.procedure_occurrence_id
    , po.person_id
    , po.procedure_concept_id
    , po.procedure_date
    , po.procedure_datetime
    , po.procedure_end_date
    , po.procedure_end_datetime
    , po.procedure_type_concept_id
    , po.modifier_concept_id
    , po.quantity
    , vd.provider_id
    , vd.visit_occurrence_id
    , vd.visit_detail_id
    , po.procedure_source_value
    , po.procedure_source_concept_id
    , po.modifier_source_value
FROM {{ ref( 'int__procedure_occurrence') }} AS po
LEFT JOIN {{ ref( 'int__visit_detail') }} AS vd
    ON po.encounter_id = vd.encounter_id
