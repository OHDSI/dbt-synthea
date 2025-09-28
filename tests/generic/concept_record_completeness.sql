{% test concept_record_completeness(model, column_name, threshold) %}

{%- set model_name = model.identifier -%}

WITH validation AS (

    SELECT
        {{ column_name }} AS concept_field
        {% if (column_name == 'unit_concept_id' or column_name == 'unit_source_concept_id') and model_name != 'dose_era' %}
        , unit_source_value
        {% endif %}
        {% if column_name == 'admitted_from_concept_id' %}
        , admitted_from_source_value
        {% endif %}
        {% if column_name == 'admitting_source_concept_id' %}
        , admitting_source_value
        {% endif %}
        {% if column_name == 'discharged_to_concept_id' %}
        , discharged_to_source_value
        {% endif %}
        {% if column_name == 'discharge_to_concept_id' %}
        , discharge_to_source_value
        {% endif %}
        {% if column_name == 'condition_status_concept_id' %}
        , condition_status_source_value
        {% endif %}
        {% if column_name == 'route_concept_id' %}
        , route_source_value
        {% endif %}
        {% if column_name == 'modifier_concept_id' %}
        , modifier_source_value
        {% endif %}
        {% if column_name == 'qualifier_concept_id' %}
        , qualifier_source_value
        {% endif %}
        {% if column_name == 'cause_concept_id' or column_name == 'cause_source_concept_id' %}
        , cause_source_value
        {% endif %}
        {% if column_name == 'anatomic_site_concept_id' %}
        , anatomic_site_source_value
        {% endif %}
        {% if column_name == 'disease_status_concept_id' %}
        , disease_status_source_value
        {% endif %}
        {% if column_name == 'country_concept_id' %}
        , country_source_value
        {% endif %}
        {% if column_name == 'place_of_service_concept_id' %}
        , place_of_service_source_value
        {% endif %}
        {% if column_name == 'specialty_concept_id' or column_name == 'specialty_source_concept_id' %}
        , specialty_source_value
        {% endif %}
        {% if model_name == 'provider' and (column_name == 'gender_concept_id' or column_name == 'gender_source_concept_id') %}
        , gender_source_value
        {% endif %}
        {% if column_name == 'payer_concept_id' or column_name == 'payer_source_concept_id' %}
        , payer_source_value
        {% endif %}
        {% if column_name == 'plan_concept_id' or column_name == 'plan_source_concept_id' %}
        , plan_source_value
        {% endif %}
        {% if column_name == 'sponsor_concept_id' or column_name == 'sponsor_source_concept_id' %}
        , sponsor_source_value
        {% endif %}
        {% if column_name == 'stop_reason_concept_id' or column_name == 'stop_reason_source_concept_id' %}
        , stop_reason_source_value
        {% endif %}

    FROM {{ model }}
    WHERE {{ column_name }} IS NOT NULL
    {% if model_name != 'dose_era' and (column_name == 'unit_concept_id' or column_name == 'unit_source_concept_id') %}
    OR unit_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'admitted_from_concept_id' %}
    OR admitted_from_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'admitting_source_concept_id' %}
    OR admitting_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'discharged_to_concept_id' %}
    OR discharged_to_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'discharge_to_concept_id' %}
    OR discharge_to_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'condition_status_concept_id' %}
    OR condition_status_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'route_concept_id' %}
    OR route_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'modifier_concept_id' %}
    OR modifier_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'qualifier_concept_id' %}
    OR qualifier_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'cause_concept_id' or column_name == 'cause_source_concept_id' %}
    OR cause_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'anatomic_site_concept_id' %}
    OR anatomic_site_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'disease_status_concept_id' %}
    OR disease_status_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'country_concept_id' %}
    OR country_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'place_of_service_concept_id' %}
    OR place_of_service_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'specialty_concept_id' or column_name == 'specialty_source_concept_id' %}
    OR specialty_source_value IS NOT NULL
    {% endif %}
    {% if model_name == 'provider' and (column_name == 'gender_concept_id' or column_name == 'gender_source_concept_id') %}
    OR gender_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'payer_concept_id' or column_name == 'payer_source_concept_id' %}
    OR payer_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'plan_concept_id' or column_name == 'plan_source_concept_id' %}
    OR plan_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'sponsor_concept_id' or column_name == 'sponsor_source_concept_id' %}
    OR sponsor_source_value IS NOT NULL
    {% endif %}
    {% if column_name == 'stop_reason_concept_id' or column_name == 'stop_reason_source_concept_id' %}
    OR stop_reason_source_value IS NOT NULL
    {% endif %}

),

denominator AS (

    SELECT 
        CASE 
            WHEN COUNT(*) = 0 THEN 1
            ELSE COUNT(*)
        END AS denom
    FROM validation

),

validation_errors AS (

    SELECT 1
    FROM validation
    CROSS JOIN denominator
    GROUP BY denom
    HAVING
        SUM(
            CASE 
                WHEN 
                    concept_field = 0 
                    {% if model_name != 'dose_era' and (column_name == 'unit_concept_id' or column_name == 'unit_source_concept_id') %}
                    OR (concept_field IS NULL AND unit_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'admitted_from_concept_id' %}
                    OR (concept_field IS NULL AND admitted_from_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'admitting_source_concept_id' %}
                    OR (concept_field IS NULL AND admitting_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'discharged_to_concept_id' %}
                    OR (concept_field IS NULL AND discharged_to_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'discharge_to_concept_id' %}
                    OR (concept_field IS NULL AND discharge_to_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'condition_status_concept_id' %}
                    OR (concept_field IS NULL AND condition_status_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'route_concept_id' %}
                    OR (concept_field IS NULL AND route_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'modifier_concept_id' %}
                    OR (concept_field IS NULL AND modifier_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'qualifier_concept_id' %}
                    OR (concept_field IS NULL AND qualifier_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'cause_concept_id' or column_name == 'cause_source_concept_id' %}
                    OR (concept_field IS NULL AND cause_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'anatomic_site_concept_id' %}
                    OR (concept_field IS NULL AND anatomic_site_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'disease_status_concept_id' %}
                    OR (concept_field IS NULL AND disease_status_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'country_concept_id' %}
                    OR (concept_field IS NULL AND country_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'place_of_service_concept_id' %}
                    OR (concept_field IS NULL AND place_of_service_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'specialty_concept_id' or column_name == 'specialty_source_concept_id' %}
                    OR (concept_field IS NULL AND specialty_source_value IS NOT NULL)
                    {% endif %}
                    {% if model_name == 'provider' and (column_name == 'gender_concept_id' or column_name == 'gender_source_concept_id') %}
                    OR (concept_field IS NULL AND gender_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'payer_concept_id' or column_name == 'payer_source_concept_id' %}
                    OR (concept_field IS NULL AND payer_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'plan_concept_id' or column_name == 'plan_source_concept_id' %}
                    OR (concept_field IS NULL AND plan_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'sponsor_concept_id' or column_name == 'sponsor_source_concept_id' %}
                    OR (concept_field IS NULL AND sponsor_source_value IS NOT NULL)
                    {% endif %}
                    {% if column_name == 'stop_reason_concept_id' or column_name == 'stop_reason_source_concept_id' %}
                    OR (concept_field IS NULL AND stop_reason_source_value IS NOT NULL)
                    {% endif %}
                    THEN 1 
                ELSE 0 
            END
        ) * 100.0 / denom > {{ threshold }}

)

SELECT *
FROM validation_errors

{% endtest %}