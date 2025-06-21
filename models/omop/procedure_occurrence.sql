SELECT
    po.procedure_occurrence_id
    , po.person_id
    , po.procedure_concept_id
    , po.procedure_date
    , po.procedure_datetime
    , po.procedure_end_date
    , po.procedure_end_datetime
    , 32827 AS procedure_type_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS modifier_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS quantity
    , vd.provider_id
    , vd.visit_occurrence_id
    , vd.visit_detail_id
    , {{ string_truncate("po.procedure_source_value", 50) }} AS procedure_source_value
    , po.procedure_source_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS modifier_source_value
FROM {{ ref( 'int__procedure_occurrence') }} AS po
LEFT JOIN {{ ref( 'int__visit_detail') }} AS vd
    ON po.encounter_id = vd.encounter_id
