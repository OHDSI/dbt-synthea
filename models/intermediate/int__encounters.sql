WITH cte_dupes AS (
    /*
    some encounter IDs are duplicated due to a bug in the Synthea data generation process.
    we flag duplicates here in order to remove them from downstream models, as there is no way to determine which encounter among duplicates is referenced by a foreign key to the encounters table.
    */
    SELECT encounter_id AS dupe_encounter_id
    FROM {{ ref( 'stg_synthea__encounters') }}
    GROUP BY encounter_id
    HAVING COUNT(*) > 1
)

SELECT
    e.encounter_id
    , e.encounter_start_datetime
    , e.encounter_start_date
    , e.encounter_stop_datetime
    , e.encounter_stop_date
    , p.person_id
    , pr.provider_id
    , e.payer_id
    , e.encounter_class
    , e.encounter_code
    , e.encounter_description
    , e.base_encounter_cost
    , e.total_encounter_cost
    , e.encounter_payer_coverage
    , e.encounter_reason_code
    , e.encounter_reason_description
FROM {{ ref( 'stg_synthea__encounters') }} AS e
LEFT JOIN cte_dupes
    ON e.encounter_id = cte_dupes.dupe_encounter_id
INNER JOIN {{ ref ('int__person') }} AS p
    ON e.patient_id = p.person_source_value
LEFT JOIN {{ ref ('int__provider') }} AS pr
    ON e.provider_id = pr.provider_source_value
WHERE cte_dupes.dupe_encounter_id IS NULL
