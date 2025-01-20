SELECT
    av.visit_occurrence_id
    , epr.person_id
    , CASE
        WHEN lower(av.encounter_class) = 'ambulatory' THEN 9202
        WHEN lower(av.encounter_class) = 'emergency' THEN 9203
        WHEN lower(av.encounter_class) = 'inpatient' THEN 9201
        WHEN lower(av.encounter_class) = 'wellness' THEN 9202
        WHEN lower(av.encounter_class) = 'urgentcare' THEN 9203
        WHEN lower(av.encounter_class) = 'outpatient' THEN 9202
        ELSE 0
    END AS visit_concept_id
    , {{ dbt.cast("av.visit_start_datetime", api.Column.translate_type("date")) }} AS visit_start_date
    , av.visit_start_datetime
    , {{ dbt.cast("av.visit_end_datetime", api.Column.translate_type("date")) }} AS visit_end_date
    , av.visit_end_datetime
    , 32827 AS visit_type_concept_id
    , epr.provider_id
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }}  AS care_site_id
    , av.encounter_id AS visit_source_value
    , 0 AS visit_source_concept_id
    , 0 AS admitted_from_concept_id
    , NULL AS admitted_from_source_value
    , 0 AS discharged_to_concept_id
    , NULL AS discharged_to_source_value
    , lag(av.visit_occurrence_id)
        OVER (
            PARTITION BY epr.person_id
            ORDER BY av.visit_start_datetime
        )
    AS preceding_visit_occurrence_id
FROM {{ ref( 'int__all_visits') }} AS av
INNER JOIN {{ ref ('int__encounter_provider') }} AS epr
    ON av.encounter_id = epr.encounter_id
