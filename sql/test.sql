set SERVEROUTPUT on;

select chr(39) from dual;

declare
begin
    dbms_output.put_line('Hi');
end;

/* Добавить роли */
declare
begin
    diplom.fnd_user.add_user_type('Администратор');
    diplom.fnd_user.add_user_type('Руководитель');
    diplom.fnd_user.add_user_type('Студент');
end;

/* Добавить пользователя */
declare
    p_error VARCHAR2(100);
begin
    diplom.FND_USER.ADD_USER(
        P_LOGIN  => 'system',
        P_PASSWORD  => '321Start',
        P_USER_TYPE => 1,
        P_USERNAME  => 'System Account',
        P_EMAIL  => 'sys@gmail.com'
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;

    p_error := null;
    diplom.FND_USER.ADD_USER(
        P_LOGIN  => 'dashinmu',
        P_PASSWORD  => 'dashinmu23',
        P_USER_TYPE => 2,
        P_USERNAME  => 'Daniil Dashinmu',
        P_EMAIL  => 'dashinmu@gmail.com',
        P_PHONE  => '+7-919-446-04-27'
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;

    p_error := null;
    diplom.FND_USER.ADD_USER(
        P_LOGIN  => 'myasnikova_av',
        P_PASSWORD  => '321Student',
        P_USER_TYPE => 3,
        P_USERNAME  => 'Аврора Мясникова',
        P_EMAIL  => 'aurora.mv_20@gmail.com',
        P_PHONE  => '+7-919-534-14-90'
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;

    p_error := null;
    diplom.FND_USER.ADD_USER(
        P_LOGIN  => 'Solovyov_DM',
        P_PASSWORD  => '321student',
        P_USER_TYPE => 3,
        P_USERNAME  => 'Дмитрий Соловьёв',
        P_EMAIL  => 'dm.solovey@gmail.com',
        P_PHONE  => '+7-912-101-01-48',
        P_END_DATE => to_date('27062024','ddmmyyyy')
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

/* Проверить пользователя */
declare
    p_error NUMBER(1);
begin
    DIPLOM.FND_USER.VALID_USER(P_LOGIN => 'dashinmu', P_PASSWORD => 'dashinmu23', p_user_type => p_error);
    if p_error = 0 then DBMS_OUTPUT.PUT_LINE('Wrong data info'); end if;
end;

/* Проверить права пользователя */
declare
begin
    if DIPLOM.FND_USER.IS_ADMIN(P_USER => 'dashinmu')
        then DBMS_OUTPUT.PUT_LINE('Права администратора');
        else DBMS_OUTPUT.PUT_LINE('Не является администратором');
    end if;
end;

/* Связать пользователей */
declare
    p_error VARCHAR2(20);
begin
    DIPLOM.FND_USER.ADD_RELATIONSHIPS(
        P_PARENT  => 'dashinmu',
        P_CHILD  => 'myasnikova_av',
        P_ERROR  => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    p_error := null;
    DIPLOM.FND_USER.ADD_RELATIONSHIPS(
        P_PARENT  => 'dashinmu',
        P_CHILD  => 'Solovyov_DM',
        P_ERROR  => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

/* Личная информация */
select * from DIPLOM.PERSONAL_INFO;

select 1 from dual where sysdate >= to_date('08042024','ddmmyyyy') and sysdate <= to_date(1,'J'); --прикол с датой

/* Добавить этапы */
declare
    p_error VARCHAR2(200);
begin
    DIPLOM.fnd_tasks.add_stage(
        p_meaning => 'Ознакомление с организацией'
        , p_stage_name => 'Этап №1'
        , p_author => 1
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    p_error := null;
    DIPLOM.fnd_tasks.add_stage(
        p_meaning => 'Введение в разработку на PL/SQL'
        , p_author =>  1
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

select * from DIPLOM.STAGES;

/* Связать этапы */
declare
    p_error VARCHAR2(200);
begin
    DIPLOM.fnd_tasks.connect_stage(
        p_parent => 1
        , p_child => 2
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

declare
    p_error VARCHAR2(200);
begin
    DIPLOM.fnd_tasks.connect_stage(
        p_parent => 1
        , p_child => 3
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

/* Создать типы заданий */
declare
begin
    diplom.fnd_tasks.add_task_type('Подтверждение');
    diplom.fnd_tasks.add_task_type('Варианты');
    diplom.fnd_tasks.add_task_type('Код');
    diplom.fnd_tasks.add_task_type('Свободный');
end;

/* Создать задание */
declare
    p_id_task NUMBER(4);
    p_error VARCHAR2(200);
begin
    DIPLOM.fnd_tasks.add_task(
        p_meaning => 'Задание 1: Ознакомление с документацией'
        , p_desc => 'Требуется ознакомиться с документацией...'
        , p_type => 1
        , p_author => 1 
        , p_id_task => p_id_task
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    p_error := null;
    DIPLOM.fnd_tasks.add_task(
        p_meaning => 'Задание 2: Вопросы по документации'
        , p_desc => 'Выберите из предложенных ответов верные...'
        , p_type => 2
        , p_author => 1 
        , p_id_task => p_id_task
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    p_error := null;
    DIPLOM.fnd_tasks.add_task(
        p_meaning => 'Задание 1: Основы запросов PL/SQL'
        , p_desc => 'Используйте SELECT [column_name] FROM [table_name] WHERE [condition]...'
        , p_type => 3
        , p_author => 1
        , p_id_task => p_id_task
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    p_error := null;
    DIPLOM.fnd_tasks.add_task(
        p_meaning => 'Задание 2: Основы запросов PL/SQL'
        , p_desc => 'Доработать прошлый запрос добавив ограничение по строкам'
        , p_type => 3
        , p_author => 1 
        , p_id_task => p_id_task
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    p_error := null;
    DIPLOM.fnd_tasks.add_task(
        p_meaning => 'Задание 3: Основы запросов PL/SQL'
        , p_desc => 'Выберите верные суждения...'
        , p_type => 2
        , p_author => 1 
        , p_id_task => p_id_task
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

/* Создать задание */
declare
    p_id_task NUMBER(4);
    p_error VARCHAR2(200);
begin
    DIPLOM.fnd_tasks.add_task(
        p_meaning => 'Задание 3: Основы запросов PL/SQL'
        , p_desc => 'Напишите запрос...'
        , p_type => 3
        , p_author => 1 
        , p_id_task => p_id_task
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

/* Связать задания */
declare
    p_error VARCHAR2(200);
begin
    diplom.fnd_tasks.connect_task(
        p_stage => 1
        , p_task => 1
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    p_error := null;
    diplom.fnd_tasks.connect_task(
        p_stage => 1
        , p_task => 2
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    p_error := null;
    diplom.fnd_tasks.connect_task(
        p_stage => 2
        , p_task => 3
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    p_error := null;
    diplom.fnd_tasks.connect_task(
        p_stage => 2
        , p_task => 4
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    p_error := null;
    diplom.fnd_tasks.connect_task(
        p_stage => 2
        , p_task => 5
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    p_error := null;
    ------------------------------------------------------------------
    diplom.fnd_tasks.connect_task(
        p_stage => 1
        , p_task => 1
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    p_error := null;
    diplom.fnd_tasks.connect_task(
        p_stage => 3
        , p_task => 1
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    p_error := null;
    diplom.fnd_tasks.connect_task(
        p_stage => 1
        , p_task => 6
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

/* Связать задания */
declare
    p_error VARCHAR2(200);
begin
    diplom.fnd_tasks.connect_task(
        p_stage => 2
        , p_task => 21
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    p_error := null;
end;


/* Создать ответы руководитель*/
declare
    p_error VARCHAR2(200);
begin
    diplom.fnd_tasks.add_answer(
        p_user => 1
        , p_answer => '1'
        , p_task => 1
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    diplom.fnd_tasks.add_answer(
        p_user => 1
        , p_answer => '2 4'
        , p_task => 2
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    diplom.fnd_tasks.add_answer(
        p_user => 1
        , p_answer => 'SELECT trunc(sysdate) FROM dual'
        , p_task => 3
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    diplom.fnd_tasks.add_answer(
        p_user => 1
        , p_answer => 'SELECT trunc(sysdate) as "sdb" FROM dual'
        , p_task => 4
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    diplom.fnd_tasks.add_answer(
        p_user => 1
        , p_answer => '  1'
        , p_task => 5
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

/* Создать ответы руководитель*/
declare
    p_error VARCHAR2(200);
begin
    diplom.fnd_tasks.add_answer(
        p_user => 1
        , p_answer => 'SELECT * FROM DIPLOM.users WHERE type = 1'
        , p_task => 4
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

/* Выдать этапы студентам */
declare
    p_error VARCHAR2(200);
begin
    DIPLOM.FND_TASKS.give_stage(
        p_user => 1
        , p_stage => 1
        , p_student => 3
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;
declare
    p_error VARCHAR2(200);
begin
    DIPLOM.FND_TASKS.give_stage(
        p_user => 1
        , p_stage => 2
        , p_student => 3
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

/* Создать ответы студент*/
declare
    p_error VARCHAR2(200);
begin
    diplom.fnd_tasks.add_answer(
        p_user => 3
        , p_answer => '1'
        , p_task => 1
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE('1 - '||p_error); end if;
    p_error := null;
    diplom.fnd_tasks.add_answer(
        p_user => 3
        , p_answer => '2 4'
        , p_task => 2
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE('2 - '||p_error); end if;
    p_error := null;
    diplom.fnd_tasks.add_answer(
        p_user => 3
        , p_answer => 'SELECT trunc(sysdate) FROM dual'
        , p_task => 3
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE('3 - '||p_error); end if;
    p_error := null;
    diplom.fnd_tasks.add_answer(
        p_user => 3
        , p_answer => 'SELECT trunc(sysdate) sd FROM dual'
        , p_task => 4
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE('4 - '||p_error); end if;
    p_error := null;
    diplom.fnd_tasks.add_answer(
        p_user => 3
        , p_answer => '1 4'
        , p_task => 5
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE('5 - '||p_error); end if;
end;

/* Создать ответы студент*/
declare
    p_error VARCHAR2(200);
begin
    diplom.fnd_tasks.add_answer(
        p_user => 3
        , p_answer => '2 4 5'
        , p_task => 2
        , p_error => p_error
    );
end;

/* Создать ответы студент*/
declare
    p_error VARCHAR2(200);
begin
    if p_error is not null then DBMS_OUTPUT.PUT_LINE('2 - '||p_error); end if;
    p_error := null;
    diplom.fnd_tasks.add_answer(
        p_user => 3
        , p_answer => 'SELECT trunc(sysdate) FROM dual'
        , p_task => 3
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE('3 - '||p_error); end if;
    p_error := null;
    diplom.fnd_tasks.add_answer(
        p_user => 3
        , p_answer => 'SELECT trunc(sysdate) sd FROM dual'
        , p_task => 4
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE('4 - '||p_error); end if;
    p_error := null;
    diplom.fnd_tasks.add_answer(
        p_user => 3
        , p_answer => '1 4'
        , p_task => 5
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE('5 - '||p_error); end if;
end;

declare
    p_error VARCHAR2(400);
begin
    diplom.fnd_tasks.add_answer(
        p_user => 3
        , p_answer => 'SELECT trunc(sysdate) sd FROM dual'
        , p_task => 4
        , p_error => p_error
    );
     if p_error is not null then DBMS_OUTPUT.PUT_LINE('4 - '||p_error); end if;
end;

update diplom.answer set answer = upper('SELECT trunc(sysdate) "sdb" FROM dual') where id = 4;
select * from diplom.answer;
select * from diplom.tasks;
select * from diplom.TASK_TYPES;

select
    *
from
    DIPLOM.answer
where 1 = 1
    and primary = 'Y'
    and task = 4
;

DELETE FROM DIPLOM.ANSWER where ID = 103;



--Проверка работы DBMS_SQL (СЛОЖНЫЙ, НО НАДЁЖНЫЙ!)
declare
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

    wrong_answer exception;

    i integer; --столбцы
    j integer; --номер строки
    res NUMBER(1) := 1; --соответствует верному результату
begin
    cursor_tutor := 'SELECT meaning FROM fnd_lookup_values WHERE rownum < 5 and LOOKUP_TYPE like ''CONTACT'' ORDER BY 1';
    cursor_student := 'SELECT meaning FROM fnd_lookup_values WHERE rownum < 5 and LOOKUP_TYPE like ''CONTACT'' ORDER BY 1 DESC';

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
            DBMS_OUTPUT.PUT_LINE(v_cols_tutor(i).col_type);
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
                    /* ELSIF v_cols_tutor(i).col_type in (181) then --IN TIMESTAMP WITH TIME ZONE
                        dbms_sql.COLUMN_VALUE(v_cur_tutor_id, i, v_res_tutor_char);
                        dbms_sql.COLUMN_VALUE(v_cur_student_id, i, v_res_student_char);
                    ELSIF v_cols_tutor(i).col_type in (231) then --IN TIMESTAMP WITH LOCAL TIME ZONE
                        dbms_sql.COLUMN_VALUE(v_cur_tutor_id, i, v_res_tutor_char);
                        dbms_sql.COLUMN_VALUE(v_cur_student_id, i, v_res_student_char); */
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

    DBMS_OUTPUT.PUT_LINE('Результат сравнения = '||res);
    --хоть одна ошибка попадаем сюда
    exception 
        when wrong_answer then 
            DBMS_OUTPUT.PUT_LINE('Ответ неверный прерван где-то при расчёте');
            dbms_sql.CLOSE_CURSOR(v_cur_tutor_id); --закрыть курсоры
            dbms_sql.CLOSE_CURSOR(v_cur_student_id);
        when others then
            if dbms_sql.IS_OPEN(v_cur_tutor_id) then
                dbms_sql.CLOSE_CURSOR(v_cur_tutor_id); --закрыть курсоры
            end if;
            if dbms_sql.IS_OPEN(v_cur_student_id) then
                dbms_sql.CLOSE_CURSOR(v_cur_student_id);
            end if;
            DBMS_OUTPUT.PUT_LINE('ERROR: Ошибка в теле процедуры - '||SQLERRM);
end;