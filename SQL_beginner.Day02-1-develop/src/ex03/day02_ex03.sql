WITH TABLE_DATES(missing_date)
AS (SELECT generate_series('2022-01-01'::date, '2022-01-10'::date, '1 day'::interval))
SELECT missing_date::date
FROM (SELECT * FROM person_visits WHERE person_id in (1,2)) as pv
RIGHT JOIN TABLE_DATES
ON pv.visit_date = missing_date
WHERE pv.id IS NULL
ORDER BY missing_date;