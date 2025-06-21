SELECT
    row_number() OVER (ORDER BY provider_state, provider_city, provider_zip, provider_id) AS provider_id
    , provider_name
    , CASE upper(provider_gender)
        WHEN 'M' THEN 8507
        WHEN 'F' THEN 8532
    END AS gender_concept_id
    , provider_id AS provider_source_value
    , provider_specialty AS specialty_source_value
    , provider_gender AS gender_source_value
    , CASE upper(provider_gender)
        WHEN 'M' THEN 8507
        WHEN 'F' THEN 8532
    END AS gender_source_concept_id
FROM {{ ref( 'stg_synthea__providers') }}
