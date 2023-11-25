SELECT coalesce(person.name, '-') AS person_name, pv.visit_date AS visit_date,
coalesce(pz.name, '-') AS pizzeria_name
FROM person 
FULL JOIN (SELECT * FROM person_visits WHERE visit_date BETWEEN '2022-01-01' AND '2022-01-03') as pv
ON person.id = pv.person_id
FULL JOIN (SELECT * FROM pizzeria) as pz
ON pv.pizzeria_id = pz.id
ORDER BY person_name, visit_date, pizzeria_name;