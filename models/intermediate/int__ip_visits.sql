/*
inpatient visits
include multi-day OP/ER visits, and collapse all overlapping multi-day visits into a single visit
*/

WITH

all_ip_encounters AS (
    SELECT
        encounter_id
        , patient_id
        , encounter_class
        , encounter_start_date
        , encounter_stop_date
    FROM {{ ref( 'stg_synthea__encounters') }}
    WHERE
        encounter_class = 'inpatient'
        OR (encounter_class IN ('ambulatory', 'wellness', 'outpatient', 'emergency', 'urgentcare') AND encounter_start_date != encounter_stop_date)
)

, cte_collapse_encounters AS (
    SELECT
        patient_id
        , event_date
        , event_type
        , max(start_ordinal)
            OVER (
                PARTITION BY patient_id
                ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING
            )
        AS start_ordinal
        , row_number() OVER (
            PARTITION BY patient_id
            ORDER BY event_date, event_type
        ) AS overall_ord
    FROM (
        SELECT
            patient_id
            , encounter_start_date AS event_date
            , -1 AS event_type
            , row_number() OVER (
                PARTITION BY patient_id
                ORDER BY encounter_start_date, encounter_stop_date
            ) AS start_ordinal
        FROM all_ip_encounters
        UNION ALL
        SELECT
            patient_id
            , {{ dbt.dateadd(datepart="day", interval=1, from_date_or_timestamp="encounter_stop_date") }} AS event_date
            , 1 AS event_type
            , NULL AS start_ordinal
        FROM all_ip_encounters
    ) AS e
)

, cte_end_dates AS (
    SELECT
        patient_id
        , {{ dbt.dateadd(datepart="day", interval=-1, from_date_or_timestamp="event_date") }} AS end_date
    FROM cte_collapse_encounters
    WHERE (2 * start_ordinal - overall_ord = 0)
)

, cte_visit_ends AS (
    SELECT
        min(a.encounter_id) OVER (PARTITION BY a.patient_id, a.encounter_start_date) AS encounter_id
        , a.encounter_id AS original_encounter_id
        , a.patient_id
        , a.encounter_start_date
        , min(e.end_date) OVER (PARTITION BY a.patient_id, a.encounter_start_date) AS visit_end_date
    FROM all_ip_encounters AS a
    INNER JOIN cte_end_dates AS e
        ON
            a.patient_id = e.patient_id
            AND a.encounter_start_date <= e.end_date
)

, cte_visit_starts AS (
    SELECT
        encounter_id
        , patient_id
        , min(encounter_start_date) AS visit_start_date
        , visit_end_date
    FROM cte_visit_ends
    GROUP BY encounter_id, patient_id, visit_end_date
)

SELECT
    v.encounter_id AS visit_id
    -- bring back the original encounter ID so we can keep track of all encounters that were rolled up into each IP visit
    , ve.original_encounter_id AS encounter_id
    , v.patient_id
    , CASE
        -- if the stay began with an ER encounter, classify as ER+IP
        WHEN er.patient_id IS NOT NULL THEN 'er+ip'
        ELSE 'inpatient'
    END AS visit_class
    , v.visit_start_date
    , v.visit_end_date
FROM cte_visit_starts AS v
INNER JOIN cte_visit_ends AS ve
    ON v.encounter_id = ve.encounter_id
LEFT JOIN all_ip_encounters AS er
    ON
        v.patient_id = er.patient_id
        AND v.visit_start_date = er.encounter_start_date
        AND er.encounter_class IN ('emergency', 'urgentcare')
