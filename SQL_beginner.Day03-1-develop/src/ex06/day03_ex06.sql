WITH pizzerias_first AS (SELECT menu.pizza_name AS pizza_name, pizzeria.name AS pizzeria_name, menu.price AS price,
					 pizzeria.id
					 FROM menu JOIN pizzeria ON menu.pizzeria_id = pizzeria.id
					)

SELECT piz_2.pizza_name, piz_2.pizzeria_name AS pizzeria_name_1, pizzerias_first.pizzeria_name AS pizzeria_name_2, piz_2.price
FROM(SELECT * FROM pizzerias_first) piz_2
JOIN pizzerias_first ON piz_2.price = pizzerias_first.price AND piz_2.pizza_name = pizzerias_first.pizza_name
AND piz_2.id>pizzerias_first.id
ORDER BY pizza_name;