INSERT INTO person_visits (id, person_id, pizzeria_id, visit_date)
VALUES ((SELECT MAX(id)+1 FROM person_visits), (SELECT person.id FROM person WHERE name ='Dmitriy'),
		(SELECT pizzeria.id FROM pizzeria WHERE pizzeria.name = 'Best Pizza'), '2022-01-08');
INSERT INTO person_order(id, person_id,menu_id,order_date)
VALUES ((SELECT MAX(id)+1 FROM person_order), (SELECT person.id FROM person WHERE name ='Dmitriy'), 16, '2022-01-08');

REFRESH MATERIALIZED VIEW mv_dmitriy_visits_and_eats;
SELECT * FROM mv_dmitriy_visits_and_eats;