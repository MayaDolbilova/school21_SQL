--- reacting on checks update
--- we don't need it
CREATE OR REPLACE FUNCTION insert_all()
RETURNS TRIGGER AS $$
    DECLARE
    calculated_time time;
    statuss stat;
    BEGIN
    IF (SELECT last_value(p2p.time) over (order by id DESC) last_time FROM p2p LIMIT 1 ) > '23:00:00' THEN
    calculated_time := '08:00:00';
    ELSE
    calculated_time := (SELECT last_value(p2p.time) over (order by id DESC) last_time FROM p2p LIMIT 1) ;
    END IF;
    IF(SELECT MAX("Check") FROM p2p) IN (1,7,21,25,33,97) THEN
    statuss := 'Failure';
    ELSE
    statuss := 'Success';
    end if;
    WITH rnd_nick AS ((SELECT nickname FROM(SELECT nickname FROM peers EXCEPT SELECT nickname FROM peers WHERE nickname = NEW.peer) as rnd_name ORDER BY random() LIMIT 1))
       INSERT INTO p2p VALUES((SELECT MAX(ID)+1 FROM p2p),NEW.id,(SELECT nickname FROM rnd_nick),'Start',
                              (calculated_time+'00:15:00')),
                             ((SELECT MAX(ID)+2 FROM p2p),NEW.id,(SELECT nickname FROM rnd_nick),statuss,(calculated_time + '00:30:00'));
    RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER inserting_all_checks
    AFTER INSERT OR UPDATE ON checks
    FOR EACH ROW
    EXECUTE FUNCTION insert_all();

---- adding to verter after insert on p2p
CREATE OR REPLACE FUNCTION fnc_insert_verter()
RETURNS TRIGGER AS $$
    BEGIN
    IF NEW."Check" NOT IN (SELECT checks.id FROM checks WHERE checks.task LIKE '%D0%' OR checks.task LIKE '%SQL%') THEN
    INSERT INTO verter VALUES ((SELECT MAX(id)+1 FROM verter), NEW."Check", 'Start', NEW.time + '00:05:13'),
                              ((SELECT MAX(id)+2 FROM verter), NEW."Check", 'Success', NEW.time + '00:20:00' );
    ELSE
    INSERT INTO XP VALUES ((SELECT MAX(id)+1 FROM XP), NEW."Check", (SELECT maxxp - (floor(random() * 51)::int) FROM tasks JOIN checks ON tasks.Title = checks.Task WHERE NEW."Check" = checks.id));
    END IF;
    RETURN NULL;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_verter
    AFTER INSERT ON p2p
    FOR EACH ROW
    WHEN (NEW.state = 'Success')
    EXECUTE FUNCTION fnc_insert_verter();

----
CREATE OR REPLACE FUNCTION fnc_insert_xp()
RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO XP VALUES ((SELECT MAX(id)+1 FROM XP), NEW."Check", (SELECT maxxp - (floor(random() * 51)::int) FROM tasks JOIN checks ON tasks.Title = checks.Task WHERE NEW."Check" = checks.id));
    RETURN NULL;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_xp
    AFTER INSERT ON verter
    FOR EACH ROW
    WHEN (NEW.state = 'Success')
    EXECUTE FUNCTION fnc_insert_xp();

CREATE OR REPLACE FUNCTION fnc_insert_transf_points()
RETURNS TRIGGER AS $$
    BEGIN
         IF EXISTS(SELECT checkingpeer, checkedpeer FROM TransferredPoints WHERE checkingpeer=NEW.checkingpeer
                                                                      AND checkedpeer IN (SELECT checks.peer FROM checks JOIN p2p ON checks.id = p2p."Check" WHERE NEW."Check"=checks.id)) THEN
             UPDATE TransferredPoints
             SET pointsamount = pointsamount+1
             WHERE checkingpeer = NEW.checkingpeer AND checkedpeer IN (SELECT checks.peer FROM checks JOIN p2p ON checks.id = p2p."Check" WHERE NEW."Check"=checks.id);
         ELSE
             INSERT INTO TransferredPoints VALUES((SELECT MAX(id)+1 FROM TransferredPoints), NEW.checkingpeer, (SELECT checks.peer FROM checks JOIN p2p ON checks.id = p2p."Check" WHERE NEW."Check"=checks.id LIMIT 1), 1);
         END IF;
         RETURN NULL;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_transf_points
    AFTER INSERT ON p2p
    FOR EACH ROW
    WHEN (NEW.state = 'Start')
    EXECUTE FUNCTION fnc_insert_transf_points();

--CREATE TEMP TABLE temp_export AS SELECT * FROM transferredpoints ORDER BY id;
--CALL export('p2p','/Users/rosamonj/Desktop/fin/p2p.csv', ',');
-- export('verter','/Users/rosamonj/Desktop/fin/verter.csv', ',');
--CALL export('xp','/Users/rosamonj/Desktop/fin/xp.csv', ',');
--CALL export('temp_export','/Users/rosamonj/Desktop/fin/transferredpoints.csv', ',');
--CALL export('checks','/Users/rosamonj/Desktop/fin/checks.csv', ',');
--DROP TABLE temp_export;