{# This bit of SQL gets reused several times in the OMOP layer #}
SELECT
    p.person_id
    , e.patient_id
    , e.encounter_id
    , vid.visit_occurrence_id_new AS visit_occurrence_id
    , pr.provider_id
FROM {{ ref ('stg_synthea__encounters') }} AS e
INNER JOIN {{ ref ('provider') }} AS pr
    ON e.provider_id = pr.provider_source_value
INNER JOIN {{ ref ('int__person') }} AS p
    ON e.patient_id = p.person_source_value
INNER JOIN {{ ref( 'int__final_visit_ids') }} AS vid
    ON e.encounter_id = vid.encounter_id
