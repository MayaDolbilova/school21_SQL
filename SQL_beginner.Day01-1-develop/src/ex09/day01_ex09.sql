SELECT name
FROM pizzeria
WHERE pizzeria.id NOT IN (SELECT pizzeria_id FROM person_visits);

SELECT name
FROM pizzeria
WHERE NOT EXISTS (SELECT pizzeria_id from person_visits where pizzeria_id = pizzeria.id);
