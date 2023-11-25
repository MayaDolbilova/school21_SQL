--------- task 1

CREATE OR REPLACE FUNCTION func_get_transferredpoints()
RETURNS table (Peer1 varchar, Peer2 varchar, PointsAmount int)
AS $$
BEGIN
    RETURN QUERY
    SELECT tp.CheckingPeer, tp.CheckedPeer, coalesce(tp.PointsAmount - tp2.PointsAmount, tp.PointsAmount)
    FROM TransferredPoints tp
    LEFT JOIN TransferredPoints tp2
    ON tp.CheckingPeer = tp2.CheckedPeer AND tp.CheckedPeer = tp2.CheckingPeer;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM func_get_transferredpoints();

--------- task 2

CREATE OR REPLACE FUNCTION func_get_XP()
RETURNS table (Peer varchar, Task varchar, XP int)
AS $$
BEGIN
    RETURN QUERY
    SELECT Checks.Peer, Checks.Task, XP.XPAmount
    FROM XP JOIN Checks ON XP."Check" = Checks.ID;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM func_get_XP();

---------- task 3

CREATE OR REPLACE FUNCTION func_get_out(IN p_day DATE)
RETURNS SETOF VARCHAR
AS $$
BEGIN
    RETURN QUERY
    SELECT peer
    FROM(
    SELECT COUNT(peer) as count_peer, peer FROM timetracking GROUP BY peer, date HAVING date = p_day) a
    WHERE count_peer=2;
END;
$$ LANGUAGE plpgsql;

SELECT func_get_out('2023-08-12');

---------- task 4
CREATE OR REPLACE PROCEDURE Sum_of_transfpoints()
AS $$
BEGIN
    DROP MATERIALIZED VIEW IF EXISTS sof;
    CREATE MATERIALIZED VIEW sof AS
        SELECT checkingpeer, SUM(PointsAmount) as PointsChange
        FROM transferredpoints
        GROUP BY checkingpeer
        ORDER BY PointsChange DESC;
END;
$$
LANGUAGE plpgsql;

CALL Sum_of_transfpoints();
SELECT * from sof;
DROP MATERIALIZED VIEW sof;

---------- task 5
CREATE OR REPLACE PROCEDURE Sum_of_func_transfpoints()
AS $$
BEGIN
    DROP MATERIALIZED VIEW IF EXISTS SoFT;
    CREATE MATERIALIZED VIEW SoFT AS
        SELECT peer1, SUM(PointsAmount) as PointsChange
        FROM func_get_transferredpoints()
        GROUP BY peer1
        ORDER BY PointsChange DESC;
END;
$$
LANGUAGE plpgsql;

CALL Sum_of_func_transfpoints();
SELECT * from SoFt;
DROP MATERIALIZED VIEW SoFT;

---------- task 6
CREATE OR REPLACE PROCEDURE Most_Checkable()
AS $$
BEGIN
    DROP MATERIALIZED VIEW IF EXISTS count;
    CREATE MATERIALIZED VIEW count AS
        SELECT date,COUNT(task) as cnt
        FROM checks
        GROUP BY task, date
        ORDER BY cnt DESC;

    DROP MATERIALIZED VIEW IF EXISTS most_cheakab;
    CREATE MATERIALIZED VIEW most_cheakab AS
        SELECT count.date as day,checks.task, cnt
        FROM checks
        JOIN count ON checks.date = count.date
        GROUP BY count.date,checks.task,cnt
        ORDER BY cnt DESC;

END;
$$
LANGUAGE plpgsql;

CALL Most_Checkable();
SELECT * from most_cheakab;
DROP MATERIALIZED VIEW most_cheakab;
DROP MATERIALIZED VIEW count;

---------- task 7
CREATE OR REPLACE PROCEDURE Block_done(IN blockname VARCHAR)
AS $$
BEGIN
    DROP TABLE IF EXISTS Block_doned;
    CREATE TEMP TABLE Block_doned AS
        WITH xp_check AS (SELECT "Check" , xpamount
                          FROM xp
                          JOIN checks c on c.id = xp."Check")
        SELECT peer,date
        FROM checks
        LEFT JOIN xp_check on checks.id = xp_check."Check"
        WHERE
            CASE WHEN blockname = 'C' THEN task = 'C8_3DViewer_v1.0' and xpamount is NOT NULL
                 WHEN blockname = 'CPP' THEN task = 'CPP7_MLP' and xpamount is NOT NULL
                 WHEN blockname = 'D' THEN task = 'D06_CICD' and xpamount is NOT NULL
                 WHEN blockname = 'SQL' THEN task = 'SQL3_RetailAnalytics_v1.0' and xpamount is NOT NULL
            END
        ORDER BY date;
