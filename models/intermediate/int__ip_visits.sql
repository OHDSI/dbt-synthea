/*
inpatient visits
include multi-day OP/ER visits, and collapse all overlapping multi-day visits into a single visit
*/

WITH

all_ip_encounters AS (
    SELECT
        encounter_id
        , person_id
        , encounter_class
        , encounter_start_date
        , encounter_stop_date
    FROM {{ ref( 'int__encounters') }}
    WHERE
        (
            encounter_class = 'inpatient'
            OR (encounter_class IN ('ambulatory', 'wellness', 'outpatient', 'emergency', 'urgentcare') AND encounter_start_date != encounter_stop_date)
        )
        AND encounter_start_date <= encounter_stop_date
)

, cte_collapse_encounters AS (
    /*
    Per patient, go through all encounter dates in ascending order, assigning each row the highest start_ordinal yet seen. This will fill in the start_ordinal for each end date, using the start_ordinal of the closest previous start date. The start_ordinal for each start date will remain unchanged. This means that if one encounter starts “during” another, the end date of the previous encounter will be ranked above start date of that encounter.
    overall_ord simply ranks all the rows for each patient in order of date (in case of tie, start dates are ranked above end dates, then by ascending start_ordinal).
    */
    SELECT
        person_id
        , event_date
        , event_type
        , max(start_ordinal)
            OVER (
                PARTITION BY person_id
                ORDER BY event_date, event_type, start_ordinal ROWS UNBOUNDED PRECEDING
            )
        AS start_ordinal
        , row_number() OVER (
            PARTITION BY person_id
            ORDER BY event_date, event_type, start_ordinal
        ) AS overall_ord
    FROM (
        -- per patient, rank all start dates in start_ordinal, then tack on all the end dates (+1 day), with a NULL start_ordinal
        SELECT
            person_id
            , encounter_start_date AS event_date
            , -1 AS event_type
            , row_number() OVER (
                PARTITION BY person_id
                ORDER BY encounter_start_date, encounter_stop_date
            ) AS start_ordinal
        FROM all_ip_encounters
        UNION ALL
        SELECT
            person_id
            , {{ dbt.dateadd(datepart="day", interval=1, from_date_or_timestamp="encounter_stop_date") }} AS event_date
            , 1 AS event_type
            , NULL AS start_ordinal
        FROM all_ip_encounters
    ) AS e
)

, cte_end_dates AS (
    /*
    Per patient, take dates where the overall rank = 2x the start date rank, and subtract one day from them. This indicates the final end date of a collapsed encounter.
    */
    SELECT
        person_id
        , {{ dbt.dateadd(datepart="day", interval=-1, from_date_or_timestamp="event_date") }} AS end_date
    FROM cte_collapse_encounters
    WHERE (2 * start_ordinal - overall_ord = 0)
)

, cte_visit_ends AS (
    /*
    Now go back to the original table with all IP encounters, and join it to the end dates table - tack an end date onto all encounters whose start date is on or before that date.  Without aggregation this would create duplicate rows anytime there’s more than 1 collapsed visit, so we assign the minimum qualifying end date to each encounter.
    */
    SELECT
        a.encounter_id
        , a.person_id
        , a.encounter_start_date
        , min(e.end_date) AS visit_end_date
    FROM all_ip_encounters AS a
    INNER JOIN cte_end_dates AS e
        ON
            a.person_id = e.person_id
            AND a.encounter_start_date <= e.end_date
    GROUP BY a.encounter_id, a.person_id, a.encounter_start_date
)

, cte_visit_starts AS (
    -- Then among encounters with the same end date, we choose the earliest possible start date
    SELECT
        person_id
        , min(encounter_start_date) AS visit_start_date
        , visit_end_date
    FROM cte_visit_ends
    GROUP BY person_id, visit_end_date
)

, cte_visit_ids AS (
    -- Assign each collapsed visit a unique ID
    SELECT
        row_number() OVER (ORDER BY person_id, visit_start_date) AS visit_id
        , person_id
        , visit_start_date
        , visit_end_date
    FROM cte_visit_starts
)

, er_starts AS (
    -- identify encounter start dates associated with ER/urgent care visits
    SELECT DISTINCT
        person_id
        , encounter_start_date
    FROM all_ip_encounters
    WHERE encounter_class IN ('emergency', 'urgentcare')
)

SELECT
    {{ dbt.cast("v.visit_id", api.Column.translate_type("varchar")) }} AS visit_id
    -- bring back the original encounter ID so we can keep track of all encounters that were rolled up into each IP visit
    , ve.encounter_id
    , v.person_id
    , CASE
        -- if the stay began with an ER encounter, classify as ER+IP
        WHEN er.person_id IS NOT NULL THEN 'er+ip'
        ELSE 'inpatient'
    END AS visit_class
    , v.visit_start_date
    , v.visit_end_date
FROM cte_visit_ids AS v
INNER JOIN cte_visit_ends AS ve
    ON
        v.person_id = ve.person_id
        AND v.visit_end_date = ve.visit_end_date
LEFT JOIN er_starts AS er
    ON
        v.person_id = er.person_id
        AND v.visit_start_date = er.encounter_start_date
