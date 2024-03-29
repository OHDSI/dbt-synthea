-- Returns a list of the columns from a relation, so you can then iterate in a for loop
{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'patients') ) 
%}


WITH cte_patients_lower AS (

    SELECT  

        {% for column_name in column_names %}
            "{{ column_name }}" as {{ column_name | lower }}
        {% if not loop.last %},{% endif %}
        {% endfor %}
        
    FROM {{ source('synthea','patients') }}
) 

, cte_patients_rename AS (

    SELECT 
        id AS patient_id
        , birthdate AS patient_birth_date
        , deathdate AS patient_death_date
        , ssn AS patient_ssn
        , drivers AS patient_drivers_license_number
        , passport AS patient_passport_number
        , prefix AS patient_prefix
        , first AS patient_first_name
        , last AS patient_last_name
        , suffix AS patient_suffix
        , maiden AS patient_maiden_name
        , marital AS patient_marital_status
        , race AS patient_race
        , ethnicity AS patient_ethnicity
        , gender AS patient_gender
        , birthplace AS patient_birthplace
        , address AS patient_address
        , city AS patient_city
        , state AS patient_state
        , county AS patient_county
        , zip AS patient_zip
        , lat AS patient_latitude
        , lon AS patient_longitude
        , healthcare_expenses AS patient_healthcare_expenses
        , healthcare_coverage AS patient_healthcare_coverage
    FROM cte_patients_lower

)

SELECT  * 
FROM cte_patients_rename