SELECT 
    condition_concept_id,
    condition_era_start_date,
    condition_era_end_date,
    condition_occurrence_count
FROM dbt_synthea_dev.condition_era
EXCEPT 
SELECT 
    condition_concept_id,
    condition_era_start_date,
    condition_era_end_date,
    condition_occurrence_count
FROM etl_synthea.condition_era;

SELECT 
    condition_concept_id,
    condition_era_start_date,
    condition_era_end_date,
    condition_occurrence_count
FROM etl_synthea.condition_era
EXCEPT 
SELECT 
    condition_concept_id,
    condition_era_start_date,
    condition_era_end_date,
    condition_occurrence_count
FROM dbt_synthea_dev.condition_era;

SELECT
    condition_concept_id,
    condition_start_date,
    --, condition_start_datetime
    condition_end_date,
    --, condition_end_datetime
    condition_type_concept_id,
    stop_reason,
    condition_source_value,
    condition_source_concept_id,
    condition_status_source_value,
    condition_status_concept_id
FROM dbt_synthea_dev.condition_occurrence
EXCEPT
SELECT
    condition_concept_id,
    condition_start_date,
    --, condition_start_datetime
    condition_end_date,
    --, condition_end_datetime
    condition_type_concept_id,
    stop_reason,
    condition_source_value,
    condition_source_concept_id,
    condition_status_source_value,
    condition_status_concept_id
FROM etl_synthea.condition_occurrence;

SELECT
    condition_concept_id,
    condition_start_date,
    --, condition_start_datetime
    condition_end_date,
    --, condition_end_datetime
    condition_type_concept_id,
    stop_reason,
    condition_source_value,
    condition_source_concept_id,
    condition_status_source_value,
    condition_status_concept_id
FROM etl_synthea.condition_occurrence
EXCEPT
SELECT
    condition_concept_id,
    condition_start_date,
    --, condition_start_datetime
    condition_end_date,
    --, condition_end_datetime
    condition_type_concept_id,
    stop_reason,
    condition_source_value,
    condition_source_concept_id,
    condition_status_source_value,
    condition_status_concept_id
FROM dbt_synthea_dev.condition_occurrence;

SELECT
    cost_domain_id,
    cost_type_concept_id,
    currency_concept_id,
    total_charge,
    total_cost,
    total_paid,
    paid_by_payer,
    paid_by_patient,
    paid_patient_copay,
    paid_patient_coinsurance,
    paid_patient_deductible,
    paid_by_primary,
    paid_ingredient_cost,
    paid_dispensing_fee,
    amount_allowed,
    revenue_code_concept_id,
    revenue_code_source_value,
    drg_concept_id,
    drg_source_value
FROM dbt_synthea_dev.cost
EXCEPT
SELECT
    cost_domain_id,
    cost_type_concept_id,
    currency_concept_id,
    total_charge,
    total_cost,
    total_paid,
    paid_by_payer,
    paid_by_patient,
    paid_patient_copay,
    paid_patient_coinsurance,
    paid_patient_deductible,
    paid_by_primary,
    paid_ingredient_cost,
    paid_dispensing_fee,
    amount_allowed,
    revenue_code_concept_id,
    revenue_code_source_value,
    drg_concept_id,
    drg_source_value
FROM etl_synthea.cost;

SELECT
    cost_domain_id,
    cost_type_concept_id,
    currency_concept_id,
    total_charge,
    total_cost,
    total_paid,
    paid_by_payer,
    paid_by_patient,
    paid_patient_copay,
    paid_patient_coinsurance,
    paid_patient_deductible,
    paid_by_primary,
    paid_ingredient_cost,
    paid_dispensing_fee,
    amount_allowed,
    revenue_code_concept_id,
    revenue_code_source_value,
    drg_concept_id,
    drg_source_value
FROM etl_synthea.cost
EXCEPT
SELECT
    cost_domain_id,
    cost_type_concept_id,
    currency_concept_id,
    total_charge,
    total_cost,
    total_paid,
    paid_by_payer,
    paid_by_patient,
    paid_patient_copay,
    paid_patient_coinsurance,
    paid_patient_deductible,
    paid_by_primary,
    paid_ingredient_cost,
    paid_dispensing_fee,
    amount_allowed,
    revenue_code_concept_id,
    revenue_code_source_value,
    drg_concept_id,
    drg_source_value
