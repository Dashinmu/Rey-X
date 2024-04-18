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
        , p_error out VARCHAR2
    ) RETURN NUMBER;

    --Выдать этап студенту
    PROCEDURE give_stage(
        p_user in NUMBER
        , p_stage in NUMBER
        , p_student in NUMBER
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
        elsif p_task_type = 3 then res := upper(replace(trim(p_answer), chr(39), ''''));
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
        i integer; --столбцы
        j integer; --номер строки
        res NUMBER(1) := 1; --соответствует верному результату
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
            then raise wrong_answer; --выходим если нет, дальше проверять нет смысла
        end if;

        for i in 1 .. v_col_tutor_cnt loop
            if v_cols_tutor(i).col_name <> v_cols_student(i).col_name then -- снимаем флаг если наименования столбцов разняться
                raise wrong_answer;
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
                    raise wrong_answer;
                end if;
            else --проверить количество строк в курсоре студента и выйти
                j := DBMS_SQL.LAST_ROW_COUNT;
                if j <> j + dbms_sql.FETCH_ROWS(v_cur_student_id)
                    then raise wrong_answer;
                end if;
                exit;
            end if;
        end loop;

        dbms_sql.CLOSE_CURSOR(v_cur_tutor_id); --закрыть курсоры
        dbms_sql.CLOSE_CURSOR(v_cur_student_id);

        return res;
        --хоть одна ошибка попадаем сюда
        exception 
            when wrong_answer then 
                res := 0;
                dbms_sql.CLOSE_CURSOR(v_cur_tutor_id); --закрыть курсоры
                dbms_sql.CLOSE_CURSOR(v_cur_student_id);
                return res;
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

END fnd_tasks;