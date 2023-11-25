SELECT f.name AS name
FROM v_persons_female f
UNION ALL
SELECT m.name AS name
FROM v_persons_male m
ORDER BY name;