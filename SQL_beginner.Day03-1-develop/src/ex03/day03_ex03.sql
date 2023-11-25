WITH women_count AS (SELECT pizzeria.name AS p_name, COUNT(*) AS visit_count_w
FROM person_visits pv
JOIN person ON pv.person_id = person.id
JOIN pizzeria  ON pv.pizzeria_id = pizzeria.id
WHERE gender = 'female'
GROUP BY pizzeria.name),
man_count AS (
SELECT pizzeria.name AS p_name, COUNT(*) AS visit_count_m
FROM person_visits pv
JOIN person ON pv.person_id = person.id
JOIN pizzeria  ON pv.pizzeria_id = pizzeria.id
WHERE gender = 'male'
GROUP BY pizzeria.name
)
SELECT man_count.p_name AS pizzeria_name
FROM man_count JOIN women_count ON man_count.p_name = women_count.p_name
WHERE visit_count_m <> visit_count_w
ORDER BY pizzeria_name;