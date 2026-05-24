SELECT
    source_code
    , source_concept_id
    , source_vocabulary_id
    , source_code_description
    , target_concept_id
    , target_vocabulary_id
    , valid_start_date
    , valid_end_date
    , invalid_reason
FROM {{ ref('stg_vocabulary__source_to_concept_map') }}
