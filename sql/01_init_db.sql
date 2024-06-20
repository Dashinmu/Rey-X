/* Первоначальные настройки OracleDB */

    /* Создание табличного пространства */
    CREATE TABLESPACE diplom_tablespace
    DATAFILE 'diplom_tablespace.dat' 
    SIZE 10M
    REUSE
    AUTOEXTEND ON NEXT 10M MAXSIZE 2000M
    ;

    /* Создание временного табличного пространства */
    CREATE TEMPORARY TABLESPACE diplom_tablespace_temp
    TEMPFILE 'diplom_tablespace_temp.dbf'
    SIZE 10M
    AUTOEXTEND ON;

    /* Создание новой схемы */
    CREATE USER diplom
    IDENTIFIED BY pass4diplom
    DEFAULT TABLESPACE diplom_tablespace
    TEMPORARY TABLESPACE diplom_tablespace_temp
    QUOTA 2000M on diplom_tablespace;

    /* Выдать права на сессию */
    GRANT CREATE SESSION TO diplom;

    /* Выдать права на создание триггеров */
    GRANT CREATE ANY TRIGGER TO diplom;

    /* Выдать права на использование шифрования от Oracle */
    GRANT EXECUTE ON SYS.DBMS_CRYPTO TO diplom;

    /* Выдать права на подключение к схеме */
    ALTER USER diplom IDENTIFIED BY pass4diplom ACCOUNT UNLOCK;

/* Первоначальные настройки OracleDB */


/* ---------------------------------------------------- */


/* Блок с пользователями */

    /* Таблица "Пользователи" */

        /* Создать последовательность */
        CREATE SEQUENCE diplom.user_id_seq
        MINVALUE 1
        MAXVALUE 99999
        START WITH 1
        INCREMENT BY 1
        ;

        /* Удалить последовательность */
        /* DROP SEQUENCE DIPLOM.user_id_seq; */

        /* Создать таблицу */
        CREATE TABLE diplom.users
        (
            id NUMBER(5) not null
            , type NUMBER(2) not null
            , name VARCHAR2(50)
            , login VARCHAR2(20) not null
            , password VARCHAR2(200) not null
            , contact_info1 VARCHAR2(50) 
            , contact_info2 VARCHAR2(50) 
            , start_date DATE
            , end_date DATE
            , CONSTRAINT users_pk PRIMARY KEY (id, login)
            , CONSTRAINT user_uniq UNIQUE (login)
        );

        ALTER TABLE DIPLOM.USERS DROP CONSTRAINT user_uniq;
        ALTER TABLE DIPLOM.USERS MODIFY (CONSTRAINT user_uniq UNIQUE (login));

        /* Создать триггер */
        CREATE OR REPLACE TRIGGER diplom.user_id_trigger
        BEFORE INSERT ON diplom.users FOR EACH ROW            
        BEGIN
            :new.id := diplom.user_id_seq.nextval;
            if :new.start_date is null then :new.start_date := trunc(sysdate); end if;
            if :new.end_date is null then :new.end_date := to_date('01013872','ddmmyyyy'); end if;
            begin
                select id into :new.type from diplom.user_type where id = :new.type;
                exception when others then raise_application_error(-20001, 'Не существует тип пользователя с id = '||:new.type);
            end;
            :new.password := DIPLOM.FND_USER.GET_PASSWORD(P_PASSWORD  => :new.password);
            :new.login := upper(:new.login);
        END;

        CREATE OR REPLACE TRIGGER diplom.user_id_trigger_update
        BEFORE UPDATE ON DIPLOM.USERS FOR EACH ROW
        BEGIN
            if :new.login is not null and upper(:new.login) not like :old.login 
                then :new.login := upper(:new.login); 
                else :new.login := :old.login;
            end if;
            if :new.password is not null and :new.password not like ''
                then :new.password := DIPLOM.FND_USER.GET_PASSWORD(P_PASSWORD  => :new.password); 
                else :new.password := :old.password;
            end if;
            if :new.start_date < :old.start_date and :new.type not in (1, 2) then raise_application_error(-20001, 'Дата начала обучения не может быть указана меньше текущей'); 
                elsif :new.start_date is null then :new.start_date := :old.start_date;
            end if;
            if :new.end_date <= :new.start_date then raise_application_error(-20001, 'Дата окончания обучения не может быть меньше даты начала обучения'); 
                elsif :new.end_date is null then :new.end_date := :old.end_date;
            end if;
            if :new.name is null or :new.name like :old.name then :new.name := :old.name; end if;
        END;

        /* Удалить таблицу */
        /* DROP TABLE diplom.users */
    
    /* Таблица "Пользователи" */

    /* Таблица "Тип пользователя" */

        /* Создать последовательность */
        CREATE SEQUENCE diplom.user_type_seq
        MINVALUE 1
        MAXVALUE 99
        START WITH 1
        INCREMENT BY 1
        ;

        /* Удалить последовательность */
        /* DROP SEQUENCE diplom.user_type_seq; */

        /* Создать таблицу */
        CREATE TABLE diplom.user_type
        (
            id NUMBER(2) not null
            , meaning VARCHAR2(50) not null
            , start_date DATE not null
            , inactive_date DATE
            , CONSTRAINT user_type_pk PRIMARY KEY (id)
            , CONSTRAINT user_type_uniq UNIQUE (meaning, start_date, inactive_date)
        );

        /* Создать триггер */
        CREATE OR REPLACE TRIGGER diplom.user_type_trigger
        BEFORE INSERT ON diplom.user_type FOR EACH ROW
        BEGIN
            :new.id := diplom.user_type_seq.nextval;
            :new.start_date := trunc(sysdate);
            :new.inactive_date := to_date('01013872','ddmmyyyy');
        END;

        /* Удалить таблицу */
        /* DROP TABLE diplom.user_type; */
    
    /* Таблица "Тип пользователя" */

    /* Таблица "Связь пользователей" */

        /* Создать последовательность */
        CREATE SEQUENCE diplom.person_relations_seq
        MINVALUE 1
        MAXVALUE 99999
        START WITH 1
        INCREMENT BY 1
        ;

        /* Удалить последовательность */
        /* DROP SEQUENCE diplom.person_relations_seq; */

        /* Создать таблицу */
        CREATE TABLE diplom.person_relations
        (
            id NUMBER(5) not null
            , parent NUMBER(5) not null
            , child NUMBER(5) not null
            /* , type NUMBER(2) not null --Зачем? Используется только связь РОДИТЕЛЬ (Руководитель) и ДОЧЬ (Студент)*/
            , start_date DATE not null
            , end_date DATE
            , CONSTRAINT person_relations_pk PRIMARY KEY (id)
            , CONSTRAINT person_relations_uniq UNIQUE (parent, child, start_date, end_date)
        );

        /* Создать триггер */
        CREATE OR REPLACE TRIGGER diplom.person_relations_trigger
        BEFORE INSERT ON diplom.person_relations FOR EACH ROW
        BEGIN
            :new.id := diplom.person_relations_seq.nextval;
            /* if :new.start_date is null then :new.start_date := trunc(sysdate); */
            select
                START_DATE
                , END_DATE
            into
                :new.start_date
                , :new.end_date
            from
                DIPLOM.USERS
            where 1 = 1
                and id = :new.child
            ;
        END;

        /* Удалить таблицу */
        /* DROP TABLE diplom.person_relations; */

    /* Таблица "Связь пользователей" */

