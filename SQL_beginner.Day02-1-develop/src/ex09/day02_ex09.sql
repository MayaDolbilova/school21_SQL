SELECT person.name
FROM person JOIN person_order po ON person.id = po.person_id JOIN menu ON po.menu_id = menu.id
WHERE person.gender = 'female' AND menu.pizza_name = 'pepperoni pizza' 
AND person.name IN (SELECT person.name 
					FROM person JOIN person_order po ON person.id = po.person_id JOIN menu ON po.menu_id = menu.id
				   	WHERE person.gender = 'female' AND menu.pizza_name = 'cheese pizza'
				   ) 
ORDER BY name;