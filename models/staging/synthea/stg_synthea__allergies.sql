-- Returns a list of the columns from a relation, so you can then iterate in a for loop
{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'allergies') ) 
%}


WITH cte_allergies_lower AS (

    SELECT  

        {% for column_name in column_names %}
            "{{ column_name }}" as {{ column_name | lower }}
        {% if not loop.last %},{% endif %}
        {% endfor %}
        
    FROM {{ source('synthea','allergies') }}
) 

, cte_allergies_rename AS (

    SELECT 
        start AS allergy_start_date
        , stop AS allergy_stop_date
        , patient AS patient_id
        , encounter AS encounter_id
        , code AS allergy_code
        , system AS allergy_code_system
        , description AS allergy_description
        , type AS allergy_type
        , category AS allergy_category
        , reaction1 AS reaction1_code
        , description1 AS reaction1_description
        , severity1 AS reaction1_severity
        , reaction2 AS reaction2_code
        , description2 AS reaction2_description
        , severity2 AS reaction2_severity
    FROM cte_allergies_lower

)

SELECT  * 
FROM cte_allergies_rename