FROM dbt_synthea_dev.cost;

SELECT
    death_date,
    --, death_datetime
    death_type_concept_id,
    cause_concept_id,
    cause_source_value,
    cause_source_concept_id
FROM dbt_synthea_dev.death
EXCEPT
SELECT
    death_date,
    --, death_datetime
    death_type_concept_id,
    cause_concept_id,
    cause_source_value,
    cause_source_concept_id
FROM etl_synthea.death;

SELECT
    death_date,
    --, death_datetime
    death_type_concept_id,
    cause_concept_id,
    cause_source_value,
    cause_source_concept_id
FROM etl_synthea.death
EXCEPT
SELECT
    death_date,
    --, death_datetime
    death_type_concept_id,
    cause_concept_id,
    cause_source_value,
    cause_source_concept_id
FROM dbt_synthea_dev.death;

SELECT
    device_concept_id,
    device_exposure_start_date,
    --, device_exposure_start_datetime
    device_exposure_end_date,
    --, device_exposure_end_datetime
    device_type_concept_id,
    unique_device_id,
    production_id,
    quantity,
    device_source_value,
    device_source_concept_id,
    unit_concept_id,
    unit_source_value,
    unit_source_concept_id
FROM dbt_synthea_dev.device_exposure
EXCEPT
SELECT
    device_concept_id,
    device_exposure_start_date,
    --, device_exposure_start_datetime
    device_exposure_end_date,
    --, device_exposure_end_datetime
    device_type_concept_id,
    unique_device_id,
    production_id,
    quantity,
    device_source_value,
    device_source_concept_id,
    unit_concept_id,
    unit_source_value,
    unit_source_concept_id
FROM etl_synthea.device_exposure;

SELECT
    device_concept_id,
    device_exposure_start_date,
    --, device_exposure_start_datetime
    device_exposure_end_date,
    --, device_exposure_end_datetime
    device_type_concept_id,
    unique_device_id,
    production_id,
    quantity,
    device_source_value,
    device_source_concept_id,
    unit_concept_id,
    unit_source_value,
    unit_source_concept_id
FROM etl_synthea.device_exposure
EXCEPT
SELECT
    device_concept_id,
    device_exposure_start_date,
    --, device_exposure_start_datetime
    device_exposure_end_date,
    --, device_exposure_end_datetime
    device_type_concept_id,
    unique_device_id,
    production_id,
    quantity,
    device_source_value,
    device_source_concept_id,
    unit_concept_id,
    unit_source_value,
    unit_source_concept_id
FROM dbt_synthea_dev.device_exposure;

SELECT 
    drug_concept_id,
    drug_era_start_date,
    drug_era_end_date,
    drug_exposure_count,
    gap_days
FROM dbt_synthea_dev.drug_era
EXCEPT
SELECT 
    drug_concept_id,
    drug_era_start_date,
    drug_era_end_date,
    drug_exposure_count,
    gap_days
FROM etl_synthea.drug_era;

SELECT 
    drug_concept_id,
    drug_era_start_date,
    drug_era_end_date,
    drug_exposure_count,
    gap_days
FROM etl_synthea.drug_era
EXCEPT
SELECT 
    drug_concept_id,
    drug_era_start_date,
    drug_era_end_date,
    drug_exposure_count,
    gap_days
FROM dbt_synthea_dev.drug_era;

SELECT
    drug_concept_id,
    drug_exposure_start_date,
    --, drug_exposure_start_datetime
    drug_exposure_end_date,
    --, drug_exposure_end_datetime
    verbatim_end_date,
    drug_type_concept_id,
    stop_reason,
    refills,
    quantity,
    days_supply,
    sig,
    route_concept_id,
    lot_number,
    drug_source_value,
    drug_source_concept_id,
    route_source_value,
    dose_unit_source_value
FROM dbt_synthea_dev.drug_exposure
EXCEPT
SELECT
    drug_concept_id,
    drug_exposure_start_date,
    --, drug_exposure_start_datetime
    drug_exposure_end_date,
    --, drug_exposure_end_datetime
    verbatim_end_date,
    drug_type_concept_id,
    stop_reason,
    refills,
    quantity,
    days_supply,
    sig,
    route_concept_id,
    lot_number,
    drug_source_value,
    drug_source_concept_id,
    route_source_value,
    dose_unit_source_value
