SELECT
    {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS fact_relationship_id
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS domain_concept_id_1
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS fact_id_1
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS domain_concept_id_2
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS fact_id_2
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS relationship_concept_id
WHERE 1 = 0
