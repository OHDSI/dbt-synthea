select
  *,
  row_number() over (order by patient_id) as visit_occurrence_id
from
  (
    select * from {{ ref('int__ip_visits') }}
    union all
    select * from {{ ref('int__er_visits') }}
    union all
    select * from {{ ref('int__op_visits') }}
  ) as t1
