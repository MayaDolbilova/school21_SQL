SELECT menu.pizza_name AS pizza_name, menu.price AS price, pizzeria.name AS pizzeria_name, pv.visit_date AS visit_date
FROM person JOIN person_visits pv ON person.id = pv.person_id JOIN pizzeria ON pv.pizzeria_id = pizzeria.id 
JOIN menu ON pizzeria.id = menu.pizzeria_id
WHERE person.name = 'Kate' AND menu.price BETWEEN 800 and 1000
ORDER BY pizza_name, price, pizzeria_name;