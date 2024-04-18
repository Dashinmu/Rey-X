--Представление личной информации
CREATE OR REPLACE VIEW DIPLOM.PERSONAL_INFO AS
    SELECT
        u.ID as USER_ID
        , u.NAME as USER_NAME
        , u.CONTACT_INFO1 as USER_MAIL
        , u.CONTACT_INFO2 as USER_PHONE
        , to_char(u.END_DATE, 'dd.mm.yyyy') as USER_INACTIVE_DATE
        , ut.MEANING as USER_TYPE
        , u.LOGIN as USER_LOGIN
    FROM
        DIPLOM.USERS u
        left join DIPLOM.USER_TYPE ut
            on u.type = ut.id
            and u.END_DATE between ut.START_DATE and ut.INACTIVE_DATE
    WHERE 1 = 1
;

--Представление задания
CREATE OR REPLACE VIEW DIPLOM.TASKS_INFO AS
    SELECT
        s.ID as STAGE_ID
        , s.STAGE_NAME as STAGE_NAME
        , s.MEANING as STAGE_MEANING
        , u.LOGIN as STAGE_AUTHOR_NAME
        , to_char(s.INACTIVE_DATE, 'dd.mm.yyyy') as STAGE_INACTIVE_DATE
        , s.TIME_PERIOD as STAGE_TIME_PERIOD --нужен ли?
        , t.ID as TASK_ID
        , tt.MEANING as TASK_TYPE
        , t.MEANING as TASK_NAME
        , st.NUM_TASK as TASK_NUM_IN_STAGE
        , t.DESCRIP as TASK_DESC
        , to_char(t.INACTIVE_DATE, 'dd.mm.yyyy') as TASK_INACTIVE_DATE
        , a.ANSWER as TRUE_ANSWER
    FROM
        DIPLOM.STAGES s
        join DIPLOM.USERS u
            on u.ID = s.CREATED_BY
        left join DIPLOM.TASK_RELATIONS st
            on st.STAGE = s.ID
            and s.INACTIVE_DATE >= st.END_DATE
        left join DIPLOM.TASKS t
            on st.TASK = t.ID
            and t.INACTIVE_DATE >= st.END_DATE
        left join DIPLOM.TASK_TYPES tt
            on tt.id = t.TYPE
        left join DIPLOM.ANSWER a
            on a.TASK = t.ID
            and a.CREATION_DATE BETWEEN t.CREATION_DATE and t.INACTIVE_DATE
            and a.PRIMARY like 'Y'
    WHERE 1 = 1
;

--Представление прогресса выполнения заданий студентами
CREATE OR REPLACE VIEW DIPLOM.PRACTICE_PROGRESS AS
    SELECT
        student.ID as STUDENT_ID
        , student.LOGIN as STUDENT_NAME
        , s.STAGE_NAME as STAGE_NAME
        , to_char(gs.ASSIGNED_DATE, 'dd.mm.yyyy') as ASSIGNED_DATE
        , u.LOGIN as ASSIGNED_BY
        , t.MEANING as TASK_NAME
        , tr.NUM_TASK as TASK_NUM
        , a.RATING
        , a.ANSWER
    FROM
        DIPLOM.USERS student
        left join DIPLOM.GIVE_STAGES gs
            on gs.STUDENT_ID = student.ID
        left join DIPLOM.USERS u
            on u.ID = gs.ASSIGNED_BY
        left join DIPLOM.STAGES s
            on s.ID = gs.STAGE
        left join DIPLOM.TASK_RELATIONS tr
            on tr.STAGE = gs.STAGE
        left join DIPLOM.TASKS t
            on t.ID = tr.TASK
        left join DIPLOM.ANSWER a
            on a.TASK = t.ID
            and student.ID = a.PERSON
    WHERE 1 = 1
        and student.TYPE not in (1, 2)
;