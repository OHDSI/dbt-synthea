select
  row_number() over (order by (select null)) as provider_id,
  provider_name as provider_name,
  cast(null as varchar(20)) as npi,
  cast(null as varchar(20)) as dea,
  38004446 as specialty_concept_id,
  cast(null as integer) as care_site_id,
  cast(null as integer) as year_of_birth,
  case upper(provider_gender)
    when 'M' then 8507
    when 'F' then 8532
  end as gender_concept_id,
  provider_id as provider_source_value,
  provider_specialty as specialty_source_value,
  38004446 as specialty_source_concept_id,
  provider_gender as gender_source_value,
  case upper(provider_gender)
    when 'M' then 8507
    when 'F' then 8532
  end as gender_source_concept_id
from {{ ref( 'stg_synthea__providers') }}
