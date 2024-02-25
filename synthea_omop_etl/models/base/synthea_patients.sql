-- Returns a list of the columns from a relation, so you can then iterate in a for loop
{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'patients') ) 
%}


WITH patients AS (

    SELECT  

        {% for column_name in column_names %}
            {% if column_name == "Id" %}
            "{{ column_name }}" as patient_id
            {% elif column_name ==  "BIRTHDATE" %}
            "{{ column_name }}" as  patient_birth_date
            {% else %}
            "{{ column_name }}" as {{ column_name | lower }}
            {% endif %}
        {% if not loop.last %},{% endif %}
        {% endfor %}
        
    FROM {{ source('synthea','patients' ) }}
) 

SELECT  *

FROM patients