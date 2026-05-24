SELECT
    row_number() OVER (ORDER BY person_id) AS observation_period_id
    , person_id
    , observation_period_start_date
    , observation_period_end_date
    , 32882 AS period_type_concept_id
FROM (
    SELECT
        person_id
        , min(visit_detail_start_date) AS observation_period_start_date
        , max(visit_detail_end_date) AS observation_period_end_date
    FROM {{ ref ('int__visit_detail') }}
    GROUP BY person_id
) AS tmp
