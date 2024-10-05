/* inpatient visits */
/* collapse ip claim lines with <=1 day between them into one visit */

WITH cte_end_dates AS (
    SELECT
        patient_id
        , encounter_class
        , {{ dbt.dateadd(datepart="day", interval=-1, from_date_or_timestamp="event_datetime") }} AS end_datetime
    FROM (
        SELECT
            patient_id
            , encounter_class
            , event_datetime
            , event_type
            , max(start_ordinal)
                OVER (
                    PARTITION BY
                        patient_id
                        , encounter_class
                    ORDER BY event_datetime, event_type ROWS UNBOUNDED PRECEDING
                )
            AS start_ordinal
            , row_number() OVER (
                PARTITION BY patient_id, encounter_class
                ORDER BY event_datetime, event_type
            ) AS overall_ord
        FROM (
            SELECT
                patient_id
                , encounter_class
                , encounter_start_datetime AS event_datetime
                , -1 AS event_type
                , row_number() OVER (
                    PARTITION BY patient_id, encounter_class
                    ORDER BY encounter_start_datetime, encounter_stop_datetime
                ) AS start_ordinal
            FROM {{ ref( 'stg_synthea__encounters') }}
            WHERE encounter_class = 'inpatient'
            UNION ALL
            SELECT
                patient_id
                , encounter_class
                , {{ dbt.dateadd(datepart="day", interval=1, from_date_or_timestamp="encounter_stop_datetime") }} AS event_datetime
                , 1 AS event_type
                , NULL AS start_ordinal
            FROM {{ ref( 'stg_synthea__encounters') }}
            WHERE encounter_class = 'inpatient'
        ) AS rawdata
    ) AS e
    WHERE (2 * e.start_ordinal - e.overall_ord = 0)
)

, cte_visit_ends AS (
    SELECT
        min(v.encounter_id) AS encounter_id
        , v.patient_id
        , v.encounter_class
        , v.encounter_start_datetime AS visit_start_datetime
        , min(e.end_datetime) AS visit_end_datetime
    FROM {{ ref( 'stg_synthea__encounters') }} AS v
    INNER JOIN cte_end_dates AS e
        ON
            v.patient_id = e.patient_id
            AND v.encounter_class = e.encounter_class
            AND v.encounter_start_datetime <= e.end_datetime
    GROUP BY v.patient_id, v.encounter_class, v.encounter_start_datetime
)

SELECT
    t2.encounter_id
    , t2.patient_id
    , t2.encounter_class
    , t2.visit_start_datetime
    , t2.visit_end_datetime
FROM (
    SELECT
        encounter_id
        , patient_id
        , encounter_class
        , min(visit_start_datetime) AS visit_start_datetime
        , visit_end_datetime
    FROM cte_visit_ends
    GROUP BY encounter_id, patient_id, encounter_class, visit_end_datetime
) AS t2
