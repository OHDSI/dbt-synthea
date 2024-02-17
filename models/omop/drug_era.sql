-- Code taken from:
-- https://github.com/OHDSI/ETL-CMS/blob/master/SQL/create_CDMv5_drug_era_non_stockpile.sql

with ctePreDrugTarget as (
  -- Normalize DRUG_EXPOSURE_END_DATE to either the existing drug exposure end date, or add days supply, or add 1 day to the start date
  select
    d.drug_exposure_id,
    d.person_id,
    c.concept_id as ingredient_concept_id,
    d.drug_exposure_start_date as drug_exposure_start_date,
    d.days_supply as days_supply,
    coalesce(
      ---NULLIF returns NULL if both values are the same, otherwise it returns the first parameter
      nullif(drug_exposure_end_date, NULL),
      ---If drug_exposure_end_date != NULL, return drug_exposure_end_date, otherwise go to next case
      nullif(
        dateadd(day, days_supply, drug_exposure_start_date),
        drug_exposure_start_date
      ),
      ---If days_supply != NULL or 0, return drug_exposure_start_date + days_supply, otherwise go to next case
      dateadd(day, 1, drug_exposure_start_date)
    ---Add 1 day to the drug_exposure_start_date since there is no end_date or INTERVAL for the days_supply
    ) as drug_exposure_end_date
  from {{ ref ('drug_exposure') }} as d
  inner join
    {{ ref ('concept_ancestor') }} as ca
    on d.drug_concept_id = ca.descendant_concept_id
  inner join {{ ref ('concept') }} as c on ca.ancestor_concept_id = c.concept_id
  where
    c.vocabulary_id = 'RxNorm' ---8 selects RxNorm from the vocabulary_id
    and c.concept_class_id = 'Ingredient'
    and d.drug_concept_id != 0 ---Our unmapped drug_concept_id's are set to 0, so we don't want different drugs wrapped up in the same era
    and coalesce(d.days_supply, 0) >= 0 ---We have cases where days_supply is negative, and this can set the end_date before the start_date, which we don't want. So we're just looking over those rows. This is a data-quality issue.
),

cteSubExposureEndDates as (
  --- A preliminary sorting that groups all of the overlapping exposures into one exposure so that we don't double-count non-gap-days(
  select
    person_id,
    ingredient_concept_id,
    event_date as end_date
  from
    (
      select
        person_id,
        ingredient_concept_id,
        event_date,
        event_type,
        max(start_ordinal) over (
          partition by person_id, ingredient_concept_id
          order by event_date, event_type rows unbounded preceding
        ) as start_ordinal,
        -- this pulls the current START down from the prior rows so that the NULLs
        -- from the END DATES will contain a value we can compare with
        row_number() over (
          partition by person_id, ingredient_concept_id
          order by event_date, event_type
        ) as overall_ord
      -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
      from (
        -- select the start dates, assigning a row number to each
        select
          person_id,
          ingredient_concept_id,
          drug_exposure_start_date as event_date,
          -1 as event_type,
          row_number() over (
            partition by person_id, ingredient_concept_id
            order by drug_exposure_start_date
          ) as start_ordinal
        from ctePreDrugTarget

        union all

        select
          person_id,
          ingredient_concept_id,
          drug_exposure_end_date,
          1 as event_type,
          NULL
        from ctePreDrugTarget
      ) as RAWDATA
    ) as e
  where (2 * e.start_ordinal) - e.overall_ord = 0
),

cteDrugExposureEnds as (
  select
    dt.person_id,
    dt.ingredient_concept_id,
    dt.drug_exposure_start_date,
    min(e.end_date) as drug_sub_exposure_end_date
  from ctePreDrugTarget as dt
  inner join
    cteSubExposureEndDates as e
    on
      dt.person_id = e.person_id
      and dt.ingredient_concept_id = e.ingredient_concept_id
      and dt.drug_exposure_start_date <= e.end_date
  group by
    dt.drug_exposure_id,
    dt.person_id,
    dt.ingredient_concept_id,
    dt.drug_exposure_start_date
),

