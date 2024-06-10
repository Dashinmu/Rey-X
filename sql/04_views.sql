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

--Представление задания от этапов
CREATE OR REPLACE VIEW DIPLOM.TASKS_INFO AS
    SELECT
        s.ID as STAGE_ID
        , s.STAGE_NAME as STAGE_NAME
        , s.MEANING as STAGE_MEANING
        , u.LOGIN as STAGE_AUTHOR_NAME
        , to_char(s.INACTIVE_DATE, 'dd.mm.yyyy') as STAGE_INACTIVE_DATE
        , s.TIME_PERIOD as STAGE_TIME_PERIOD --нужен ли?
        , t.ID as TASK_ID
        , tt.ID as TASK_TYPE_ID
        , tt.MEANING as TASK_TYPE
        , t.MEANING as TASK_NAME
        , st.NUM_TASK as TASK_NUM_IN_STAGE
        , t.DESCRIP as TASK_DESC
        , to_char(t.INACTIVE_DATE, 'dd.mm.yyyy') as TASK_INACTIVE_DATE
        , a.ANSWER as TRUE_ANSWER
        , case when s.INACTIVE_DATE < trunc(sysdate) then 'inactive' end STAGE_STATUS
        , max(st.NUM_TASK) as STAGE_NUM_TASKS
        , listagg(s2.STAGE_NAME, ';') WITHIN GROUP (ORDER BY s2.ID desc) as LINKS_TO_STAGES
    FROM
        DIPLOM.STAGES s
        join DIPLOM.USERS u
            on u.ID = s.CREATED_BY
        left join DIPLOM.TASK_RELATIONS st
            on st.STAGE = s.ID
            and s.INACTIVE_DATE <= st.END_DATE
        left join DIPLOM.TASKS t
            on st.TASK = t.ID
            and t.INACTIVE_DATE <= st.END_DATE
        left join DIPLOM.TASK_TYPES tt
            on tt.id = t.TYPE
        left join DIPLOM.ANSWER a
            on a.TASK = t.ID
            and a.CREATION_DATE BETWEEN t.CREATION_DATE and t.INACTIVE_DATE
            and a.PRIMARY like 'Y'
        left join DIPLOM.STAGE_RELATIONS sr
            on sr.CHILD = s.ID
            and trunc(sysdate) between sr.START_DATE and sr.END_DATE
        left join DIPLOM.STAGES s2
            on s2.ID = sr.PARENT
    WHERE 1 = 1
    GROUP BY
        s.ID
        , s.STAGE_NAME
        , s.MEANING
        , u.LOGIN
        , to_char(s.INACTIVE_DATE, 'dd.mm.yyyy')
        , s.TIME_PERIOD
        , t.ID
        , tt.ID
        , tt.MEANING
        , t.MEANING
        , st.NUM_TASK
        , t.DESCRIP
        , to_char(t.INACTIVE_DATE, 'dd.mm.yyyy')
        , a.ANSWER
        , case when s.INACTIVE_DATE < trunc(sysdate) then 'inactive' end
    ORDER BY
        1 desc, 11 desc
;

--Представление заданий
CREATE OR REPLACE VIEW DIPLOM.ALL_TASKS AS
    SELECT
        t.ID as TASK_ID
        , t.TYPE as TASK_TYPE_ID
        , tt.MEANING as TASK_TYPE
        , t.MEANING as TASK_MEANING
        , t.DESCRIP as TASK_DESCRIPTION
        , t.CREATION_DATE as TASK_CREATION_DATE
        , t.INACTIVE_DATE as TASK_INACTIVE_DATE
        , t.CREATED_BY as AUTHOR_ID
        , u.LOGIN as AUTHOR
        , a.ANSWER as ANSWER
        , case when t.INACTIVE_DATE < trunc(sysdate) then 'inactive' end as TASK_INACTIVE_STATUS
        , LISTAGG(s.STAGE_NAME, ';') WITHIN GROUP (order by s.ID desc) as LINKS_TO_STAGES
    FROM
        DIPLOM.TASKS t
        join DIPLOM.TASK_TYPES tt
            on t.TYPE = tt.ID
        join DIPLOM.USERS u
            on t.CREATED_BY = u.ID
        join DIPLOM.ANSWER a
            on a.TASK = t.ID
            and a.CREATION_DATE BETWEEN trunc(t.CREATION_DATE) and trunc(t.INACTIVE_DATE)
            and a.PRIMARY like 'Y'
        left join DIPLOM.TASK_RELATIONS tr
            on t.ID = tr.TASK
            and t.INACTIVE_DATE <= tr.END_DATE
        left join DIPLOM.STAGES s
            on s.ID = tr.STAGE
            and s.INACTIVE_DATE <= tr.END_DATE
    WHERE 1 = 1
    GROUP BY
        t.ID
        , t."TYPE"
        , tt.MEANING
        , t.MEANING
        , t.DESCRIP
        , t.CREATION_DATE
        , t.INACTIVE_DATE
        , t.CREATED_BY
        , u.LOGIN
        , a.ANSWER
        , case when t.INACTIVE_DATE < trunc(sysdate) then 'inactive' end
    ORDER BY
        1 desc
;

--Представление прогресса выполнения заданий студентами #1
CREATE OR REPLACE VIEW DIPLOM.PRACTICE_PROGRESS_INFO AS
    SELECT
        student.ID as STUDENT_ID
        , student.LOGIN as STUDENT_NAME
        , s.ID as STAGE_ID
        , s.STAGE_NAME as STAGE_NAME
        , s.MEANING as STAGE_MEANING
        , DIPLOM.FND_TASKS.GET_STAGE_TASKS(
            p_stage => s.ID
            , p_date => student.START_DATE
        ) as STAGE_NUM_TASKS
        , to_char(gs.ASSIGNED_DATE, 'dd.mm.yyyy hh24:mm') as STAGE_ASSIGNED_DATE
        , u.LOGIN as ASSIGNED_BY
        , null as TO_TASK
        , t.ID as TASK_ID
        , tr.NUM_TASK as TASK_NUM
        , t.MEANING as TASK_NAME
        , t.DESCRIP as TASK_DESC
        , true_a.ANSWER as FIRST_TRUE_ANSWER
        , true_a.CREATION_DATE as FIRST_TRUE_ANSWER_DATE
        , last_a.RATING as LAST_RATING
        , last_a.ANSWER as LAST_ANSWER
        , last_a.CREATION_DATE as LAST_DATE
        , DIPLOM.FND_TASKS.GET_STUDENT_PROGRESS_STAGE(
            p_stage => s.ID
            , p_student => student.ID
        ) as TASK_COMPLETE_IN_STAGE
        , DIPLOM.FND_TASKS.GET_STUDENT_ALL_PROGRESS_STAGE(
            p_stage => s.ID
            , p_student => student.ID
        ) as TASK_ANSWER_IN_STAGE
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
        left join DIPLOM.ANSWER last_a
            on last_a.TASK = t.ID
            and student.ID = last_a.PERSON
            and last_a.ID = DIPLOM.FND_TASKS.GET_LAST_ANSWER_TIME(
                p_task => t.ID
                , p_student => student.ID
            )
        left join DIPLOM.ANSWER true_a
            on true_a.ID = DIPLOM.FND_TASKS.GET_STUDENT_TRUE_ANSWER(
                p_task => t.ID
                , p_student => student.ID
            )
    WHERE 1 = 1
        and student.TYPE not in (1, 2)
;