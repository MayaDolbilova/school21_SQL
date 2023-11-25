CREATE VIEW RS AS
( SELECT person_id FROM person_visits
 WHERE visit_date = '2022-01-02'
 EXCEPT
 SELECT person_id FROM person_visits
 WHERE visit_date = '2022-01-06'
);
CREATE VIEW SR AS
(SELECT person_id FROM person_visits
 WHERE visit_date = '2022-01-06'
 EXCEPT
 SELECT person_id FROM person_visits
 WHERE visit_date = '2022-01-02'
);

CREATE VIEW v_symmetric_union AS
(SELECT person_id FROM RS
 UNION
 SELECT person_id FROM SR
 ORDER BY person_id
);