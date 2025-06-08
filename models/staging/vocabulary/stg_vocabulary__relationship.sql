{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('vocabulary', 'relationship') ) 
%}


WITH cte_relationship_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('vocabulary','relationship') }}
)

SELECT

    relationship_id
    , relationship_name
    , {{ dbt.cast("is_hierarchical", api.Column.translate_type("varchar")) }} AS is_hierarchical
    , {{ dbt.cast("defines_ancestry", api.Column.translate_type("varchar")) }} AS defines_ancestry
    , reverse_relationship_id
    , relationship_concept_id

FROM cte_relationship_lower
