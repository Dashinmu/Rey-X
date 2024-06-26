/* Пакет для работы с блоком заданий */
CREATE OR REPLACE PACKAGE DIPLOM.fnd_tasks IS

    --Создать этап
    PROCEDURE add_stage(
        p_meaning in VARCHAR2
        , p_stage_name in VARCHAR2 default null
        , p_author in NUMBER
        , p_time_period in NUMBER default null
        , p_stage_id out NUMBER
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
        , p_num_task in NUMBER default null --последовательность задания в этапе автомат
        , p_start_date in VARCHAR2 default null
        , p_end_date in VARCHAR2 default null
        , p_error out VARCHAR2
    );

    --Создать ответ
    PROCEDURE add_answer(
        p_user in NUMBER
        , p_answer in VARCHAR2
        , p_task in NUMBER
        , p_error out VARCHAR2
        , p_status out NUMBER
    );

    --Получить ответ
    FUNCTION get_rating(
        p_answer in VARCHAR2
        , p_task in NUMBER
        , p_error out VARCHAR2
    ) RETURN NUMBER;

    --Выдать этап студенту
    PROCEDURE give_stage(
        p_user in NUMBER
        , p_stage in NUMBER
        , p_student in NUMBER
        , p_error out VARCHAR2
    );

    --Всего заданий в этапе
    FUNCTION get_stage_tasks(
        p_stage in NUMBER
        , p_date in DATE
    ) RETURN NUMBER;

    --Узнать есть ли у студента верный ответ на задание
    FUNCTION get_student_true_answer(
        p_task in NUMBER
        , p_student in NUMBER
    ) RETURN NUMBER; --вернуть ид ответа

    --Прогресс студента в этапе
    FUNCTION get_student_progress_stage(
        p_stage in NUMBER
        , p_student in NUMBER
    ) RETURN NUMBER;

    --Всего начато заданий
    FUNCTION get_student_all_progress_stage(
        p_stage in NUMBER
        , p_student in NUMBER
    ) RETURN NUMBER;

    --Получить id последнего ответа
    FUNCTION get_last_answer_time(
        p_task in NUMBER
        , p_student in NUMBER
    ) RETURN NUMBER;

    --Проверить существует ли ответ с флагом PRIMARY Y на задании
    FUNCTION check_primary_answer(
        p_task in NUMBER
    ) RETURN BOOLEAN;

    --Узнать количество назначенных этапов
    FUNCTION get_all_students_assigned_stages(
        p_student in NUMBER
    ) RETURN NUMBER;

    --Обновить задание
    PROCEDURE update_task(
        p_task_id in NUMBER
        , p_task_meaning in VARCHAR2
        , p_task_descrip in VARCHAR2
        , p_task_type_id in NUMBER
        , p_task_start_date in VARCHAR2
        , p_task_end_date in VARCHAR2
        , p_task_answer in VARCHAR2
        , p_user in NUMBER
        , p_error out VARCHAR2
    );

    --Функция проверки вхождения даты задания в диапазон Stage
    FUNCTION valid_task_date(
        p_date in DATE
        , p_stage in NUMBER
    ) RETURN BOOLEAN;

    --Получить последнюю дату Stage
    FUNCTION get_stage_date(
        p_stage in NUMBER
        , p_date in NUMBER
    ) RETURN DATE;

    --Получить итоговую оценку
    PROCEDURE GET_GENERAL_RATING(
        p_user in NUMBER
        , p_current_rating out NUMBER
        , p_max_rating out NUMBER
        , p_string out VARCHAR2
    );

    PROCEDURE UPDATE_CONNECT_STAGE_TASK(
        p_task in NUMBER
        , p_stage in NUMBER
        , p_start_date in VARCHAR2
        , p_end_date in VARCHAR2
        , p_error out VARCHAR2
    );

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
        , p_stage_id out NUMBER
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
        p_stage_id := DIPLOM.stages_seq.currval;
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
        , p_start_date in VARCHAR2 default null
        , p_end_date in VARCHAR2 default null
        , p_error out VARCHAR2
    ) IS
        start_date DATE := to_date(p_start_date, 'YYYY-MM-DD');
        end_date DATE := to_date(p_end_date, 'YYYY-MM-DD');
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
            , start_date
            , end_date
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
        /* elsif p_task_type = 3 then res := upper(replace(trim(p_answer), chr(39), '''')); */
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

    --Проверка последнее ли это задание в этапе
    FUNCTION is_last_task_in_stage(
        p_task in NUMBER
    ) RETURN NUMBER IS
        num_task_max NUMBER(2);
        p_stage_last NUMBER(3);
    BEGIN
        SELECT
            max(num_task)
        INTO
            num_task_max
        FROM
            DIPLOM.TASK_RELATIONS
        WHERE 1 = 1
            AND STAGE in (
                SELECT
                    STAGE
                FROM
                    DIPLOM.TASK_RELATIONS
                WHERE 1 = 1
                    and TASK = p_task
            )
        ;
        SELECT
            STAGE
        INTO
            p_stage_last
        FROM
            DIPLOM.TASK_RELATIONS
        WHERE 1 = 1
            and TASK = p_task
            and NUM_TASK = num_task_max
        ;
        RETURN p_stage_last;
        EXCEPTION WHEN OTHERS THEN RETURN 0;
    END;

    --Проверить выдан ли этап
    FUNCTION stage_already_gived(p_stage in NUMBER, p_student in NUMBER) RETURN BOOLEAN IS
        flag NUMBER(1);
    BEGIN
        SELECT
            1
        INTO
            flag
        FROM
            DIPLOM.GIVE_STAGES
        WHERE 1 = 1
            and STAGE = p_stage
            and STUDENT_ID = p_student
        ;
        return false;
        exception when others then return true;
    END;

    --Создать ответ
    PROCEDURE add_answer(
        p_user in NUMBER
        , p_answer in VARCHAR2
        , p_task in NUMBER
        , p_error out VARCHAR2
        , p_status out NUMBER
    ) IS
        res VARCHAR2(4000);
        cursor get_next_stages(p_stage in NUMBER) IS
            select
                CHILD
            from
                DIPLOM.STAGE_RELATIONS
            where 1 = 1
                and PARENT = p_stage
        ;
        r get_next_stages%ROWTYPE;
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
        select
            rating
            , answer_error
        into
            p_status
            , p_error
        from
            DIPLOM.ANSWER
        where 1 = 1
            and task = p_task
            and person = p_user
            and id = (
                select
                    max(id)
                from
                    DIPLOM.ANSWER
                where 1 = 1
                    and task = p_task
                    and person = p_user
            )
        ;
        if DIPLOM.FND_USER.IS_ADMIN(P_USER  => p_user) then null; else
            if is_last_task_in_stage(p_task) != 0 then
                begin
                    for r in get_next_stages( is_last_task_in_stage(p_task) ) loop
                        if stage_already_gived(r.CHILD, p_user) then
                            DIPLOM.FND_TASKS.give_stage(
                                P_USER => 1
                                , P_STAGE => r.CHILD
                                , P_STUDENT => p_user
                                , P_ERROR => p_error
                            );
                        end if;
                    end loop;
                end;
            end if;
        end if;
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

    --Сравнить два запроса
    FUNCTION compare_selects(
        p_true_select in VARCHAR2
        , p_select in VARCHAR2
        , p_error out VARCHAR2
    ) RETURN NUMBER IS
        cursor_tutor VARCHAR2(4000); --верный запрос
            v_cur_tutor_id integer;
            v_col_tutor_cnt integer;
            v_cols_tutor dbms_sql.desc_tab;
            v_rows_tutor integer;
            v_res_tutor_char VARCHAR2(1000);
            v_res_tutor_number NUMBER;
            v_res_tutor_date DATE;
            v_res_tutor_clob CLOB;
            v_res_tutor_time TIMESTAMP;
        cursor_student VARCHAR2(4000); --запрос студента
            v_cur_student_id integer;
            v_col_student_cnt integer;
            v_cols_student dbms_sql.desc_tab;
            v_rows_student integer;
            v_res_student_char VARCHAR2(1000);
            v_res_student_number NUMBER;
            v_res_student_date DATE;
            v_res_student_clob CLOB;
            v_res_student_time TIMESTAMP;
        wrong_answer exception; --остановка проверки
        wrong_answer_cnt_columns exception;
        wrong_answer_column_name exception;
        wrong_answer_cnt_rows exception;
        i integer; --столбцы
        j integer; --номер строки
        /* res NUMBER(1) := 1; --соответствует верному результату */
    BEGIN
        cursor_tutor := p_true_select;
        cursor_student := p_select;
        v_cur_tutor_id := dbms_sql.open_cursor; --получить номер курсора
        v_cur_student_id := dbms_sql.open_cursor;

        dbms_sql.PARSE(v_cur_tutor_id, cursor_tutor, dbms_sql.native); --парсить курсор
        dbms_sql.PARSE(v_cur_student_id, cursor_student, dbms_sql.native);

        dbms_sql.DESCRIBE_COLUMNS(v_cur_tutor_id, v_col_tutor_cnt, v_cols_tutor); --получить столбцы запроса
        dbms_sql.DESCRIBE_COLUMNS(v_cur_student_id, v_col_student_cnt, v_cols_student);

        if v_col_tutor_cnt <> v_col_student_cnt 
            then raise wrong_answer_cnt_columns; --выходим если нет, дальше проверять нет смысла
        end if;

        for i in 1 .. v_col_tutor_cnt loop
            if v_cols_tutor(i).col_name <> v_cols_student(i).col_name then -- снимаем флаг если наименования столбцов разняться
                raise wrong_answer_column_name;
            else
                IF v_cols_tutor(i).col_type in (1, 96, 11, 208) then --IN VARCHAR2
                    dbms_sql.DEFINE_COLUMN(v_cur_tutor_id, i, v_res_tutor_char, 1000);
                    dbms_sql.DEFINE_COLUMN(v_cur_student_id, i, v_res_student_char, 1000);
                ELSIF v_cols_tutor(i).col_type in (2) then --IN NUMBER
                    dbms_sql.DEFINE_COLUMN(v_cur_tutor_id, i, v_res_tutor_number);
                    dbms_sql.DEFINE_COLUMN(v_cur_student_id, i, v_res_student_number);
                ELSIF v_cols_tutor(i).col_type in (12) then --IN DATE
                    dbms_sql.DEFINE_COLUMN(v_cur_tutor_id, i, v_res_tutor_date);
                    dbms_sql.DEFINE_COLUMN(v_cur_student_id, i, v_res_tutor_date);
                ELSIF v_cols_tutor(i).col_type in (112) then --IN CLOB
                    dbms_sql.DEFINE_COLUMN(v_cur_tutor_id, i, v_res_tutor_clob);
                    dbms_sql.DEFINE_COLUMN(v_cur_student_id, i, v_res_student_clob);  
                ELSIF v_cols_tutor(i).col_type in (180) then --IN TIMESTAMP
                    dbms_sql.DEFINE_COLUMN(v_cur_tutor_id, i, v_res_tutor_time);
                    dbms_sql.DEFINE_COLUMN(v_cur_student_id, i, v_res_student_time); 
                ELSE
                    dbms_sql.DEFINE_COLUMN(v_cur_tutor_id, i, v_res_tutor_char, 1000);
                    dbms_sql.DEFINE_COLUMN(v_cur_student_id, i, v_res_student_char, 1000);             
                end if;
            end if;
        end loop;

        v_rows_tutor := dbms_sql.EXECUTE(v_cur_tutor_id); --выполнить
        v_rows_student := dbms_sql.EXECUTE(v_cur_student_id);

        loop --сравним строки курсора препода с курсором студента
            if dbms_sql.FETCH_ROWS(v_cur_tutor_id) > 0 then
                if dbms_sql.FETCH_ROWS(v_cur_student_id) > 0 then --если записей меньше - ошибка
                    for i in 1 .. v_col_tutor_cnt loop --сравнить все столбцы в строке, количество столбцов уже проверили
                        /* УСЛОВИЕ ПО РАБОТЕ С ТИПОМ СТОЛБЦОВ */
                        IF v_cols_tutor(i).col_type in (1, 96, 11, 208) then --IN VARCHAR2
                            dbms_sql.COLUMN_VALUE(v_cur_tutor_id, i, v_res_tutor_char);
                            dbms_sql.COLUMN_VALUE(v_cur_student_id, i, v_res_student_char);
                            if  v_res_tutor_char <> v_res_student_char then
                                raise wrong_answer;
                            end if;
                        ELSIF v_cols_tutor(i).col_type in (2) then --IN NUMBER
                            dbms_sql.COLUMN_VALUE(v_cur_tutor_id, i, v_res_tutor_number);
                            dbms_sql.COLUMN_VALUE(v_cur_student_id, i, v_res_student_number);
                            if  v_res_tutor_number <> v_res_student_number then
                                raise wrong_answer;
                            end if;
                        ELSIF v_cols_tutor(i).col_type in (12) then --IN DATE
                            dbms_sql.COLUMN_VALUE(v_cur_tutor_id, i, v_res_tutor_date);
                            dbms_sql.COLUMN_VALUE(v_cur_student_id, i, v_res_student_date);
                            if  v_res_tutor_date <> v_res_student_date then
                                raise wrong_answer;
                            end if;
                        ELSIF v_cols_tutor(i).col_type in (112) then --IN CLOB
                            dbms_sql.COLUMN_VALUE(v_cur_tutor_id, i, v_res_tutor_clob);
                            dbms_sql.COLUMN_VALUE(v_cur_student_id, i, v_res_student_clob);
                            if  v_res_tutor_clob <> v_res_student_clob then
                                raise wrong_answer;
                            end if;
                        ELSIF v_cols_tutor(i).col_type in (180) then --IN TIMESTAMP
                            dbms_sql.COLUMN_VALUE(v_cur_tutor_id, i, v_res_tutor_time);
                            dbms_sql.COLUMN_VALUE(v_cur_student_id, i, v_res_student_time);
                            if  v_res_tutor_time <> v_res_student_time then
                                raise wrong_answer;
                            end if;
                        ELSE
                            dbms_sql.COLUMN_VALUE(v_cur_tutor_id, i, v_res_tutor_char);
                            dbms_sql.COLUMN_VALUE(v_cur_student_id, i, v_res_student_char);
                        END IF;
                    end loop;
                else
                    raise wrong_answer_cnt_rows;
                end if;
            else --проверить количество строк в курсоре студента и выйти
                j := DBMS_SQL.LAST_ROW_COUNT;
                if j <> j + dbms_sql.FETCH_ROWS(v_cur_student_id)
                    then raise wrong_answer_cnt_rows;
                end if;
                exit;
            end if;
        end loop;

        dbms_sql.CLOSE_CURSOR(v_cur_tutor_id); --закрыть курсоры
        dbms_sql.CLOSE_CURSOR(v_cur_student_id);

        return 1;
        --хоть одна ошибка попадаем сюда
        exception 
            when wrong_answer_cnt_columns then 
                dbms_sql.CLOSE_CURSOR(v_cur_tutor_id); --закрыть курсоры
                dbms_sql.CLOSE_CURSOR(v_cur_student_id);
                p_error := 'Неверное количество столбцов';
                return 0;
            when wrong_answer_column_name then 
                dbms_sql.CLOSE_CURSOR(v_cur_tutor_id); --закрыть курсоры
                dbms_sql.CLOSE_CURSOR(v_cur_student_id);
                p_error := 'Неверное наименование столбцов';
                return 0;
            when wrong_answer then 
                dbms_sql.CLOSE_CURSOR(v_cur_tutor_id); --закрыть курсоры
                dbms_sql.CLOSE_CURSOR(v_cur_student_id);
                p_error := 'Несовпадают значения в столбце';
                return 0;
            when wrong_answer_cnt_rows then 
                dbms_sql.CLOSE_CURSOR(v_cur_tutor_id); --закрыть курсоры
                dbms_sql.CLOSE_CURSOR(v_cur_student_id);
                p_error := 'Неверное количество строк';
                return 0;
            when others then
                if dbms_sql.IS_OPEN(v_cur_tutor_id) then
                    dbms_sql.CLOSE_CURSOR(v_cur_tutor_id); --закрыть курсоры
                end if;
                if dbms_sql.IS_OPEN(v_cur_student_id) then
                    dbms_sql.CLOSE_CURSOR(v_cur_student_id);
                end if;
                p_error := SQLERRM;
                return -1;
    END compare_selects;

    --Получить результат
    FUNCTION get_rating(
        p_answer in VARCHAR2
        , p_task in NUMBER
        , p_error out VARCHAR2
    ) RETURN NUMBER IS
        curr_answer VARCHAR2(4000);
        task_type NUMBER(2);
        score NUMBER(2);
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
                then score := compare_selects(curr_answer, p_answer, p_error);
            when 4
                then score := 2;
            else --Ошибка 
                null;
        end case;
        return score;
    END;

    --Выдать этап студенту
    PROCEDURE give_stage(
        p_user in NUMBER
        , p_stage in NUMBER
        , p_student in NUMBER
        , p_error out VARCHAR2
    ) IS
    BEGIN
        begin
            insert into DIPLOM.GIVE_STAGES(
                ASSIGNED_BY
                , STAGE
                , STUDENT_ID
            ) values (
                p_user
                , p_stage
                , p_student
            );
        end;
        commit;

        EXCEPTION WHEN OTHERS THEN p_error := SQLERRM;
    END;

    --Всего заданий в этапе
    FUNCTION get_stage_tasks(
        p_stage in NUMBER
        , p_date in DATE
    ) RETURN NUMBER IS
        res NUMBER(2);
    BEGIN
        select
            count(NUM_TASK)
        into
            res
        from
            DIPLOM.TASK_RELATIONS
        where 1 = 1
            and STAGE = p_stage
            /* and p_date between START_DATE and END_DATE */
        ;
        return res;
    END;

    --Узнать есть ли у студента верный ответ на задание
    FUNCTION get_student_true_answer(
        p_task in NUMBER
        , p_student in NUMBER
    ) RETURN NUMBER IS --вернуть ид ответа
        res NUMBER(6);
    BEGIN
        select
            ID
        into
            res
        from
            DIPLOM.ANSWER
        where 1 = 1
            and PERSON = p_student
            and TASK = p_task
            and RATING in (1)
            and ROWNUM = 1
        ;
        return res;

        EXCEPTION WHEN OTHERS THEN return -1;
    END;

    --Прогресс студента в этапе
    FUNCTION get_student_progress_stage(
        p_stage in NUMBER
        , p_student in NUMBER
    ) RETURN NUMBER IS
        res NUMBER(2);
    BEGIN
        select
            count(distinct a.TASK)
        into
            res
        from
            DIPLOM.ANSWER a
            join DIPLOM.TASK_RELATIONS tr
                on tr.STAGE = p_stage
                and a.TASK = tr.TASK
        where 1 = 1
            and a.PERSON = p_student
            and a.RATING in (1)
        ;
        return res;
    END;

    --Всего начато заданий
    FUNCTION get_student_all_progress_stage(
        p_stage in NUMBER
        , p_student in NUMBER
    ) RETURN NUMBER IS
        res NUMBER(2);
    BEGIN
        select
            count(distinct a.TASK)
        into
            res
        from
            DIPLOM.ANSWER a
            join DIPLOM.TASK_RELATIONS tr
                on tr.STAGE = p_stage
                and a.TASK = tr.TASK
        where 1 = 1
            and a.PERSON = p_student
        ;
        return res;
    END;

    --Получить id последнего ответа
    FUNCTION get_last_answer_time(
        p_task in NUMBER
        , p_student in NUMBER
    ) RETURN NUMBER IS
        res NUMBER;
    BEGIN
        select
            a.ID
        into
            res
        from 
            DIPLOM.ANSWER a
        where 1 = 1
            and a.PERSON = p_student
            and a.TASK = p_task
            and a.CREATION_DATE = (
                select
                    max(CREATION_DATE)
                from
                    DIPLOM.ANSWER
                where 1 = 1
                    and PERSON = a.PERSON
                    and TASK = a.TASK
            )
        ;
        return res;

        EXCEPTION WHEN OTHERS THEN return -1;
    END;

    --Проверить существует ли ответ с флагом PRIMARY Y на задании
    FUNCTION check_primary_answer(
        p_task in NUMBER
    ) RETURN BOOLEAN IS
        flag NUMBER(1);
    BEGIN
        select
            1
        into
            flag
        from
            diplom.ANSWER
        where 1 = 1
            and PRIMARY like 'Y'
            and TASK = p_task
        ;
        return false;
        exception when others then return true;
    END;

    --Узнать количество назначенных этапов
    FUNCTION get_all_students_assigned_stages(
        p_student in NUMBER
    ) RETURN NUMBER IS
        res NUMBER(2);
    BEGIN
        select
            count(stage)
        into
            res
        from
            DIPLOM.GIVE_STAGES
        where 1 = 1
            and STUDENT_ID = p_student
        ;
        return res;
    END;

    --Обновить задание
    PROCEDURE update_task(
        p_task_id in NUMBER
        , p_task_meaning in VARCHAR2
        , p_task_descrip in VARCHAR2
        , p_task_type_id in NUMBER
        , p_task_start_date in VARCHAR2
        , p_task_end_date in VARCHAR2
        , p_task_answer in VARCHAR2
        , p_user in NUMBER
        , p_error out VARCHAR2
    ) IS
        p_start_date_rel_old DATE;
    BEGIN
        UPDATE
            DIPLOM.TASKS
        SET
            TYPE = p_task_type_id
            , CREATION_DATE = to_date(p_task_start_date, 'YYYY-MM-DD')
            , INACTIVE_DATE = to_date(p_task_end_date, 'YYYY-MM-DD')
            , MEANING = p_task_meaning
            , DESCRIP = p_task_descrip
        WHERE 1 = 1
            and ID = p_task_id
        ;
        
        UPDATE
            DIPLOM.ANSWER
        SET
            ANSWER = p_task_answer
        WHERE 1 = 1
            and TASK = p_task_id
            and PRIMARY like 'Y'
        ;
        
        UPDATE
            DIPLOM.TASK_RELATIONS
        SET
            START_DATE = to_date(p_task_start_date, 'YYYY-MM-DD')
            , END_DATE = to_date(p_task_end_date, 'YYYY-MM-DD')
        WHERE 1 = 1
            and TASK = p_task_id
        ;
        commit;
        exception when others then p_error := SQLERRM;
    END;

    --Функция проверки вхождения даты задания в диапазон Stage
    FUNCTION valid_task_date(
        p_date in DATE
        , p_stage in NUMBER
    ) RETURN BOOLEAN IS
        flag NUMBER;
    BEGIN
        select
            1
        into
            flag
        from
            DIPLOM.STAGES
        where 1 = 1
            and p_date between CREATION_DATE and INACTIVE_DATE
        ;
        return true;
        exception when others then return false;
    END;

    --Получить последнюю дату Stage
    FUNCTION get_stage_date(
        p_stage in NUMBER
        , p_date in NUMBER
    ) RETURN DATE IS
        res DATE;
    BEGIN
        if p_date = 1
            then
                begin
                    select
                        inactive_date
                    into
                        res
                    from
                        DIPLOM.STAGES
                    where
                        ID = p_stage
                    ;
                    exception when others then res := to_date('01012100','ddmmyyyy');
                end;
            else
                begin
                    select
                        creation_date
                    into
                        res
                    from
                        DIPLOM.STAGES
                    where
                        ID = p_stage
                    ;
                    exception when others then res := trunc(sysdate);
                end;
        end if;
        return res;
    END;

    --Получить итоговую оценку
    PROCEDURE GET_GENERAL_RATING(
        p_user in NUMBER
        , p_current_rating out NUMBER
        , p_max_rating out NUMBER
        , p_string out VARCHAR2
    ) IS
        current_complete_task NUMBER(3);
        max_task NUMBER(3);
        cursor q1 (p_user in NUMBER) is
            SELECT
                stage_id
                , max(STAGE_NUM_TASKS) snt
                , max(TASK_COMPLETE_IN_STAGE) tcis
            FROM
                DIPLOM.PRACTICE_PROGRESS_INFO
            WHERE 1 = 1
                and STUDENT_ID = p_user
            GROUP BY
                stage_id
        ;
        r q1%ROWTYPE;
        rating NUMBER(3) := 0;
        rating1 NUMBER(3) := 0;
        rating2 NUMBER(3) := 0;
        i NUMBER(2) := 1;
    BEGIN
        for r in q1(p_user) loop
            if r.stage_id = 1 then 
                rating := rating + round(r.tcis / r.snt, 1);
            elsif r.stage_id = 2 then
                rating := rating + round(r.tcis / r.snt, 1);
            elsif r.stage_id = 3 then
                rating := rating + (round(r.tcis / r.snt, 1) * 3);
            elsif rating1 = 0 then
                rating1 := rating1 + (round(r.tcis / r.snt, 1) * 5);
            else
                rating2 := (round(r.tcis / r.snt, 1) * 5);
                i := i + 1;
                rating1 := round( round(rating1 + rating2 / i) / 5, 1 ) * 5;
            end if;
        end loop;
        if rating is null and rating1 is null then
            p_current_rating := 0;
            p_max_rating := 0;
            p_string := 'N/A';
        elsif rating is null and rating1 is not null then
            p_current_rating := rating1;
            p_max_rating := 5;
            p_string := to_char(rating1)||'/'||to_char(p_max_rating);
        elsif rating is not null and rating1 is null then
            p_current_rating := rating;
            p_max_rating := 5;
            p_string := to_char(rating1)||'/'||to_char(p_max_rating);
        else
            p_current_rating := greatest(rating, rating1);
            p_max_rating := 5;
            p_string := to_char(p_current_rating)||'/'||to_char(p_max_rating);
        end if;
    END;

    PROCEDURE UPDATE_CONNECT_STAGE_TASK(
        p_task in NUMBER
        , p_stage in NUMBER
        , p_start_date in VARCHAR2
        , p_end_date in VARCHAR2
        , p_error out VARCHAR2
    ) IS
        v_start_date DATE := to_date(p_start_date, 'YYYY-MM-DD');
        v_end_date DATE := to_date(p_end_date, 'YYYY-MM-DD');
    BEGIN
        UPDATE DIPLOM.TASK_RELATIONS
        SET START_DATE = v_start_date
            , END_DATE = v_end_date
        WHERE 1 = 1
            and TASK = p_task
            and STAGE = p_stage
        ;
        commit;
        exception when others then p_error := SQLERRM;
    END;

END fnd_tasks;