/* Блок с пользователями */


/* ----------------------------------------------------------------------- */


/* Блок заданий и этапов */
    
    /* ---- Таблица "Этапы" ---- */

        /* Создать последовательность */
        CREATE SEQUENCE diplom.stages_seq
        MINVALUE 1
        MAXVALUE 999
        START WITH 1
        INCREMENT BY 1
        ;

        /* Удалить последовательность */
        /* DROP SEQUENCE diplom.stages_seq; */

        /* Создать таблицу */
        CREATE TABLE diplom.stages
        (
            id NUMBER(3) not null
            , created_by NUMBER(5) not null
            , stage_name VARCHAR2(50) not null
            , meaning VARCHAR2(100) not null
            , creation_date DATE
            , inactive_date DATE
            , time_period NUMBER(2)
            , CONSTRAINT stages_pk PRIMARY KEY (id)
            , CONSTRAINT stages_uniq UNIQUE (created_by, stage_name, creation_date, inactive_date)
        );

        ALTER TABLE DIPLOM.stages DROP CONSTRAINT stages_uniq;
        ALTER TABLE DIPLOM.stages MODIFY (CONSTRAINT stages_uniq UNIQUE (created_by, stage_name, creation_date, inactive_date));

        /* Создать триггер */
        CREATE OR REPLACE TRIGGER diplom.stages_trigger
        BEFORE INSERT ON diplom.stages FOR EACH ROW
        BEGIN
            :new.id := diplom.stages_seq.nextval;
            :new.creation_date := trunc(sysdate);
            :new.inactive_date := to_date('01013872','ddmmyyyy');
            if :new.time_period is null then :new.time_period := -1; end if;
            if :new.stage_name is null then :new.stage_name := 'Stage #'||:new.id; end if;
        END;

        /* Удалить таблицу */
        /* DROP TABLE diplom.stages; */

    /* ---- Таблица "Этапы" ---- */

    /* ---- Таблица "Связь этапов" ---- */

        /* Создать последовательность */
        CREATE SEQUENCE diplom.stage_relations_seq
        MINVALUE 1
        MAXVALUE 999
        START WITH 1
        INCREMENT BY 1
        ;

        /* Удалить последовательность */
        /* DROP SEQUENCE diplom.stage_relations_seq; */

        /* Создать таблицу */
        CREATE TABLE diplom.stage_relations
        (
            id NUMBER(4) not null
            , parent NUMBER(3) not null
            , child NUMBER(3) not null
            , start_date DATE not null
            , end_date DATE
            , CONSTRAINT stage_relations_pk PRIMARY KEY (id)
            , CONSTRAINT stage_relations_uniq UNIQUE (parent, child, start_date, end_date)
        );

        /* Создать триггер */
        CREATE OR REPLACE TRIGGER diplom.stage_relations_trigger
        BEFORE INSERT ON diplom.stage_relations FOR EACH ROW
        BEGIN
            :new.id := diplom.stage_relations_seq.nextval;
            :new.start_date := trunc(sysdate);
            :new.end_date := to_date('01013872','ddmmyyyy');
            begin
                select id into :new.parent from diplom.stages where id = :new.parent;
                exception when others then raise_application_error(-20002, 'Не существует этапа с id = '||:new.parent);
            end;
            begin
                select id into :new.child from diplom.stages where id = :new.child;
                exception when others then raise_application_error(-20002, 'Не существует этапа с id = '||:new.child);
            end;
        END;

        /* Удалить таблицу */
        /* DROP TABLE diplom.stage_relations; */
    
    /* ---- Таблица "Связь этапов" ---- */

    /* ---- Таблица "Задания" ---- */

        /* Создать последовательность */
        CREATE SEQUENCE diplom.tasks_seq
        MINVALUE 1
        MAXVALUE 9999
        START WITH 1
        INCREMENT BY 1
        ;

        /* Удалить последовательность */
        /* DROP SEQUENCE diplom.tasks_seq; */

        /* Создать таблицу */
        CREATE TABLE diplom.tasks
        (
            id NUMBER(4) not null
            , type NUMBER(2) not null
            , created_by NUMBER(5) not null
            , creation_date DATE not null
            , inactive_date DATE
            , meaning VARCHAR2(200) not null
            , descrip VARCHAR2(2000) not null
            --, answer NUMBER(6) --как правильно занести при первом объявлении задания? ответ ведь связан с заданием...
            -- ответ брать из таблицы ответов
            , CONSTRAINT tasks_pk PRIMARY KEY (id)
            , CONSTRAINT tasks_uniq UNIQUE (created_by, type, meaning, descrip, inactive_date)
        );

        /* Создать триггер */
        CREATE OR REPLACE TRIGGER diplom.tasks_trigger
        BEFORE INSERT ON diplom.tasks FOR EACH ROW
        BEGIN
            :new.id := diplom.tasks_seq.nextval;
            :new.creation_date := trunc(sysdate);
            :new.inactive_date := to_date('01013872','ddmmyyyy');
            begin
                select id into :new.type from DIPLOM.TASK_TYPES where id = :new.type;
                exception when others then raise_application_error(-20003, 'Не существует типа задания с id = '||:new.type);
            end;
        END;

        /* Удалить таблицу */
        /* DROP TABLE diplom.tasks; */
        
    /* ---- Таблица "Задания" ---- */

    /* ---- Таблица "Тип заданий" ---- */

        /* Создать последовательность */
        CREATE SEQUENCE diplom.task_types_seq
        MINVALUE 1
        MAXVALUE 99
        START WITH 1
        INCREMENT BY 1
        ;

        /* Удалить последовательность */
        /* DROP SEQUENCE diplom.task_types_seq; */

        /* Создать таблицу */
        CREATE TABLE diplom.task_types
        (
            id NUMBER(2) not null
            , MEANING VARCHAR2(50) not null
            , CONSTRAINT task_types_pk PRIMARY KEY (id)
            , CONSTRAINT task_types_uniq UNIQUE (MEANING)
        );

        /* Создать триггер */
        CREATE OR REPLACE TRIGGER diplom.task_types_trigger
        BEFORE INSERT ON diplom.task_types FOR EACH ROW
        BEGIN
            :new.id := diplom.task_types_seq.nextval;
        END;

        /* Удалить таблицу */
        /* DROP TABLE diplom.task_types; */

    /* ---- Таблица "Тип заданий" ---- */

    /* ---- Таблица "Связь заданий" ---- */

        /* Создать последовательность */
        CREATE SEQUENCE diplom.task_relations_seq
        MINVALUE 1
        MAXVALUE 9999
        START WITH 1
        INCREMENT BY 1
        ;

        /* Удалить последовательность */
        /* DROP SEQUENCE diplom.task_relations_seq; */

        /* Создать таблицу */
        CREATE TABLE diplom.task_relations
        (
            id NUMBER(4) not null
            , stage NUMBER(4) not null
            , task NUMBER(4) not null
            , num_task NUMBER(2) not null
            , start_date DATE not null
            , end_date DATE
            , CONSTRAINT task_relations_pk PRIMARY KEY (id)
            , CONSTRAINT task_relations_uniq UNIQUE (stage, task, start_date, end_date)
        );

        /* Создать триггер */
        CREATE OR REPLACE TRIGGER diplom.task_relations_trigger
        BEFORE INSERT ON diplom.task_relations FOR EACH ROW
        BEGIN
            :new.id := diplom.task_relations_seq.nextval;
            if :new.start_date is null then
                :new.start_date := DIPLOM.FND_TASKS.get_stage_date(:new.stage, 0);
            end if;
            if :new.end_date is null then
                :new.end_date := DIPLOM.FND_TASKS.get_stage_date(:new.stage, 1);
            end if;
            begin
                select id into :new.stage from DIPLOM.STAGES where id = :new.stage;
                    exception when others then raise_application_error(-20004, 'Не существует этапа с id = '||:new.stage);
            end;
            begin
                select id into :new.task from DIPLOM.TASKS where id = :new.task;
                    exception when others then raise_application_error(-20004, 'Не существует задания с id = '||:new.task);
            end;
            if :new.num_task is null then
                select
                    count(NUM_TASK) + 1
                into
                    :new.num_task
                from
                    diplom.task_relations
                where 1 = 1
                    and stage = :new.stage
                    and trunc(sysdate) between start_date and end_date
                ;
            end if;
        END;

        CREATE OR REPLACE TRIGGER diplom.task_relations_trigger_update
        BEFORE UPDATE ON diplom.task_relations FOR EACH ROW
        BEGIN
            if DIPLOM.FND_TASKS.valid_task_date(:new.start_date, :old.stage) then :new.start_date := :old.start_date; end if;
            if DIPLOM.FND_TASKS.valid_task_date(:new.end_date, :old.stage) then :new.end_date := :old.end_date; end if;
        END;

        /* Удалить таблицу */
        /* DROP TABLE diplom.task_relations; */
    /* ---- Таблица "Связь заданий" ---- */