END;
$$
LANGUAGE plpgsql;

CALL Block_done('D');
SELECT * FROM Block_doned;

------------- task 8
CREATE OR REPLACE PROCEDURE Recommend()
AS $$
BEGIN
    CREATE TEMP TABLE Recommended_peers AS
    WITH FriendRecommendations AS (
       SELECT peers.nickname as peer, friends.peer2, recommendations.recommendedpeer as recommended_peer, recommendations.id
    FROM peers JOIN friends ON peers.nickname = friends.peer1 JOIN recommendations ON friends.peer2 = recommendations.peer
    WHERE  peers.nickname <> recommendations.recommendedpeer
    )
    SELECT peer, recommended_peer
    FROM (
        SELECT peer, recommended_peer, ROW_NUMBER() OVER (PARTITION BY peer ORDER BY COUNT(recommended_peer) DESC) AS place
        FROM FriendRecommendations
        GROUP BY peer, recommended_peer
    ) ranked_recommendations
    WHERE place = 1;
END;
$$
LANGUAGE plpgsql;

CALL Recommend();
SELECT * FROM Recommended_peers;
DROP TABLE IF EXISTS Recommended_peers;

---------task 9

CREATE OR REPLACE PROCEDURE Status_blocks(IN p_block_1 VARCHAR, IN p_block_2 VARCHAR)
AS $$
BEGIN
    DROP TABLE IF EXISTS  not_started;
    CREATE TEMP TABLE not_started AS (
        SELECT COUNT(nickname)
        FROM (SELECT peers.nickname
        FROM peers
        EXCEPT
        (
        SELECT DISTINCT peers.nickname
        FROM peers JOIN checks ON peers.nickname = checks.peer
        WHERE task LIKE p_block_1 || '%'
        UNION
        SELECT DISTINCT peers.nickname
        FROM peers JOIN checks ON peers.nickname = checks.peer
        WHERE task LIKE p_block_2 || '%')) d);

    DROP TABLE IF EXISTS final_table;
    CREATE TEMP TABLE final_table AS (
        WITH abc AS (SELECT COUNT(*) FROM ((
            SELECT peers.nickname
        FROM peers JOIN checks ON peers.nickname = checks.peer
        WHERE task lIKE p_block_1 || '%')
        INTERSECT
        (SELECT peers.nickname
         FROM peers JOIN checks ON peers.nickname = checks.peer
        WHERE task lIKE p_block_2 || '%'
         ))b)
        SELECT ROUND((SELECT COUNT(DISTINCT peers.nickname)
        FROM peers JOIN checks ON peers.nickname = checks.peer
        WHERE task lIKE p_block_1 || '%')/(SELECT COUNT(*) FROM peers)::NUMERIC,4) * 100 as startedBlock1,
        ROUND((SELECT COUNT(DISTINCT peers.nickname)
        FROM peers JOIN checks ON peers.nickname = checks.peer
        WHERE task lIKE p_block_2 || '%')/(SELECT COUNT(*) FROM peers)::NUMERIC,4) * 100 as startedBlock2,
        ROUND((SELECT count FROM abc)/ (SELECT COUNT(*) FROM peers)::NUMERIC,4) * 100 as StartedBothBlocks,
        ROUND((SELECT count FROM not_started)/(SELECT COUNT(*) FROM peers)::NUMERIC,4) * 100 AS
        DidntStartAnyBlock
        FROM peers
        LIMIT 1);
END;
$$
LANGUAGE plpgsql;

CALL Status_blocks('SQL','D');
SELECT * FROM final_table;

--------task 10

