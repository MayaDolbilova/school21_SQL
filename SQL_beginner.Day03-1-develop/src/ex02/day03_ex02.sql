SELECT menu.pizza_name AS pizza_name, menu.price AS price, pizzeria.name AS pizzeria_name
FROM menu JOIN pizzeria ON menu.pizzeria_id = pizzeria.id
WHERE menu.id NOT IN (SELECT po.menu_id FROM person_order po)
ORDER BY pizza_name, price;