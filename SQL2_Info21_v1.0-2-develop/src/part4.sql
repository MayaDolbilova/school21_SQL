------- task 1 -------
CREATE OR REPLACE PROCEDURE drop_tables_with_prefix(IN prefix_name VARCHAR)
    LANGUAGE plpgsql
AS
$$
DECLARE
    tbl TEXT;
BEGIN
    FOR tbl IN
        SELECT tablename
        FROM pg_tables
        WHERE tableowner != 'postgres'
          AND tablename LIKE prefix_name || '%'
        LOOP
            EXECUTE 'DROP TABLE IF EXISTS ' || tbl || ' CASCADE';
        END LOOP;
END;
$$;

CALL drop_tables_with_prefix('tablename');

-- CREATE TABLE TableName_1 (
--     id BIGINT NOT NULL,
--     name VARCHAR,
--     age INT,
--     gender VARCHAR,
--     address VARCHAR
-- );
-- CREATE TABLE TableName_2 (
--     id BIGINT NOT NULL,
--     name VARCHAR,
--     age INT,
--     gender VARCHAR,
--     address VARCHAR
-- );


------- task 2 -------
CREATE OR REPLACE PROCEDURE show_amount_of_functions_and_args(output OUT INT)
AS $$
DECLARE
    func_args_name RECORD;
BEGIN
    output := 0;
    FOR func_args_name IN
    SELECT routine_name,pg_catalog.pg_get_function_identity_arguments(pg_proc.oid) AS args
    FROM information_schema.routines r  JOIN
    pg_proc ON r.routine_name = pg_proc.proname
    WHERE specific_schema = 'public'
    AND routine_type = 'FUNCTION'
    AND data_type IS NOT NULL AND routine_name NOT IN (
    SELECT proname from pg_proc where prokind='f' and pronamespace = 'public'::regnamespace and (pg_get_function_identity_arguments(pg_proc.oid) = ''))
    LOOP
        RAISE INFO 'name: %, type: %', quote_ident(func_args_name.routine_name), quote_ident(func_args_name.args);
        output := output + 1;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CALL show_amount_of_functions_and_args(0);

-- CREATE OR REPLACE FUNCTION test_task2_1(integer, integer) RETURNS INTEGER
--     AS 'select $1 + $2;'
--     LANGUAGE SQL
--     IMMUTABLE
--     RETURNS NULL ON NULL INPUT;
--
-- CREATE OR REPLACE FUNCTION test_task2_2(input_text VARCHAR) RETURNS INTEGER
--     AS 'SELECT LENGTH($1);'
--     LANGUAGE SQL
--     IMMUTABLE
--     RETURNS NULL ON NULL INPUT;


------- task 3 -------
CREATE OR REPLACE PROCEDURE destroy_DML_triggers(OUT num INT)
    LANGUAGE plpgsql
AS
$$
DECLARE
    trigger_info RECORD;
BEGIN
    num := 0;
    FOR trigger_info IN
        SELECT *
        FROM information_schema.triggers
        WHERE event_manipulation IN ('DELETE', 'UPDATE', 'INSERT')
        LOOP
            EXECUTE 'DROP TRIGGER IF EXISTS ' || trigger_info.trigger_name || ' ON ' || trigger_info.event_object_table ||
                    ' CASCADE';
            num := num + 1;
        END LOOP;
end;
$$;

CALL destroy_DML_triggers(num := 0);

-- SELECT *
-- FROM information_schema.triggers;


------- task 4 -------
CREATE OR REPLACE PROCEDURE show_procedures_which_include(
  input IN VARCHAR
)
AS $$
DECLARE
    procedure_and_type RECORD;
BEGIN
    FOR  procedure_and_type IN
        SELECT DISTINCT r.routine_name, r.routine_type
        FROM information_schema.routines r
        WHERE
        routine_schema = 'public'
        AND routine_definition like '%' || input || '%'
     LOOP
      RAISE INFO 'name: %, type: %', quote_ident(procedure_and_type.routine_name), quote_ident(procedure_and_type.routine_type);
    END LOOP;
END;
$$
LANGUAGE plpgsql;
CALL show_procedures_which_include('LENGTH');