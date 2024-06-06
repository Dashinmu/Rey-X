<?php
    $get_student_last_stages = "
        SELECT
            *
        FROM
            (
                SELECT
                    STAGE_ID
                    , STAGE_NAME
                    , STAGE_MEANING
                    , STAGE_NUM_TASKS
                    , TASK_COMPLETE_IN_STAGE
                    , TASK_ANSWER_IN_STAGE
                    , STAGE_ASSIGNED_DATE
                    , LAST_DATE
                FROM
                    DIPLOM.PRACTICE_PROGRESS_INFO
                WHERE 1 = 1
                    and STUDENT_ID = :student_id
                    and LAST_DATE is not null
                GROUP BY
                    STAGE_ID
                    , STAGE_NAME
                    , STAGE_MEANING
                    , STAGE_NUM_TASKS
                    , TASK_COMPLETE_IN_STAGE
                    , TASK_ANSWER_IN_STAGE
                    , STAGE_ASSIGNED_DATE
                    , LAST_DATE
                ORDER BY
                    LAST_DATE DESC
            )
        WHERE 1 = 1
            and ROWNUM <= 2
    ";

    $get_student_last_answer = "
        SELECT
            *
        FROM 
            (
                SELECT
                    STAGE_ID
                    , STAGE_NAME
                    , TASK_ID
                    , TASK_NUM
                    , TASK_NAME
                    , FIRST_TRUE_ANSWER
                    , LAST_RATING
                    , LAST_ANSWER
                    , STUDENT_ID
                    , LAST_DATE
                FROM
                    DIPLOM.PRACTICE_PROGRESS_INFO
                WHERE 1 = 1
                    and STUDENT_ID = :student_id
                ORDER BY
                    LAST_DATE DESC
            )
        WHERE 1 = 1
            and ROWNUM <= 7
    ";

    $get_student_activity = "
        SELECT
            *
        FROM 
            (
                SELECT
                    ppi.STAGE_ID
                    , ppi.STAGE_NAME
                    , ppi.TASK_ID
                    , ppi.TASK_NUM
                    , ppi.TASK_NAME
                    , a.ANSWER
                    , a.RATING
                    , ppi.STUDENT_ID
                    , u.NAME STUDENT_NAME
                    , to_char(a.CREATION_DATE, 'dd.mm.yyyy hh24:mi:ss') LAST_DATE
                FROM
                    DIPLOM.PRACTICE_PROGRESS_INFO ppi
                    join DIPLOM.PERSON_RELATIONS pr
                        on ppi.STUDENT_ID = pr.CHILD
                        and trunc(sysdate) between pr.START_DATE and pr.END_DATE
                        and pr.PARENT = :user_id
                    join DIPLOM.USERS u
                        on u.ID = ppi.STUDENT_ID
                        and trunc(sysdate) between u.START_DATE and u.END_DATE
                    join DIPLOM.ANSWER a
                        on a.PERSON = ppi.STUDENT_ID
                        and a.TASK = ppi.TASK_ID
                WHERE 1 = 1
                ORDER BY
                    a.CREATION_DATE DESC
            )
        WHERE 1 = 1
            and ROWNUM <= 5
    ";

    $get_active_student = "
        SELECT
            q.STUDENT_NAME
            , q.START_DATE
            , q.END_DATE
            , q.ID
            , count(q.STAGE_ID) STAGE_CNT
            , sum(q.STAGE_NUM_TASKS) STAGE_TASKS
            , sum(q.TASK_COMPLETE_IN_STAGE) STAGE_TASKS_COMPLETE
        FROM
            (
                SELECT
                    u.NAME STUDENT_NAME
                    , u.START_DATE
                    , u.END_DATE
                    , u.ID
                    , ppi.STAGE_ID
                    , ppi.STAGE_NUM_TASKS
                    , ppi.TASK_COMPLETE_IN_STAGE
                FROM
                    DIPLOM.USERS u
                    join DIPLOM.PERSON_RELATIONS pr
                        on pr.CHILD = u.ID
                        and pr.PARENT = :user_id
                        and trunc(sysdate) between pr.START_DATE and pr.END_DATE
                    join DIPLOM.PRACTICE_PROGRESS_INFO ppi
                        on ppi.STUDENT_ID = u.ID
                WHERE 1 = 1
                GROUP BY
                    u.NAME
                    , u.START_DATE
                    , u.END_DATE
                    , u.ID
                    , ppi.STAGE_ID
                    , ppi.STAGE_NUM_TASKS
                    , ppi.TASK_COMPLETE_IN_STAGE   
            ) q
        WHERE 1 = 1
        GROUP BY
            q.STUDENT_NAME
            , q.START_DATE
            , q.END_DATE
            , q.ID
    ";

    $get_student_all_stage = "
        SELECT
            *
        FROM
            DIPLOM.PRACTICE_PROGRESS_INFO
        WHERE 1 = 1
            and STUDENT_ID = :student_id
        ORDER BY
            STAGE_ASSIGNED_DATE
            , STAGE_NAME
            , TASK_NUM DESC
    ";

    $change_password = "
        BEGIN diplom.fnd_user.change_password(
            p_login => :p_login
            , p_password_old => :p_password_old
            , p_password_new => :p_password_new
            , p_error => :p_error); 
        END;
    ";
?>