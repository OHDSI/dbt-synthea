SELECT
    drug_exposure_id
    , person_id
    , drug_concept_id
    , drug_exposure_start_date
    , drug_exposure_start_datetime
    , drug_exposure_end_date
    , drug_exposure_end_datetime
    , verbatim_end_date
    , drug_type_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS stop_reason
    , {{ dbt.cast("null", api.Column.translate_type("integer")) }} AS refills
    , {{ dbt.cast("null", api.Column.translate_type("float")) }} AS quantity
    , days_supply
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS sig
    , route_concept_id
    , lot_number
    , provider_id
    , visit_occurrence_id
    , visit_detail_id
    , drug_source_value
    , drug_source_concept_id
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS route_source_value
    , {{ dbt.cast("null", api.Column.translate_type("varchar")) }} AS dose_unit_source_value
FROM {{ ref('int__drug_exposure') }}
