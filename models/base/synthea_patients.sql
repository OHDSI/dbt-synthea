WITH patients AS (

    SELECT
        "Id" AS patient_id,
        "BIRTHDATE" AS patient_birth_date
    FROM {{ ref('patients') }}

)

SELECT *
FROM patients