FROM etl_synthea.drug_exposure;

SELECT
    drug_concept_id,
    drug_exposure_start_date,
    --, drug_exposure_start_datetime
    drug_exposure_end_date,
    --, drug_exposure_end_datetime
    verbatim_end_date,
    drug_type_concept_id,
    stop_reason,
    refills,
    quantity,
    days_supply,
    sig,
    route_concept_id,
    lot_number,
    drug_source_value,
    drug_source_concept_id,
    route_source_value,
    dose_unit_source_value
FROM etl_synthea.drug_exposure
EXCEPT
SELECT
    drug_concept_id,
    drug_exposure_start_date,
    --, drug_exposure_start_datetime
    drug_exposure_end_date,
    --, drug_exposure_end_datetime
    verbatim_end_date,
    drug_type_concept_id,
    stop_reason,
    refills,
    quantity,
    days_supply,
    sig,
    route_concept_id,
    lot_number,
    drug_source_value,
    drug_source_concept_id,
    route_source_value,
    dose_unit_source_value
FROM dbt_synthea_dev.drug_exposure;

SELECT
    measurement_concept_id,
    measurement_date,
    --, measurement_datetime
    --, measurement_time
    measurement_type_concept_id,
    operator_concept_id,
    value_as_number,
    value_as_concept_id,
    unit_concept_id,
    range_low,
    range_high,
    measurement_source_value,
    measurement_source_concept_id,
    unit_source_value,
    value_source_value,
    unit_source_concept_id,
    meas_event_field_concept_id
FROM dbt_synthea_dev.measurement
EXCEPT
SELECT
    measurement_concept_id,
    measurement_date,
    --, measurement_datetime
    --, measurement_time
    measurement_type_concept_id,
    operator_concept_id,
    value_as_number,
    value_as_concept_id,
    unit_concept_id,
    range_low,
    range_high,
    measurement_source_value,
    measurement_source_concept_id,
    unit_source_value,
    value_source_value,
    unit_source_concept_id,
    meas_event_field_concept_id
FROM etl_synthea.measurement;

SELECT
    measurement_concept_id,
    measurement_date,
    --, measurement_datetime
    --, measurement_time
    measurement_type_concept_id,
    operator_concept_id,
    value_as_number,
    value_as_concept_id,
    unit_concept_id,
    range_low,
    range_high,
    measurement_source_value,
    measurement_source_concept_id,
    unit_source_value,
    value_source_value,
    unit_source_concept_id,
    meas_event_field_concept_id
FROM etl_synthea.measurement
EXCEPT
SELECT
    measurement_concept_id,
    measurement_date,
    --, measurement_datetime
    --, measurement_time
    measurement_type_concept_id,
    operator_concept_id,
    value_as_number,
    value_as_concept_id,
    unit_concept_id,
    range_low,
    range_high,
    measurement_source_value,
    measurement_source_concept_id,
    unit_source_value,
    value_source_value,
    unit_source_concept_id,
    meas_event_field_concept_id
FROM dbt_synthea_dev.measurement;

SELECT
    observation_period_start_date,
    observation_period_end_date,
    period_type_concept_id
FROM dbt_synthea_dev.observation_period
EXCEPT
SELECT
    observation_period_start_date,
    observation_period_end_date,
    period_type_concept_id
FROM etl_synthea.observation_period;

SELECT
    observation_period_start_date,
    observation_period_end_date,
    period_type_concept_id
FROM etl_synthea.observation_period
EXCEPT
SELECT
    observation_period_start_date,
    observation_period_end_date,
    period_type_concept_id
FROM dbt_synthea_dev.observation_period;

SELECT
    observation_concept_id,
    observation_date,
    --, observation_datetime
    observation_type_concept_id,
    value_as_number,
    value_as_string,
    value_as_concept_id,
    qualifier_concept_id,
    unit_concept_id,
    observation_source_value,
    observation_source_concept_id,
    unit_source_value,
    qualifier_source_value,
    value_source_value,
    observation_event_id,
    obs_event_field_concept_id
