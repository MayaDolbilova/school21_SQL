SELECT pizzeria_name
FROM
(SELECT pizzeria.name AS pizzeria_name
FROM pizzeria JOIN person_visits pv ON pizzeria.id = pv.pizzeria_id JOIN person ON pv.person_id = person.id
WHERE person.name = 'Andrey'
EXCEPT
SELECT pizzeria.name AS pizzeria_name
FROM person JOIN person_order po ON person.id = po.person_id JOIN menu ON po.menu_id = menu.id JOIN pizzeria ON menu.pizzeria_id = pizzeria.id
WHERE person.name = 'Andrey') exc
ORDER BY pizzeria_name