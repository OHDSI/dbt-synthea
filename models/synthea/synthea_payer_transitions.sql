select *
from {{ source('synthea', 'payer_transitions') }}
