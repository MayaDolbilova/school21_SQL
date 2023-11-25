SELECT name
FROM person JOIN person_order po ON person.id = po.person_id JOIN menu ON po.menu_id = menu.id
WHERE person.gender = 'male' AND (person.address = 'Moscow' OR person.address = 'Samara')
AND (menu.pizza_name = 'pepperoni pizza' OR menu.pizza_name = 'mushroom pizza')
ORDER BY name DESC;