SELECT
    row_number() OVER (ORDER BY person_id) AS observation_period_id
    , person_id
    , start_date AS observation_period_start_date
    , end_date AS observation_period_end_date
    , 32882 AS period_type_concept_id
FROM (
    SELECT
        p.person_id
        , min(e.encounter_start_date) AS start_date
        , max(e.encounter_stop_date) AS end_date
    FROM {{ ref ('person') }} AS p
    INNER JOIN {{ ref ('stg_synthea__encounters') }} AS e
        ON p.person_source_value = e.patient_id
    GROUP BY p.person_id
) AS tmp
