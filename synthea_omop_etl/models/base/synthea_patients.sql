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
        
    FROM {{ source('synthea','patients' ) }}
) 
, cte_patients as (
    select 
    id as patient_id
    , birthdate as patient_birth_date
    , race as patient_race
    , ethnicity as patient_ethnicity
    from cte_patients_lower
)
SELECT  * 
FROM cte_patients