/* Блок заданий и этапов */

/* Блок ответов */

    /* ---- Таблица "Ответы" ---- */

        /* Создать последовательность */
        CREATE SEQUENCE diplom.answer_seq
        MINVALUE 1
        MAXVALUE 999999
        START WITH 1
        INCREMENT BY 1
        ;

        /* Удалить последовательность */
        /* DROP SEQUENCE diplom.answer_seq; */

        /* Создать таблицу */
        CREATE TABLE diplom.answer
        (
            id NUMBER(6) not null
            , task NUMBER(4) not null
            , person NUMBER(5) not null
            , creation_date DATE not null
            , primary VARCHAR2(1)
            , rating NUMBER(2)
            , answer VARCHAR2(4000) --первоначально максимальный размер строки в 4000 байт
            , CONSTRAINT answer_pk PRIMARY KEY (id)
        );

        ALTER TABLE DIPLOM.ANSWER add answer_error VARCHAR2(100);

        /* Создать триггер */
        CREATE OR REPLACE TRIGGER diplom.answer_trigger
        BEFORE INSERT ON diplom.answer FOR EACH ROW
        DECLARE
            p_error VARCHAR2(400);
        BEGIN
            :new.id := diplom.answer_seq.nextval;
            :new.creation_date := sysdate;
            begin
                select id into :new.task from DIPLOM.TASKS where id = :new.task;
                    exception when others then raise_application_error(-20005, 'Не существует задания с id = '||:new.task);
            end;
            if diplom.fnd_user.is_admin(:new.person)
            then
                if DIPLOM.FND_TASKS.check_primary_answer(:new.task)
                    then :new.primary := 'Y';
                    else raise_application_error(-20007, p_error);
                end if;
            else
                :new.rating := DIPLOM.fnd_tasks.get_rating(:new.answer, :new.task, p_error);
                if :new.rating < 0 then
                    raise_application_error(-20006, p_error);
                elsif :new.rating = 0 then
                    :new.answer_error := p_error;
                end if;
            end if;
        END;

        /* Удалить таблицу */
        /* drop table diplom.answer; */

    /* ---- Таблица "Ответы" ---- */

    /* ---- Таблица "Оценки" ---- */

        /* Создать последовательность */
        CREATE SEQUENCE diplom.rating_seq
        MINVALUE 1
        MAXVALUE 99
        START WITH 1
        INCREMENT BY 1
        ;

        /* Удалить последовательность */
        /* DROP SEQUENCE diplom.rating_seq; */

        /* Создать таблицу */
        CREATE TABLE diplom.rating
        (
            id NUMBER(2) not null
            , score NUMBER(1) not null
            , meaning VARCHAR2(50)
            , CONSTRAINT rating_pk PRIMARY KEY (id)
        );

        /* Создать триггерв */
        CREATE OR REPLACE TRIGGER diplom.rating_trigger
        BEFORE INSERT ON diplom.rating FOR EACH ROW
        BEGIN
            :new.id := diplom.rating_seq.nextval;
        END;

        /* Удалить таблицу */
        /* DROP TABLE diplom.rating; */

    /* ---- Таблица "Оценки" ---- */

