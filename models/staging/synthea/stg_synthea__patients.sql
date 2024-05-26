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
        , birthdate AS birth_date
        , deathdate AS death_date
        , ssn AS ssn
        , drivers AS drivers_license_number
        , passport AS passport_number
        , prefix AS patient_prefix
        , first AS patient_first_name
        , last AS patient_last_name
        , suffix AS patient_suffix
        , maiden AS maiden_name
        , marital AS marital_status
        , race AS race
        , ethnicity AS ethnicity
        , gender AS gender
        , birthplace AS birthplace
        , address AS patient_address
        , city AS patient_city
        , state AS patient_state
        , county AS patient_county
        , zip AS patient_zip
        , lat AS patient_latitude
        , lon AS patient_longitude
        , healthcare_expenses AS healthcare_expenses
        , healthcare_coverage AS healthcare_coverage
    FROM cte_patients_lower

)

SELECT  * 
FROM cte_patients_rename