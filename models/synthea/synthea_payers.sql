select *
from {{ source('synthea', 'payers') }}
