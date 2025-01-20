-- For testing purposes, create populate VISIT_DETAIL
-- such that it's basically a copy of VISIT_OCCURRENCE

SELECT
    av.visit_occurrence_id + 1000000 AS visit_detail_id
    , epr.person_id

    , CASE
        WHEN lower(av.encounter_class) = 'ambulatory' THEN 9202
        WHEN lower(av.encounter_class) = 'emergency' THEN 9203
        WHEN lower(av.encounter_class) = 'inpatient' THEN 9201
        WHEN lower(av.encounter_class) = 'wellness' THEN 9202
        WHEN lower(av.encounter_class) = 'urgentcare' THEN 9203
        WHEN lower(av.encounter_class) = 'outpatient' THEN 9202
        ELSE 0
    END AS visit_detail_concept_id

    , {{ dbt.cast("av.visit_start_datetime", api.Column.translate_type("date")) }} AS visit_detail_start_date
    , av.visit_start_datetime AS visit_detail_start_datetime
    , {{ dbt.cast("av.visit_end_datetime", api.Column.translate_type("date")) }} AS visit_detail_end_date
    , av.visit_end_datetime AS visit_detail_end_datetime
    , 32827 AS visit_detail_type_concept_id
    , epr.provider_id
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }}  AS care_site_id
    , 0 AS admitted_from_concept_id
    , 0 AS discharged_to_concept_id
    , lag(av.visit_occurrence_id)
        OVER (
            PARTITION BY epr.person_id
            ORDER BY av.visit_start_datetime
        )
    + 1000000 AS preceding_visit_detail_id
    , av.encounter_id AS visit_detail_source_value
    , 0 AS visit_detail_source_concept_id
    , NULL AS admitted_from_source_value
    , NULL AS discharged_to_source_value
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }}  AS parent_visit_detail_id
    , av.visit_occurrence_id
FROM {{ ref( 'int__all_visits') }} AS av
INNER JOIN {{ ref ('int__encounter_provider') }} AS epr
    ON av.encounter_id = epr.encounter_id
