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
    p_error VARCHAR2(400);
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
end;

select * from DIPLOM.users;

select * from diplom.stages;

/* Создать типы заданий */
declare
begin
    diplom.fnd_tasks.add_task_type('Подтверждение');
    diplom.fnd_tasks.add_task_type('Варианты');
    diplom.fnd_tasks.add_task_type('Код');
    diplom.fnd_tasks.add_task_type('Свободный');
end;

SELECT * FROM DIPLOM.USERS;
UPDATE DIPLOM.USERS SET START_DATE = TO_DATE('01052024','ddmmyyyy') WHERE ID IN (1, 2, 3);
UPDATE DIPLOM.USERS SET PASSWORD = 'dashinmu23' WHERE ID = 2;
UPDATE DIPLOM.USERS SET START_DATE = TO_DATE('01062024','ddmmyyyy') WHERE ID IN (21, 22);

SELECT * FROM DIPLOM.PERSON_RELATIONS;

SELECT * FROM DIPLOM.STAGE_RELATIONS;
SELECT * FROM DIPLOM.STAGES;
SELECT SYSDATE FROM DUAL;
SELECT * FROM DIPLOM.TASK_RELATIONS;
UPDATE DIPLOM.TASK_RELATIONS SET START_DATE = sysdate;

select
    count(NUM_TASK) + 1
from
    diplom.task_relations
where 1 = 1
    and stage = 1
    and trunc(sysdate) between trunc(start_date) and trunc(end_date)
;

SELECT * FROM DIPLOM.ANSWER;

SELECT
    ppi.*
FROM
    DIPLOM.PRACTICE_PROGRESS_INFO ppi
WHERE 1 = 1
    and ppi.STUDENT_ID = 21
ORDER BY
    STAGE_ASSIGNED_DATE
    , STAGE_NAME
    , TASK_NUM DESC