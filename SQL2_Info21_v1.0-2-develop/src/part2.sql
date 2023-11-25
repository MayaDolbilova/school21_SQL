----- 1
CREATE OR REPLACE PROCEDURE add_p2p (IN p_name_checked VARCHAR(15), IN p_name_checking VARCHAR(15), IN p_task VARCHAR(30), IN p_status stat, IN p_time TIME)
AS $$
BEGIN
    IF p_status = 'Start' THEN
        INSERT INTO Checks VALUES ((SELECT MAX(id)+1 FROM Checks), p_name_checked, p_task);
        INSERT INTO P2P VALUES ((SELECT MAX(id)+1 FROM P2P), (SELECT MAX(id) FROM Checks), p_name_checking, p_status, p_time);
    ELSE
        INSERT INTO P2P VALUES ((SELECT MAX(id)+1 FROM P2P), (SELECT "Check" FROM P2P GROUP BY "Check", CheckingPeer HAVING COUNT("Check") = 1 AND CheckingPeer = p_name_checking),
        (SELECT CheckingPeer FROM P2P GROUP BY "Check", CheckingPeer HAVING COUNT("Check") = 1 AND CheckingPeer = p_name_checking), p_status, p_time);

    END IF;
END;
$$
LANGUAGE plpgsql;

CALL add_p2p('seakingc','cringuer','CPP1_s21_matrix+','Start','11:00:00');
CALL add_p2p('seakingc','cringuer','CPP1_s21_matrix+','Success','11:30:00');
CALL add_p2p('ironbelg','rosamonj', 'SQL2_Info21_v1.0','Start','13:00:00');
CALL add_p2p('ironbelg','rosamonj', 'SQL2_Info21_v1.0','Success','13:30:00');
CALL add_p2p('ironbelg','seakingc','SQL3_RetailAnalytics_v1.0', 'Start', '14:40:00');
CALL add_p2p('ironbelg','seakingc','SQL3_RetailAnalytics_v1.0', 'Success', '15:00:00');

----- 2
CREATE OR REPLACE PROCEDURE verter_check(IN p_NickNameChecked VARCHAR, IN p_TaskName VARCHAR, IN p_State_Check stat, IN p_Time_Check time)
AS $$
BEGIN
    IF (
        SELECT id
        FROM p2p
        WHERE "Check" = (SELECT MAX(id)
            FROM checks
            WHERE peer = p_NickNameChecked and task = p_TaskName)
          and time = (SELECT MAX(time) FROM p2p WHERE "Check" = (SELECT MAX(id)
            FROM checks
            WHERE peer = p_NickNameChecked and task = p_TaskName))
          and state = 'Success') IS NOT NULL
        THEN
            INSERT INTO verter VALUES ((Select MAX(id)+1 FROM verter),(SELECT MAX(id)
        FROM checks
        WHERE peer = p_NickNameChecked and task = p_TaskName),p_State_Check,p_Time_Check);
    END IF;
END;
$$
LANGUAGE plpgsql;

CALL verter_check('seakingc', 'CPP1_s21_matrix+','Start','11:45:00');
CALL verter_check('seakingc', 'CPP1_s21_matrix+','Failure','12:00:00');

----- 3
CREATE OR REPLACE FUNCTION  fnc_update_transferredpoints()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE TransferredPoints SET PointsAmount = PointsAmount+1
    WHERE NEW.CheckingPeer = TransferredPoints.CheckingPeer AND ((SELECT Peer FROM Checks WHERE NEW."Check" = Checks.ID) = TransferredPoints.CheckedPeer);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_p2p_update_transferredpoints
AFTER INSERT ON P2P
FOR EACH ROW
WHEN (NEW.state = 'Start')
EXECUTE FUNCTION fnc_update_transferredpoints();

----- 4
CREATE OR REPLACE FUNCTION fnc_checking_xp()
RETURNS TRIGGER AS $$
    BEGIN
        IF New."Check" = ( SELECT DISTINCT p2p."Check"
                        FROM p2p
                        WHERE p2p.state = 'Success' and p2p."Check" = ( SELECT DISTINCT p2p."Check"
                                            FROM p2p
                                            LEFT JOIN verter v2 ON p2p."Check" = v2."Check"
                                            WHERE New."Check" = p2p."Check" AND p2p.state = 'Success' AND (v2.state = 'Success' OR v2.state IS NULL)))
            THEN IF New.xpamount <= (SELECT maxxp
                               FROM tasks
                               JOIN checks c ON tasks.title = c.task
                               WHERE c.id = New."Check")
                THEN RETURN new;
                ELSE RETURN NULL;
                END IF;
            ELSE RETURN NULL;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_add_xp_check
    BEFORE INSERT OR UPDATE ON xp
    FOR EACH ROW
    EXECUTE FUNCTION fnc_checking_xp();

INSERT INTO xp VALUES (96,102,290);
INSERT INTO xp VALUES (96,103,400);
INSERT INTO xp VALUES (97,104,500);