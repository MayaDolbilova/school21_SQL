WITH all_visits AS (SELECT person.gender AS gender, pizzeria.name AS pizzeria_name 
				   FROM person_order po JOIN person ON po.person_id = person.id JOIN menu ON po.menu_id = menu.id 
				   JOIN pizzeria ON menu.pizzeria_id = pizzeria.id),
women AS (SELECT * FROM all_visits av WHERE av.gender = 'female'),
man AS (SELECT * FROM all_visits av WHERE av.gender = 'male'),
only_women AS (SELECT pizzeria_name FROM women
			  EXCEPT
			  SELECT pizzeria_name FROM man),
only_man AS (SELECT pizzeria_name FROM man
			EXCEPT 
			SELECT pizzeria_name FROM women)
SELECT pizzeria_name
FROM only_women
UNION
SELECT pizzeria_name
FROM only_man
ORDER BY 1;