CREATE OR REPLACE PROCEDURE birthdayChecks()
AS $$
BEGIN
    DROP TABLE IF EXISTS birthdays_checks;
    CREATE TEMP TABLE birthdays_checks AS (
        WITH all_birthdays AS (SELECT COUNT(peers.nickname)
        FROM peers JOIN checks ON peers.nickname = checks.peer
        WHERE EXTRACT(MONTH FROM peers.birthday) = EXTRACT(MONTH FROM checks.date)
          AND EXTRACT(DAY FROM peers.birthday) = EXTRACT(DAY FROM checks.date))
        SELECT (SELECT COUNT(peers.nickname)
        FROM peers JOIN checks ON peers.nickname = checks.peer JOIN p2p ON checks.id = p2p."Check"
        WHERE EXTRACT(MONTH FROM peers.birthday) = EXTRACT(MONTH FROM checks.date)
          AND EXTRACT(DAY FROM peers.birthday) = EXTRACT(DAY FROM checks.date) AND p2p.state = 'Success')/(SELECT all_birthdays.count FROM all_birthdays)::numeric * 100 AS SuccessfulChecks,
        (SELECT COUNT(peers.nickname)
        FROM peers JOIN checks ON peers.nickname = checks.peer JOIN p2p ON checks.id = p2p."Check"
        WHERE EXTRACT(MONTH FROM peers.birthday) = EXTRACT(MONTH FROM checks.date)
          AND EXTRACT(DAY FROM peers.birthday) = EXTRACT(DAY FROM checks.date) AND p2p.state = 'Failure')/(SELECT all_birthdays.count FROM all_birthdays)::numeric * 100 AS UnsuccessfulChecks);
END;
$$
LANGUAGE plpgsql;

CALL birthdayChecks();
SELECT * FROM birthdays_checks;
DROP TABLE IF EXISTS birthdays_checks;

------ task 11
CREATE OR REPLACE PROCEDURE passedTasks(IN p_task_1 VARCHAR, IN p_task_2 VARCHAR, IN p_task_3 VARCHAR)
AS $$
BEGIN
    DROP TABLE IF EXISTS projects_done;
    CREATE TEMP TABLE projects_done AS(
        (SELECT peers.nickname FROM peers JOIN checks ON peers.nickname = checks.peer JOIN tasks ON checks.task = tasks.title
        WHERE checks.id IN (SELECT xp."Check" FROM xp) AND tasks.title = p_task_1
        INTERSECT
        SELECT peers.nickname FROM peers JOIN checks ON peers.nickname = checks.peer JOIN tasks ON checks.task = tasks.title
        WHERE checks.id IN (SELECT xp."Check" FROM xp) AND tasks.title = p_task_2)
        EXCEPT
        SELECT peers.nickname FROM peers JOIN checks ON peers.nickname = checks.peer JOIN tasks ON checks.task = tasks.title
        WHERE checks.id IN (SELECT xp."Check" FROM xp) AND tasks.title = p_task_3);
END;
$$
LANGUAGE plpgsql;

CALL passedTasks('CPP1_s21_matrix+', 'SQL1_SQL1', 'D02_LinuxNetwork');
SELECT * FROM projects_done;
DROP TABLE IF EXISTS projects_done;

------ task 12
CREATE OR REPLACE PROCEDURE recursiveTasks()
AS $$
BEGIN
    DROP TABLE IF EXISTS recursive_tasks;
    CREATE TEMP TABLE recursive_tasks AS (
        WITH RECURSIVE count_parent_tasks AS (
            SELECT title, 0 AS PrevCount
            FROM tasks
            WHERE parenttask IS NULL
            UNION
            SELECT tasks.title, count_parent_tasks.PrevCount+1
            FROM tasks
            JOIN count_parent_tasks ON tasks.parenttask = count_parent_tasks.title)
        SELECT title, PrevCount
        FROM count_parent_tasks);
END;
$$
LANGUAGE plpgsql;

CALL recursiveTasks();
SELECT * FROM recursive_tasks;
DROP TABLE IF EXISTS recursive_tasks;

-------- task 13

CREATE OR REPLACE PROCEDURE successfulDays(IN p_number_of_days INT)
AS
$$
BEGIN
    DROP TABLE IF EXISTS help;
    CREATE TEMP TABLE help AS (
        SELECT
          xp.xpamount,
          checks.id,
          checks.date,
          p2p.state,
          CASE
            WHEN p2p.state= LAG(p2p.state) OVER (PARTITION BY  checks.date ORDER BY checks.id) THEN 'Подряд'
            ELSE 'Прерывание'
          END AS status
        FROM checks JOIN p2p ON checks.id = p2p."Check" LEFT JOIN xp ON checks.id = xp."Check" JOIN tasks ON checks.task = tasks.title
        WHERE p2p.state <> 'Start' );

    DROP TABLE IF EXISTS fin_successful_days;
    CREATE TEMP TABLE fin_successful_days AS (
        WITH RECURSIVE help_me AS (
          SELECT help.id, help.date, CASE WHEN status = 'Подряд' AND (xpamount > tasks.maxxp * 0.8) THEN 1 ELSE 0 END + 1 AS fin_count
          FROM help JOIN checks ON help.id = checks.id JOIN tasks ON checks.task = tasks.title
          WHERE help.id = 1
          UNION ALL
          SELECT h.id, h.date,
                 CASE WHEN h.status = 'Подряд' AND (xpamount > tasks.maxxp * 0.8)  THEN hm.fin_count + 1 ELSE 1 END AS fin_count
          FROM help h JOIN checks ON h.id = checks.id JOIN tasks ON checks.task = tasks.title
          JOIN help_me hm ON h.id = hm.id + 1)
        SELECT date FROM help_me
        GROUP BY help_me.date
        HAVING MAX(fin_count) = p_number_of_days
        ORDER BY date);
