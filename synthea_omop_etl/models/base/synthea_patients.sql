-- Returns a list of the columns from a relation, so you can then iterate in a for loop
{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'patients') ) 
%}


WITH patients AS (

    SELECT  *
    FROM {{ source('synthea','patients' ) }}
) 

select  
{% for column_name in column_names %}
    "{{ column_name }}" as {{ column_name | lower }}
    {% if not loop.last %},{% endif %}
{% endfor %}

FROM patients