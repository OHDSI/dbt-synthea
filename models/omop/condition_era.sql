-- This script is taken from here:
-- https://github.com/OHDSI/ETL-CMS/blob/master/SQL/create_CDMv5_condition_era.sql

with cteConditionTarget as (
  select
    co.condition_occurrence_id,
    co.person_id,
    co.condition_concept_id,
    co.condition_start_date,
    coalesce(
      nullif(co.condition_end_date, NULL), co.condition_start_date + interval '1 day'
    ) as condition_end_date
  from {{ ref ('condition_occurrence') }} as co
/* Depending on the needs of your data, you can put more filters on to your code. We assign 0 to our unmapped condition_concept_id's,
   * and since we don't want different conditions put in the same era, we put in the filter below.
   */
---WHERE condition_concept_id != 0
),

cteEndDates as (
  select
    person_id,
    condition_concept_id,
    event_date - interval '30 days' as end_date -- unpad the end date
  from
    (
      select
        person_id,
        condition_concept_id,
        event_date,
        event_type,
        max(start_ordinal) over (partition by person_id, condition_concept_id order by event_date, event_type rows unbounded preceding) as start_ordinal, -- this pulls the current START down from the prior rows so that the NULLs from the END DATES will contain a value we can compare with
        row_number() over (partition by person_id, condition_concept_id order by event_date, event_type) as overall_ord -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
      from
        (
          -- select the start dates, assigning a row number to each
          select
            person_id,
            condition_concept_id,
            condition_start_date as event_date,
            -1 as event_type,
            row_number() over (
              partition by person_id,
              condition_concept_id order by condition_start_date
            ) as start_ordinal
          from cteConditionTarget

          union all

          -- pad the end dates by 30 to allow a grace period for overlapping ranges.
          select
            person_id,
            condition_concept_id,
            condition_end_date + interval '30 days',
            1 as event_type,
            NULL
          from cteConditionTarget
        ) as RAWDATA
    ) as e
  where (2 * e.start_ordinal) - e.overall_ord = 0
),

cteConditionEnds as (
  select
    c.person_id,
    c.condition_concept_id,
    c.condition_start_date,
    min(e.end_date) as era_end_date
  from cteConditionTarget as c
  inner join
    cteEndDates as e
    on
      c.person_id = e.person_id
      and c.condition_concept_id = e.condition_concept_id
      and c.condition_start_date <= e.end_date
  group by
    c.condition_occurrence_id,
    c.person_id,
    c.condition_concept_id,
    c.condition_start_date
)

select
  row_number() over (order by person_id) as condition_era_id,
  person_id,
  condition_concept_id,
  min(condition_start_date) as condition_era_start_date,
  era_end_date as condition_era_end_date,
  count(*) as condition_occurrence_count
from cteConditionEnds
group by person_id, condition_concept_id, era_end_date
