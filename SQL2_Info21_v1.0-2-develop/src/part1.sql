----- drop
drop type if exists stat cascade;
drop table if exists Peers cascade;
drop table if exists Tasks cascade;
drop table if exists Checks cascade;
drop table if exists P2P cascade;
drop table if exists Verter cascade;
drop table if exists Friends cascade;
drop table if exists Recommendations cascade;
drop table if exists TransferredPoints cascade;
drop table if exists XP cascade;
drop table if exists TimeTracking cascade;
drop procedure if exists export() cascade;
drop procedure if exists import() cascade;


---- PROCEDURES

CREATE OR REPLACE PROCEDURE import(IN p_table_name VARCHAR, IN p_file_path VARCHAR, IN p_delimiter CHAR)
AS $$
BEGIN
    EXECUTE FORMAT('COPY %I FROM %L WITH DELIMITER %L CSV HEADER', p_table_name, p_file_path, p_delimiter);
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE export(IN p_table_name VARCHAR, IN p_file_path VARCHAR, IN p_delimiter text)
AS $$
BEGIN
    EXECUTE FORMAT('COPY %I TO %L WITH DELIMITER %L CSV HEADER', p_table_name, p_file_path, p_delimiter);
END;
$$
LANGUAGE plpgsql;


----- 1

create table Peers
(
    Nickname varchar(15) primary key ,
    Birthday date not null
);

CALL import ('peers','/Users/gerrerav/Ebashu/Info/src/csv_files/peers.csv', ',');


-- -------- 2

create table Tasks
(
    Title varchar(30) primary key ,
    ParentTask varchar(30) ,
    MaxXP int not null,
    constraint fk_Tasks_ParentTask foreign key (ParentTask) references Tasks(Title)
);

CALL import ('tasks','/Users/gerrerav/Ebashu/Info/src/csv_files/tasks.csv', ',');

----- 3

create table Checks
(
    ID SERIAL primary key,
    Peer varchar(15),
    Task varchar(30),
    Date date not null default current_date,
    constraint fk_Checks_Peer foreign key (Peer) references Peers(Nickname),
    constraint fk_Checks_Task foreign key (Task) references Tasks(Title)
);
INSERT INTO checks
VALUES (1, 'gerrerav', 'C2_SimpleBash', '2021-10-02');
CALL import ('checks','/Users/gerrerav/Ebashu/Info/src/csv_files/checks.csv', ',');


----- ENUM

CREATE TYPE stat AS ENUM ('Start','Success','Failure');

----- 4


create table P2P
(
    ID SERIAL primary key,
    "Check" int not null,
    CheckingPeer varchar(15),
    state stat,
    time time not null,
    constraint fk_P2P_CheckingPeer foreign key (CheckingPeer) references Peers(Nickname),
    constraint fk_P2P_Check foreign key ("Check") references Checks(ID)
);
insert into P2P values (1, 1, 'ironbelg', 'Start', '09:30:15');
insert into P2P values (2, 1, 'ironbelg', 'Success', '10:00:15');


CALL import ('p2p','/Users/gerrerav/Ebashu/Info/src/csv_files/p2p.csv', ',');
----- 5

create table Verter
(
    ID SERIAL primary key ,
    "Check" int not null,
    state stat,
    time time not null,
    constraint fk_Verter_Check foreign key ("Check") references Checks(ID)
);
insert into Verter values (1, 1, 'Start', '10:15:00');
insert into Verter values (2, 1, 'Success', '10:30:00');

CALL import ('verter','/Users/gerrerav/Ebashu/Info/src/csv_files/verter.csv', ',');

----- 6

create table Friends
(
    ID SERIAL primary key ,
    Peer1 varchar(15),
    Peer2 varchar(15),
    constraint fk_Friends_Peer1 foreign key (Peer1) references Peers(Nickname),
    constraint fk_Friends_Peer2 foreign key (Peer2) references Peers(Nickname)
);
INSERT INTO Friends VALUES (1, 'rosamonj', 'ironbelg');
CALL import ('friends','/Users/gerrerav/Ebashu/Info/src/csv_files/friends.csv', ',');


----- 7