END;
$$
LANGUAGE plpgsql;

CALL SuccessfulDays(3);
SELECT * FROM fin_successful_days;

------ task 14
CREATE OR REPLACE PROCEDURE XpLead()
AS $$
BEGIN
    DROP TABLE IF EXISTS XpLead;
    CREATE TEMP TABLE XpLead AS
        SELECT nickname,SUM(xpamount) as xp
        FROM xp
        JOIN checks c on c.id = xp."Check"
        JOIN peers p on c.peer = p.nickname
        GROUP BY nickname
        ORDER BY xp DESC
        LIMIT 1;
END;
    $$
LANGUAGE plpgsql;

CALL XpLead();
SELECT * FROM XpLead;

------ task 15
CREATE OR REPLACE PROCEDURE Check_enter(IN entry_time time, IN min_limit int)
AS $$
BEGIN
    DROP TABLE IF EXISTS Entry;
    CREATE TEMP TABLE Entry AS
        WITH eq_time AS(
            SELECT peer, time
            FROM timetracking
            WHERE time < entry_time and state = 1)
        SELECT peer
        FROM eq_time
        GROUP BY peer
        HAVING count(peer) >= min_limit;
END;
    $$
LANGUAGE plpgsql;

CALL check_enter('13:00:00', 2);
SELECT * FROM Entry;

------ task 16
CREATE OR REPLACE PROCEDURE Check_exit(IN days_diff int, IN min_limit int)
AS $$
BEGIN
    DROP TABLE IF EXISTS Outry;
    CREATE TEMP TABLE Outry AS
        WITH eq_time AS(
            SELECT peer, date
            FROM timetracking
            WHERE date > current_date - days_diff and state = 2)
        SELECT peer
        FROM eq_time
        GROUP BY peer
        HAVING count(peer) >= min_limit;
END;
    $$
LANGUAGE plpgsql;

CALL check_exit(200,2);
SELECT * FROM Outry;

------ task 17
CREATE OR REPLACE PROCEDURE Early_entry()
AS $$
BEGIN
    DROP TABLE IF EXISTS Res;
    CREATE TEMP TABLE Res
    (id SERIAL PRIMARY KEY,
     Month varchar(15));
    INSERT INTO RES(Month) values ('January'),('February'),('March'),('April'),('May'),('June'),('July'),('August'),('September'),('October'),('November'),('December');

    DROP TABLE IF EXISTS E_Entries;
    CREATE TEMP TABLE E_Entries AS
        WITH general_count_entry AS
            (SELECT peer,COUNT(id) as entry, EXTRACT(MONTH FROM p.birthday) as bd
            FROM timetracking
            JOIN peers p ON timetracking.peer = p.nickname
            WHERE state = 1 AND EXTRACT(MONTH FROM birthday) = EXTRACT(MONTH FROM date)
            GROUP BY peer,bd),
        early_count_entry AS
            (SELECT p.nickname, COUNT(id) as early_entry,g.entry,EXTRACT(MONTH FROM birthday) as bd
             FROM timetracking
             JOIN peers p ON timetracking.peer = p.nickname
             JOIN general_count_entry g ON timetracking.peer = g.peer
             WHERE state = 1 AND EXTRACT(MONTH FROM birthday) = EXTRACT(MONTH FROM date) AND time < '12:00:00'
             GROUP BY p.nickname,bd,g.entry)

        SELECT MONTH,ROUND((CAST(early_count_entry.early_entry AS NUMERIC)/general_count_entry.entry*100),2) AS EarlyEntries
        FROM Res
        LEFT JOIN early_count_entry on Res.id = early_count_entry.bd
        LEFT JOIN general_count_entry on Res.id = general_count_entry.bd;
END;
$$
LANGUAGE plpgsql;

CALL Early_entry();
SELECT * FROM E_Entries;