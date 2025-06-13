WITH all_observations AS (
    SELECT * FROM {{ ref('int__observation_allergies') }}
    UNION ALL
    SELECT * FROM {{ ref('int__observation_conditions') }}
    UNION ALL
    SELECT * FROM {{ ref('int__observation_observations') }}
)

SELECT
    row_number() OVER (ORDER BY person_id) AS observation_id
    , person_id
    , observation_concept_id
    , observation_date
    , observation_datetime
    , 32817 AS observation_type_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("float")) }} AS value_as_number
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS value_as_string
    , 0 AS value_as_concept_id
    , 0 AS qualifier_concept_id
    , 0 AS unit_concept_id
    , provider_id
    , visit_occurrence_id
    , visit_detail_id
    , observation_source_value
    , observation_source_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS unit_source_value
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS qualifier_source_value
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS value_source_value
    , {{ dbt.cast("null", api.Column.translate_type("bigint")) }} AS observation_event_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS obs_event_field_concept_id
FROM all_observations
