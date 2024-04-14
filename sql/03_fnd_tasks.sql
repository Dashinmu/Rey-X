/* Пакет для работы с блоком заданий */
CREATE OR REPLACE PACKAGE DIPLOM.fnd_tasks IS

    --Создать этап
    PROCEDURE add_stage(
        p_meaning in VARCHAR2
        , stage_name in VARCHAR2 default null
        , p_time_period in NUMBER default null
    );

    --Связать этап
    PROCEDURE connect_stage(
        p_parent in NUMBER
        , p_child in NUMBER
    );

    --Создать задание
    PROCEDURE add_task(
        p_meaning in VARCHAR2
        , p_desc in VARCHAR2
        , p_type in NUMBER
        , p_answer in VARCHAR2
        , p_author in NUMBER
    );

    --Связать задание
    PROCEDURE connect_task(
        p_num in NUMBER
        , p_stage in NUMBER
        , p_num_task in NUMBER
    );

    --Создать ответ
    PROCEDURE add_answer(
        p_user in NUMBER
        , p_answer in VARCHAR2
        , p_task in NUMBER
    );

    --Получить ответ
    FUNCTION get_rating(
        p_answer in VARCHAR2
        , p_task in NUMBER
    ) RETURN NUMBER;

END fnd_tasks;

CREATE OR REPLACE PACKAGE BODY DIPLOM.fnd_tasks IS

    --Создать этап
    PROCEDURE add_stage(
        p_meaning in VARCHAR2
        , stage_name in VARCHAR2
        , p_time_period in NUMBER default null
    ) IS
    BEGIN
        insert into DIPLOM.stages(
            stage_name
            , meaning
            , time_period
        ) values (
            stage_name
            , p_meaning
            , p_time_period
        );
    END add_stage;

    --Связать этап
    PROCEDURE connect_stage(
        p_parent in NUMBER
        , p_child in NUMBER
    ) IS
    BEGIN
        insert into DIPLOM.stage_relations(
            parent
            , child
        ) values (
            p_parent
            , p_child
        );
    END connect_stage;

    --Создать задание
    PROCEDURE add_task(
        p_meaning in VARCHAR2
        , p_desc in VARCHAR2
        , p_type in NUMBER
        , p_answer in VARCHAR2
        , p_author in NUMBER
    ) IS
        currTask NUMBER(4);
    BEGIN
        /* Сначала создать задание */
        begin
            insert into DIPLOM.tasks(
                type
                , created_by
                , meaning
                , descrip
            ) values (
                p_type
                , p_author
                , p_meaning
                , p_desc
            );
            currTask := DIPLOM.tasks_seq.currval;
            commit;
        end;
        /* Затем создать ответ */
        add_answer(p_author, p_answer, currTask);
    END add_task;

    --Связать задание
    PROCEDURE connect_task(
        p_num in NUMBER
        , p_stage in NUMBER
        , p_num_task in NUMBER
    ) IS
    BEGIN
        null;
    END connect_task;

    --Создать ответ
    PROCEDURE add_answer(
        p_user in NUMBER
        , p_answer in VARCHAR2
        , p_task in NUMBER
    ) IS
    BEGIN
        insert into DIPLOM.answer(
            task
            , person
            , answer
        ) values (
            p_task
            , p_user
            , p_answer
        );
        commit;
    END add_answer;

    /* --Получить ответ
    FUNCTION get_answer(
        p_user in VARCHAR2
        , p_answer in VARCHAR2
        , p_task in NUMBER
    ) RETURN NUMBER IS
        user_id NUMBER(5);
        answer_id NUMBER(6);
    BEGIN
        begin
            select id into user_id from DIPLOM.users where login = p_user;
        end;
        add_answer(user_id, p_answer, p_task);
        begin
            select
                id
            into
                answer_id
            from
                DIPLOM.answer
            where 1 = 1
                and person = user_id
                and task = p_task
                and answer = p_answer
            ;
            exception when others then answer_id := -1;
        end;
        return answer_id;
    END; */

    --Получить результат
    FUNCTION get_rating(
        p_answer in VARCHAR2
        , p_task in NUMBER
    ) RETURN NUMBER IS
        curr_answer VARCHAR2(4000);
        task_type NUMBER(2);
        score NUMBER(2);
    BEGIN
        begin
            select
                answer
            into
                curr_answer
            from
                DIPLOM.answer
            where 1 = 1
                and primary = 'Y'
                and task = p_task
            ;
        end;
        begin
            select
                type
            into
                task_type
            from
                DIPLOM.tasks
            where 1 = 1
                and p_task = id
            ;
        end;
        case task_type
            when 1 --Один вариант ответа
                then null;
            when 2 --Строгий свободный вариант ответа
                then null;
            when 3 --Вариант который нужно проверить куратором
                then null;
            when 4 --Проверка кода
                then null;
            else --Ошибка 
                null;
        end case;
        return score;
    END;

END fnd_tasks;