/* Блок ответов */

/* Блок работы */

    /* ---- Таблица "Назначение этапа(ов) студенту" ---- */

        /* Создать последовательность */
        CREATE SEQUENCE DIPLOM.give_stages_seq
        MINVALUE 1
        MAXVALUE 9999999
        START WITH 1
        INCREMENT BY 1
        ;

        /* Удалить последовательность */
        /* DROP SEQUENCE DIPLOM.give_stages_seq; */

        /* Создать таблицу */
        CREATE TABLE DIPLOM.give_stages
        (
            ID NUMBER(7)
            , STUDENT_ID NUMBER(5) not null
            , STAGE NUMBER(3) not null
            , ASSIGNED_DATE DATE
            , ASSIGNED_BY NUMBER(5) not null
            , CONSTRAINT give_stages_pk PRIMARY KEY (id)
            , CONSTRAINT give_stages_uniq UNIQUE (student_id, stage)
        );

        /* Создать триггер */
        CREATE OR REPLACE TRIGGER DIPLOM.give_stages_trigger
        BEFORE INSERT ON DIPLOM.give_stages FOR EACH ROW
        BEGIN
            :new.id := DIPLOM.give_stages_seq.nextval;
            :new.ASSIGNED_DATE := sysdate;
        END;

        /* Удалить таблицу */
        /* DROP TABLE DIPLOM.give_stages; */


    /* ---- Таблица "Назначение этапа(ов) студенту" ---- */

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    /* ---- Таблица "Прогресс работы" ---- */

        /* Создать последовательность */
        CREATE SEQUENCE DIPLOM.work_progress_seq
        MINVALUE 1
        MAXVALUE 9999999
        START WITH 1
        INCREMENT BY 1
        ;

        /* Удалить последовательность */
        /* DROP SEQUENCE DIPLOM.work_progress_seq; */

        /* Создать таблицу */
        CREATE TABLE DIPLOM.work_progress
        (
            id NUMBER(7) not null
            , user NUMBER(5) not null
            , stage NUMBER(3) not null
            , task NUMBER(4) not null
            , last_answer NUMBER(6) not null
            , last_rating NUMBER(2) not null
            , start_date DATE
            , updated_date DATE
            , cnt_answer NUMBER(2) not null
            , CONSTRAINT work_progress_pk PRIMARY KEY (id, user, stage, task, last_answer, start_date, updated_date, cnt_answer)
        );

        /* Создать триггер */
        CREATE OR REPLACE TRIGGER DIPLOM.work_progress_trigger
        BEFORE INSERT ON DIPLOM.work_progress FOR EACH ROW
        BEGIN
            :new.id := DIPLOM.work_progress_seq.nextval;
            :new.start_date := trunc(sysdate);
            :new.updated_date := trunc(sysdate);
        END;

        /* Удалить таблицу */
        /* DROP TABLE diplom.work_progress; */
    /* ---- Таблица "Прогресс работы" ---- */

/* Блок работы */