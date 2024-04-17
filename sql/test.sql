set SERVEROUTPUT on;

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
        , p_answer => 'SELECT trunc(sysdate) as sdb FROM dual'
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
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    diplom.fnd_tasks.add_answer(
        p_user => 3
        , p_answer => '2 4'
        , p_task => 2
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    diplom.fnd_tasks.add_answer(
        p_user => 3
        , p_answer => 'SELECT trunc(sysdate) FROM dual'
        , p_task => 3
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    diplom.fnd_tasks.add_answer(
        p_user => 3
        , p_answer => 'SELECT trunc(sysdate) sd FROM dual'
        , p_task => 4
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
    diplom.fnd_tasks.add_answer(
        p_user => 3
        , p_answer => '1 2'
        , p_task => 5
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

--Проверка работы Static SQL
declare
    cursor_tutor VARCHAR2(4000);
        r_tutor SYS_REFCURSOR;
    cursor_student VARCHAR2(4000);
        r_student SYS_REFCURSOR;
    i NUMBER(3); --номер строки
    j NUMBER(3);
    res_tutor VARCHAR2(4000);
    res_student VARCHAR2(4000);
    flag boolean;
    res NUMBER(1);
begin
    cursor_tutor := 'SELECT trunc(sysdate) FROM dual';
    cursor_student := 'SELECT trunc(sysdate + 1) FROM dual';
    i := 0;
    j := 0;
    flag := true;
    res := 1;

    OPEN r_tutor FOR cursor_tutor;
    LOOP
        fetch r_tutor into res_tutor;
        exit when r_tutor%NOTFOUND;
        i := i + 1;

        OPEN r_student FOR cursor_student;
        LOOP
            fetch r_student into res_student;
            exit when r_student%NOTFOUND;
            j := j + 1;
            case when j = i then
                if res_student <> res_tutor 
                    then flag := false;
                end if;
                exit;
            end case;
        END LOOP;

        if flag 
            then null;
            else res := 0;
            exit;
        end if;

    END LOOP;
    CLOSE r_tutor;
    DBMS_OUTPUT.PUT_LINE('Результат сравнения '||res);
end;