cteSubExposures (
  row_number,
  person_id,
  ingredient_concept_id,
  drug_sub_exposure_start_date,
  drug_sub_exposure_end_date,
  drug_exposure_count
) as (
  select
    row_number() over (
      partition by person_id,
      ingredient_concept_id,
      drug_sub_exposure_end_date order by person_id
    ),
    person_id,
    ingredient_concept_id,
    min(drug_exposure_start_date) as drug_sub_exposure_start_date,
    drug_sub_exposure_end_date,
    count(*) as drug_exposure_count
  from cteDrugExposureEnds
  group by person_id, ingredient_concept_id, drug_sub_exposure_end_date
--ORDER BY person_id, drug_concept_id
),

--------------------------------------------------------------------------------------------------------------
/*Everything above grouped exposures into sub_exposures if there was overlap between exposures.
 *So there was no persistence window. Now we can add the persistence window to calculate eras.
 */
--------------------------------------------------------------------------------------------------------------
cteFinalTarget (
  row_number,
  person_id,
  ingredient_concept_id,
  drug_sub_exposure_start_date,
  drug_sub_exposure_end_date,
  drug_exposure_count,
  days_exposed
) as (
  select
    row_number,
    person_id,
    ingredient_concept_id,
    drug_sub_exposure_start_date,
    drug_sub_exposure_end_date,
    drug_exposure_count,
    datediff(day, drug_sub_exposure_start_date, drug_sub_exposure_end_date)
      as days_exposed
  from cteSubExposures
),

--------------------------------------------------------------------------------------------------------------
cteEndDates (person_id, ingredient_concept_id, end_date) as (
  -- the magic
  -- unpad the end date
  select
    person_id,
    ingredient_concept_id,
    dateadd(day, -30, event_date) as end_date
  from
    (
      select
        person_id,
        ingredient_concept_id,
        event_date,
        event_type,
        max(start_ordinal) over (
          partition by person_id, ingredient_concept_id
          order by event_date, event_type rows unbounded preceding
        ) as start_ordinal,
        -- this pulls the current START down from the prior rows so that the NULLs
        -- from the END DATES will contain a value we can compare with
        row_number() over (
          partition by person_id, ingredient_concept_id
          order by event_date, event_type
        ) as overall_ord
      -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
      from (
        -- select the start dates, assigning a row number to each
        select
          person_id,
          ingredient_concept_id,
          drug_sub_exposure_start_date as event_date,
          -1 as event_type,
          row_number() over (
            partition by person_id, ingredient_concept_id
            order by drug_sub_exposure_start_date
          ) as start_ordinal
        from cteFinalTarget

        union all

        -- pad the end dates by 30 to allow a grace period for overlapping ranges.
        select
          person_id,
          ingredient_concept_id,
          dateadd(day, 30, drug_sub_exposure_end_date),
          1 as event_type,
          NULL
        from cteFinalTarget
      ) as RAWDATA
    ) as e
  where (2 * e.start_ordinal) - e.overall_ord = 0

),

cteDrugEraEnds as (
  select
    ft.person_id,
    ft.ingredient_concept_id as drug_concept_id,
    ft.drug_sub_exposure_start_date,
    min(e.end_date) as drug_era_end_date,
    drug_exposure_count,
    days_exposed
  from cteFinalTarget as ft
  inner join
    cteEndDates as e
    on
      ft.person_id = e.person_id
      and ft.ingredient_concept_id = e.ingredient_concept_id
      and ft.drug_sub_exposure_start_date <= e.end_date
  group by
    ft.person_id,
    ft.ingredient_concept_id,
    ft.drug_sub_exposure_start_date,
    drug_exposure_count,
    days_exposed
)

select
  row_number() over (order by person_id) as drug_era_id,
  person_id,
  drug_concept_id,
  min(drug_sub_exposure_start_date) as drug_era_start_date,
  drug_era_end_date,
  sum(drug_exposure_count) as drug_exposure_count,
  datediff(day, min(drug_sub_exposure_start_date), drug_era_end_date)
  - sum(days_exposed) as gap_days
from cteDrugEraEnds
group by person_id, drug_concept_id, drug_era_end_date
