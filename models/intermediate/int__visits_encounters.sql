SELECT *
FROM {{ ref('int__ip_visits') }}

UNION ALL

SELECT *
FROM {{ ref('int__er_visits') }}

UNION ALL

SELECT *
FROM {{ ref('int__op_visits') }}
