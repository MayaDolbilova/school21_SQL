SELECT person.id AS person_id, person.name, age, gender, address, pizzeria.id AS pizzeria_id, pizzeria.name, rating
FROM pizzeria, person
ORDER BY person_id, pizzeria_id;
