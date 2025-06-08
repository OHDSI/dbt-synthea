{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('vocabulary', 'concept_relationship') ) 
%}


WITH cte_concept_relationship_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('vocabulary','concept_relationship') }}
)

SELECT
    concept_id_1
    , concept_id_2
    , relationship_id
    , valid_start_date
    , valid_end_date
    , {{ dbt.cast("invalid_reason", api.Column.translate_type("varchar")) }} AS invalid_reason
FROM cte_concept_relationship_lower
