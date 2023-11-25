SELECT person2.name AS person_name1, person.name AS person_name2, person.address AS common_address
FROM person CROSS JOIN (SELECT person.id, person.name, person.age,person.gender, person.address FROM person) AS person2
WHERE person.address = person2.address AND person.name<>person2.name AND person.id < person2.id
ORDER BY person_name1, person_name2, common_address;