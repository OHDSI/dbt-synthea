select
  *,
  row_number() over (order by patient) as visit_occurrence_id
from
  (
    select * from {{ ref('stg__ip_visits') }}
    union all
    select * from {{ ref('stg__er_visits') }}
    union all
    select * from {{ ref('stg__op_visits') }}
  ) as t1
