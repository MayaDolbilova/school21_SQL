SELECT name AS object_name
FROM (SELECT * FROM person ORDER BY name) AS a
union all
SELECT pizza_name AS object_name
FROM (SELECT * FROM menu ORDER BY pizza_name) AS b;