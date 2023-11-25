SELECT pizza_name, pizzeria.name AS pizzeria_name, price
FROM menu RIGHT JOIN pizzeria ON menu.pizzeria_id = pizzeria.id
WHERE pizza_name = 'mushroom pizza' OR pizza_name = 'pepperoni pizza'
ORDER BY pizza_name, pizzeria_name;