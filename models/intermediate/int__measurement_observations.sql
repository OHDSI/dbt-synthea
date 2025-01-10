SELECT
    p.person_id
    , srctostdvm.target_concept_id AS measurement_concept_id
    , o.observation_date AS measurement_date
    , o.observation_datetime AS measurement_datetime
    , {{ dbt.cast("o.observation_datetime", api.Column.translate_type("time")) }} AS measurement_time
    , 32827 AS measurement_type_concept_id
    , 0 AS operator_concept_id
    , CASE
        WHEN {{ regexp_like("o.observation_value", "^[-+]?[0-9]+\.?[0-9]*$") }}
            THEN {{ dbt.cast("o.observation_value", api.Column.translate_type("decimal")) }}
        ELSE {{ dbt.cast("null", api.Column.translate_type("decimal")) }}
    END AS value_as_number
    , coalesce(srcmap2.target_concept_id, 0) AS value_as_concept_id
    , coalesce(srcmap1.target_concept_id, 0) AS unit_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("decimal")) }} AS range_low
    , {{ dbt.cast("null", api.Column.translate_type("decimal")) }} AS range_high
    , epr.provider_id
    , epr.visit_occurrence_id
    , epr.visit_occurrence_id + 1000000 AS visit_detail_id
    , o.observation_code AS measurement_source_value
    , coalesce(
        srctosrcvm.source_concept_id, 0
    ) AS measurement_source_concept_id
    , o.observation_units AS unit_source_value
    , o.observation_value AS value_source_value
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS unit_source_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("bigint")) }} AS measurement_event_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS meas_event_field_concept_id
FROM {{ ref ('stg_synthea__observations') }} AS o
INNER JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srctostdvm
    ON
        o.observation_code = srctostdvm.source_code
        AND srctostdvm.target_domain_id = 'Measurement'
        AND srctostdvm.source_vocabulary_id = 'LOINC'
        AND srctostdvm.target_standard_concept = 'S'
        AND srctostdvm.target_invalid_reason IS null
LEFT JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srcmap1
    ON
        o.observation_units = srcmap1.source_code
        AND srcmap1.target_vocabulary_id = 'UCUM'
        AND srcmap1.source_vocabulary_id = 'UCUM'
        AND srcmap1.target_standard_concept = 'S'
        AND srcmap1.target_invalid_reason IS null
LEFT JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srcmap2
    ON
        o.observation_value = srcmap2.source_code
        AND srcmap2.target_domain_id = 'Meas value'
        AND srcmap2.target_standard_concept = 'S'
        AND srcmap2.target_invalid_reason IS null
LEFT JOIN {{ ref ('int__source_to_source_vocab_map') }} AS srctosrcvm
    ON
        o.observation_code = srctosrcvm.source_code
        AND srctosrcvm.source_vocabulary_id = 'LOINC'
INNER JOIN {{ ref ('int__person') }} AS p
    ON o.patient_id = p.person_source_value
LEFT JOIN {{ ref ('int__encounter_provider') }} AS epr
    ON o.encounter_id = epr.encounter_id
