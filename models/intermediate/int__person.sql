SELECT
    row_number() OVER (ORDER BY p.patient_id) AS person_id
    , CASE upper(p.patient_gender)
        WHEN 'M' THEN 8507
        WHEN 'F' THEN 8532
    END AS gender_concept_id
    , extract(YEAR FROM p.birth_date) AS year_of_birth
    , extract(MONTH FROM p.birth_date) AS month_of_birth
    , extract(DAY FROM p.birth_date) AS day_of_birth
    , {{ dbt.cast("NULL", api.Column.translate_type("timestamp")) }} AS birth_datetime
    , CASE upper(p.race)
        WHEN 'WHITE' THEN 8527
        WHEN 'BLACK' THEN 8516
        WHEN 'ASIAN' THEN 8515
        ELSE 0
    END AS race_concept_id
    , CASE
        WHEN upper(p.ethnicity) = 'HISPANIC' THEN 38003563
        WHEN upper(p.ethnicity) = 'NONHISPANIC' THEN 38003564
        ELSE 0
    END AS ethnicity_concept_id
    , loc.location_id
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }}  AS provider_id
    , {{ dbt.cast("NULL", api.Column.translate_type("integer")) }}  AS care_site_id
    , p.patient_id AS person_source_value
    , p.patient_gender AS gender_source_value
    , 0 AS gender_source_concept_id
    , p.race AS race_source_value
    , 0 AS race_source_concept_id
    , p.ethnicity AS ethnicity_source_value
    , 0 AS ethnicity_source_concept_id
FROM {{ ref('stg_synthea__patients') }} AS p
LEFT JOIN {{ ref('location') }} loc
    -- Address and city provides enough entropy to join on safely
    ON (p.patient_address = loc.address_1 AND p.patient_city = loc.city)

WHERE p.patient_gender IS NOT NULL
