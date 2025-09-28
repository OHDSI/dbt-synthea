{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('vocabulary', 'source_to_concept_map_seed') ) 
%}


WITH cte_stcm_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('vocabulary','source_to_concept_map_seed') }}
)

SELECT *
FROM cte_stcm_lower
