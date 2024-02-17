select *
from {{ source('synthea', 'supplies') }}
