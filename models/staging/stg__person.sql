select
  row_number() over (order by p.id) as person_id,
  case Upper(p.gender)
    when 'M' then 8507
    when 'F' then 8532
  end as gender_concept_id,
  Year(p.birthdate) as year_of_birth,
  Month(p.birthdate) as month_of_birth,
  Day(p.birthdate) as day_of_birth,
  p.birthdate as birth_datetime,
  case Upper(p.race)
    when 'WHITE' then 8527
    when 'BLACK' then 8516
    when 'ASIAN' then 8515
    else 0
  end as race_concept_id,
  case
    when Upper(p.ethnicity) = 'HISPANIC' then 38003563
    when Upper(p.ethnicity) = 'NONHISPANIC' then 38003564
    else 0
  end as ethnicity_concept_id,
  NULL as location_id,
  NULL as provider_id,
  NULL as care_site_id,
  p.id as person_source_value,
  p.gender as gender_source_value,
  0 as gender_source_concept_id,
  p.race as race_source_value,
  0 as race_source_concept_id,
  p.ethnicity as ethnicity_source_value,
  0 as ethnicity_source_concept_id
from {{ ref('synthea_patients') }} as p
where p.gender is not null
