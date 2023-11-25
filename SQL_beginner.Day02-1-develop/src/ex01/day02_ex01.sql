SELECT generated::date AS missing_date
FROM (SELECT * FROM person_visits WHERE person_id in (1,2)) as pv
RIGHT JOIN generate_series('2022-01-01'::date, '2022-01-10'::date, '1 day'::interval) AS generated
ON pv.visit_date = generated
WHERE pv.id IS NULL
ORDER BY missing_date;