create table Recommendations
(
    ID SERIAL primary key ,
    Peer varchar(15),
    RecommendedPeer varchar(15),
    constraint fk_Recommendations_Peer foreign key (Peer) references Peers(Nickname),
    constraint fk_Recommendations_RecommendedPeer foreign key (RecommendedPeer) references Peers(Nickname)
);
INSERT INTO Recommendations VALUES (1,'rosamonj', 'ironbelg');
CALL import ('recommendations','/Users/gerrerav/Ebashu/Info/src/csv_files/recommendations.csv', ',');



----- 8

create table TransferredPoints
(
    ID SERIAL primary key ,
    CheckingPeer varchar(15),
    CheckedPeer varchar(15),
    PointsAmount int default 0,
    constraint fk_TransferredPoints_CheckingPeer foreign key (CheckingPeer) references Peers(Nickname),
    constraint fk_TransferredPoints_CheckedPeer foreign key (CheckedPeer) references Peers(Nickname)
);
CALL import ('transferredpoints','/Users/gerrerav/Ebashu/Info/src/csv_files/transferredpoints.csv', ',');
----- 9

create table XP
(
    ID SERIAL primary key,
    "Check" int not null,
    XPAmount int default 0,
    constraint fk_XP_Check foreign key ("Check") references Checks(ID)
);
insert into XP values (1, 1, 340);

CALL import ('xp','/Users/gerrerav/Ebashu/Info/src/csv_files/xp.csv', ',');
----- 10

create table TimeTracking
(
    ID SERIAL primary key ,
    Peer varchar(15),
    Date date not null default current_date,
    Time time not null default current_time,
    State int not null default 1,
    constraint fk_TimeTracking_Peer foreign key (Peer) references Peers(Nickname),
    constraint ch_state check ( State between 1 and 2)
);

insert into TimeTracking values (1, 'rosamonj', '2023-07-22', '10:50:00', 1);

CALL import ('timetracking','/Users/gerrerav/Ebashu/Info/src/csv_files/timetracking.csv', ',');



------- P3.T10
INSERT INTO checks VALUES (105,'ironbelg','CPP1_s21_matrix+','2024-01-25');
INSERT INTO p2p VALUES (209,105,'cringuer','Start','10:40:00');
INSERT INTO p2p VALUES (210,105,'cringuer','Failure','11:00:00');

INSERT INTO checks VALUES (106,'ironbelg','CPP1_s21_matrix+','2024-01-25');
INSERT INTO p2p VALUES (211,106,'cringuer','Start','10:40:00');
INSERT INTO p2p VALUES (212,106,'cringuer','Success','11:00:00');


------- P3.T13
INSERT INTO checks VALUES (107,'seakingc','CPP2_s21_containers','2024-01-25'),
                          (108, 'amazomuc','D04_LinuxMonitoring_v2.0', '2024-01-25'),
                          (109,'amazomuc','D04_LinuxMonitoring_v2.0', '2024-01-25');
INSERT INTO p2p VALUES (213, 107, 'rosamonj','Start','12:00:00'),
                       (214,107,'rosamonj','Success','12:30:00'),
                       (215,108,'seakingc','Start','13:00:00'),
                       (216,108,'seakingc','Failure','13:30:00'),
                       (217,109,'ironbelg','Start','15:00:00'),
                       (218,109,'ironbelg','Success','15:30:00');

INSERT INTO checks VALUES (110,'cringuer','C8_3DViewer_v1.0', '2024-01-25');
INSERT INTO p2p VALUES (219, 110, 'rosamonj','Start','16:00:00'),
                       (220,110,'rosamonj','Success','16:30:00');
INSERT INTO checks VALUES (111,'rosamonj','SQL2_Info21_v1.0', '2024-01-25');
INSERT INTO p2p VALUES (221, 111,'gerrerav','Start','17:00:00'),
                       (222,111,'gerrerav','Success','17:30:00');
INSERT INTO verter VALUES (127,106,'Start','13:00:00'),
                          (128,106,'Success','13:15:00'),
                          (129,107,'Start','13:30:00'),
                          (130,107,'Success','13:45:00'),
                          (131,110,'Start','17:00:00'),
                          (132,110,'Success','17:15:00');
INSERT INTO xp VALUES (98,106,290),(99,107,330),(100,109,350),(101,110,730),(102,111,500);