FROM dbt_synthea_dev.observation
EXCEPT
SELECT
    observation_concept_id,
    observation_date,
    --, observation_datetime
    observation_type_concept_id,
    value_as_number,
    value_as_string,
    value_as_concept_id,
    qualifier_concept_id,
    unit_concept_id,
    observation_source_value,
    observation_source_concept_id,
    unit_source_value,
    qualifier_source_value,
    value_source_value,
    observation_event_id,
    obs_event_field_concept_id
FROM etl_synthea.observation;

SELECT
    observation_concept_id,
    observation_date,
    --, observation_datetime
    observation_type_concept_id,
    value_as_number,
    value_as_string,
    value_as_concept_id,
    qualifier_concept_id,
    unit_concept_id,
    observation_source_value,
    observation_source_concept_id,
    unit_source_value,
    qualifier_source_value,
    value_source_value,
    observation_event_id,
    obs_event_field_concept_id
FROM etl_synthea.observation
EXCEPT
SELECT
    observation_concept_id,
    observation_date,
    --, observation_datetime
    observation_type_concept_id,
    value_as_number,
    value_as_string,
    value_as_concept_id,
    qualifier_concept_id,
    unit_concept_id,
    observation_source_value,
    observation_source_concept_id,
    unit_source_value,
    qualifier_source_value,
    value_source_value,
    observation_event_id,
    obs_event_field_concept_id
FROM dbt_synthea_dev.observation;

SELECT
    payer_plan_period_start_date,
    payer_plan_period_end_date,
    payer_source_value
FROM dbt_synthea_dev.payer_plan_period
EXCEPT
SELECT
    payer_plan_period_start_date,
    payer_plan_period_end_date,
    payer_source_value
FROM etl_synthea.payer_plan_period;

SELECT
    payer_plan_period_start_date,
    payer_plan_period_end_date,
    payer_source_value
FROM etl_synthea.payer_plan_period
EXCEPT
SELECT
    payer_plan_period_start_date,
    payer_plan_period_end_date,
    payer_source_value
FROM dbt_synthea_dev.payer_plan_period;

SELECT
    person_id,
    gender_concept_id,
    year_of_birth,
    month_of_birth,
    day_of_birth,
    --, birth_datetime
    race_concept_id,
    ethnicity_concept_id,
    person_source_value,
    gender_source_value,
    gender_source_concept_id,
    race_source_value,
    , ethnicity_source_concept_id
from etl_synthea.person;
select
person_id
    , gender_concept_id
    , year_of_birth
    , month_of_birth
    , day_of_birth
    --, birth_datetime
    , race_concept_id
    , ethnicity_concept_id
    , person_source_value
    , gender_source_value
    , gender_source_concept_id
    , race_source_value
    , race_source_concept_id
    , ethnicity_source_value
    , ethnicity_source_concept_id
from etl_synthea.person
except
select
person_id
    , gender_concept_id
    , year_of_birth
    , month_of_birth
    , day_of_birth
    --, birth_datetime
    , race_concept_id
    , ethnicity_concept_id
    , person_source_value
    , gender_source_value
    , gender_source_concept_id
    , race_source_value
    , race_source_concept_id
    , ethnicity_source_value
    , ethnicity_source_concept_id
from dbt_synthea_dev.person;
select
    procedure_concept_id
    ,  procedure_date
    --, procedure_datetime
    , procedure_end_date
    --, procedure_end_datetime
    , procedure_type_concept_id
    , modifier_concept_id
    , quantity
    , procedure_source_value
    , procedure_source_concept_id
    , modifier_source_value
from dbt_synthea_dev.procedure_occurrence
except
select
    procedure_concept_id
    ,  procedure_date
    --, procedure_datetime
    , procedure_end_date
    --, procedure_end_datetime
    , procedure_type_concept_id
    , modifier_concept_id
    , quantity
    , procedure_source_value
    , procedure_source_concept_id
    , modifier_source_value
from etl_synthea.procedure_occurrence;
select
    procedure_concept_id
    ,  procedure_date
    --, procedure_datetime
    , procedure_end_date
    --, procedure_end_datetime
    , procedure_type_concept_id
    , modifier_concept_id
    , quantity
    , procedure_source_value
    , procedure_source_concept_id
    , modifier_source_value
from etl_synthea.procedure_occurrence
except
select
    procedure_concept_id
    ,  procedure_date
    --, procedure_datetime
    , procedure_end_date
    --, procedure_end_datetime
    , procedure_type_concept_id
    , modifier_concept_id
    , quantity
    , procedure_source_value
    , procedure_source_concept_id
    , modifier_source_value
