/* Пакет для работы с блоком заданий */
CREATE OR REPLACE PACKAGE DIPLOM.fnd_tasks IS

    --Создать этап
    PROCEDURE add_stage(
        p_meaning in VARCHAR2
        , p_stage_name in VARCHAR2 default null
        , p_author in NUMBER
        , p_time_period in NUMBER default null
        , p_error out VARCHAR2
    );

    --Связать этап
    PROCEDURE connect_stage(
        p_parent in NUMBER
        , p_child in NUMBER
        , p_error out VARCHAR2
    );

    --Создать тип задания
    PROCEDURE add_task_type(
        p_meaning in VARCHAR2
    );

    --Создать задание
    PROCEDURE add_task(
        p_meaning in VARCHAR2
        , p_desc in VARCHAR2
        , p_type in NUMBER
        , p_author in NUMBER
        , p_id_task out NUMBER
        , p_error out VARCHAR2
    );

    --Связать задание
    PROCEDURE connect_task(
        p_stage in NUMBER
        , p_task in NUMBER
        , p_num_task in NUMBER default null --последовательность задания в этапе
        , p_start_date in DATE default null
        , p_end_date in DATE default null
        , p_error out VARCHAR2
    );

    --Создать ответ
    PROCEDURE add_answer(
        p_user in NUMBER
        , p_answer in VARCHAR2
        , p_task in NUMBER
        , p_error out VARCHAR2
    );

    --Получить ответ
    FUNCTION get_rating(
        p_answer in VARCHAR2
        , p_task in NUMBER
    ) RETURN NUMBER;

END fnd_tasks;

CREATE OR REPLACE PACKAGE BODY DIPLOM.fnd_tasks IS

    --Глобальные переменные
    no_stage_found exception; --Не найден этап
    PRAGMA EXCEPTION_INIT(no_stage_found, -20002); --Связать с ошибкой в триггере
    no_task_type_found exception; --Не найден тип задачи
    PRAGMA EXCEPTION_INIT(no_task_type_found, -20003); --Связать с ошибкой в триггере
    error_relations exception; --Ошибка при соединении задач с этапами
    PRAGMA EXCEPTION_INIT(error_relations, -20004); --Связать с ошибкой в триггере
    error_answer exception; --Ошибки при создании ответов
    PRAGMA EXCEPTION_INIT(error_answer, -20005); --Связать с ошибкой в триггере

    --Создать этап
    PROCEDURE add_stage(
        p_meaning in VARCHAR2
        , p_stage_name in VARCHAR2 default null
        , p_author in NUMBER
        , p_time_period in NUMBER default null
        , p_error out VARCHAR2
    ) IS
    BEGIN
        insert into DIPLOM.STAGES(
            STAGE_NAME
            , MEANING
            , CREATED_BY
            , TIME_PERIOD
        ) values (
            p_stage_name
            , p_meaning
            , p_author
            , p_time_period
        );
        commit;

        exception when others then p_error := 'Нарушено условие уникальности stages_uniq';
    END add_stage;

    --Связать этап
    PROCEDURE connect_stage(
        p_parent in NUMBER
        , p_child in NUMBER
        , p_error out VARCHAR2
    ) IS
    BEGIN
        insert into DIPLOM.stage_relations(
            parent
            , child
        ) values (
            p_parent
            , p_child
        );
        commit;

        exception when others then p_error := SQLERRM;
    END connect_stage;

    --Создать тип задания
    PROCEDURE add_task_type(
        p_meaning in VARCHAR2
    ) IS
    BEGIN
        insert into diplom.task_types(
            meaning
        ) values (
            p_meaning
        );
        commit;
    END;

    --Создать задание
    PROCEDURE add_task(
        p_meaning in VARCHAR2
        , p_desc in VARCHAR2
        , p_type in NUMBER
        , p_author in NUMBER
        , p_id_task out NUMBER
        , p_error out VARCHAR2
    ) IS
    BEGIN
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
            p_id_task := DIPLOM.tasks_seq.currval;
        end;
        commit;
        
        exception when others then p_error := SQLERRM;
    END add_task;

    --Связать задание
    PROCEDURE connect_task(
        p_stage in NUMBER
        , p_task in NUMBER
        , p_num_task in NUMBER default null --последовательность задания в этапе
        , p_start_date in DATE default null
        , p_end_date in DATE default null
        , p_error out VARCHAR2
    ) IS
    BEGIN
        insert into DIPLOM.task_relations(
            stage
            , task
            , num_task
            , start_date
            , end_date
        ) values (
            p_stage
            , p_task
            , p_num_task
            , p_start_date
            , p_end_date
        );
        commit;

        exception when others then p_error := SQLERRM;
    END connect_task;

    --Форматировать формат ответа
    FUNCTION format_answer(
        p_answer in VARCHAR2
        , p_task_type in NUMBER
    ) RETURN VARCHAR2 IS
        res VARCHAR2(4000);
    BEGIN
        if p_task_type = 1 then res := 'ACCEPT';
        elsif p_task_type = 2 then res := upper(replace(trim(p_answer), ' ', ';'));
        else res := upper(trim(p_answer));
        end if;
        return res;
    END;

    FUNCTION get_task_type(
        p_task in NUMBER
    ) RETURN NUMBER IS
        res NUMBER(2);
    BEGIN
        select
            TYPE
        into
            res
        from 
            DIPLOM.TASKS
        where 1 = 1
            and ID = p_task
        ;
        return res;

        exception when others then return 0;
    END;

    --Создать ответ
    PROCEDURE add_answer(
        p_user in NUMBER
        , p_answer in VARCHAR2
        , p_task in NUMBER
        , p_error out VARCHAR2
    ) IS
        res VARCHAR2(4000);
    BEGIN
        res := format_answer(p_answer, get_task_type(p_task));
        insert into DIPLOM.answer(
            task
            , person
            , answer
        ) values (
            p_task
            , p_user
            , res
        );
        commit;

        exception when others then p_error := SQLERRM;
    END add_answer;

    FUNCTION get_true_answer(
        p_task in NUMBER
    ) RETURN VARCHAR2 IS
        res VARCHAR2(4000);
    BEGIN
        begin
            select
                answer
            into
                res
            from
                DIPLOM.answer
            where 1 = 1
                and primary = 'Y'
                and task = p_task
            ;
        end;
        return res;

        exception when others then return 'ERROR_NO_TRUE_ANSWER_FOUND';
    END;

    --Получить результат
    FUNCTION get_rating(
        p_answer in VARCHAR2
        , p_task in NUMBER
    ) RETURN NUMBER IS
        curr_answer VARCHAR2(4000);
        task_type NUMBER(2);
        score NUMBER(2);
        --курсоры для сравнения кода
        type cursor_tutor is ref cursor;
        r_tutor cursor_tutor;
        type cursor_student is ref cursor;
        r_student cursor_student;
    BEGIN
        curr_answer := get_true_answer(p_task);
        task_type := get_task_type(p_task);
        case task_type
            when 1 then score := 1;
            when 2 then 
                if p_answer = curr_answer
                    then score := 1;
                    else score := 0;
                end if;
            when 3 --Static SQL
                then null;
            when 4
                then null;
            else --Ошибка 
                null;
        end case;
        return score;
    END;

END fnd_tasks;