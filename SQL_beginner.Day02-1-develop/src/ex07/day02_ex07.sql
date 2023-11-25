SELECT pizzeria.name AS pizzeria_name
FROM pizzeria RIGHT JOIN person_visits pv ON  pizzeria.id = pv.pizzeria_id 
RIGHT JOIN menu ON pizzeria.id = menu.pizzeria_id
RIGHT JOIN person ON pv.person_id = person.id 
WHERE person.name = 'Dmitriy' AND pv.visit_date = '2022-01-08' AND menu.price<800; 