from dbt_synthea_dev.procedure_occurrence;
select
     provider_name
    , npi
    , dea
    , specialty_concept_id
    , care_site_id
    , year_of_birth
    , gender_concept_id
    , provider_source_value
    , specialty_source_value
    , specialty_source_concept_id
    , gender_source_value
    , gender_source_concept_id
from dbt_synthea_dev.provider
except
select
    provider_name
    , npi
    , dea
    , specialty_concept_id
    , care_site_id
    , year_of_birth
    , gender_concept_id
    , provider_source_value
    , specialty_source_value
    , specialty_source_concept_id
    , gender_source_value
    , gender_source_concept_id
from etl_synthea.provider;
select
    provider_name
    , npi
    , dea
    , specialty_concept_id
    , care_site_id
    , year_of_birth
    , gender_concept_id
    , provider_source_value
    , specialty_source_value
    , specialty_source_concept_id
    , gender_source_value
    , gender_source_concept_id
from etl_synthea.provider
except
select
    provider_name
    , npi
    , dea
    , specialty_concept_id
    , care_site_id
    , year_of_birth
    , gender_concept_id
    , provider_source_value
    , specialty_source_value
    , specialty_source_concept_id
    , gender_source_value
    , gender_source_concept_id
from dbt_synthea_dev.provider;
select
    visit_detail_concept_id
    , visit_detail_start_date
    , visit_detail_end_date
    ,visit_detail_type_concept_id
    --,  admitted_from_source_concept_id
    , discharged_to_concept_id
    , visit_detail_source_value
    , visit_detail_source_concept_id
    , admitted_from_source_value
    , discharged_to_source_value
from dbt_synthea_dev.visit_detail
except
select
    visit_detail_concept_id
    , visit_detail_start_date
    , visit_detail_end_date
    ,visit_detail_type_concept_id
    --,  admitted_from_source_concept_id
    , discharged_to_concept_id
    , visit_detail_source_value
    , visit_detail_source_concept_id
    , admitted_from_source_value
    , discharged_to_source_value
from etl_synthea.visit_detail;
select
    visit_detail_concept_id
    , visit_detail_start_date
    , visit_detail_end_date
    ,visit_detail_type_concept_id
    --,  admitted_from_source_concept_id
    , discharged_to_concept_id
    , visit_detail_source_value
    , visit_detail_source_concept_id
    , admitted_from_source_value
    , discharged_to_source_value
from etl_synthea.visit_detail
except
select
    visit_detail_concept_id
    , visit_detail_start_date
    , visit_detail_end_date
    ,visit_detail_type_concept_id
    --,  admitted_from_source_concept_id
    , discharged_to_concept_id
    , visit_detail_source_value
    , visit_detail_source_concept_id
    , admitted_from_source_value
    , discharged_to_source_value
from dbt_synthea_dev.visit_detail;
select
    visit_concept_id
    , visit_start_date
    , visit_end_date
    , visit_type_concept_id
    , visit_source_value
    , visit_source_concept_id
    , admitted_from_concept_id
    , admitted_from_source_value
    , discharged_to_concept_id
    ,  discharged_to_source_value
from dbt_synthea_dev.visit_occurrence
except
select
    visit_concept_id
    , visit_start_date
    , visit_end_date
    , visit_type_concept_id
    , visit_source_value
    , visit_source_concept_id
    , admitted_from_concept_id
    , admitted_from_source_value
    , discharged_to_concept_id
    , discharged_to_source_value
from etl_synthea.visit_occurrence;
select
    visit_concept_id
    , visit_start_date
    , visit_end_date
    , visit_type_concept_id
    , visit_source_value
    , visit_source_concept_id
    , admitted_from_concept_id
    , admitted_from_source_value
    , discharged_to_concept_id
    , discharged_to_source_value
from etl_synthea.visit_occurrence
except
select
    visit_concept_id
    , visit_start_date
    , visit_end_date
    , visit_type_concept_id
    , visit_source_value
    , visit_source_concept_id
    , admitted_from_concept_id
    , admitted_from_source_value
    , discharged_to_concept_id
    , discharged_to_source_value
from dbt_synthea_dev.visit_occurrence;