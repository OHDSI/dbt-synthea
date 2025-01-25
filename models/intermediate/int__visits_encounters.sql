/*
for IP visits, we rolled up many encounters into a single visit and assigned it an encounter_id. the original IDs of the rolled-up encounters are stored in the original_encounter_id column. for OP/ER visits, the encounter_id is the same as the original encounter_id as no roll-up occurred. in this model we assign an integer ID based on the rolled-up encounter_id, to use as the visit_occurrence_id.
*/

SELECT *
FROM {{ ref('int__ip_visits') }}

UNION ALL

SELECT *
FROM {{ ref('int__er_visits') }}

UNION ALL

SELECT *
FROM {{ ref('int__op_visits') }}
