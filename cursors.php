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
                    , MAX(LAST_DATE)
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
                ORDER BY
                    8 DESC
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

    $get_all_students_history = "
        SELECT
            ppi.STUDENT_ID
            , ppi.STUDENT_NAME
            , ppi.STAGE_ID
            , ppi.STAGE_NAME
            , ppi.TASK_ID
            , ppi.TASK_NUM
            , ppi.TASK_NAME
            , a.ANSWER
            , a.RATING
            , to_char(a.CREATION_DATE, 'dd.mm.yyyy hh24:mi:ss') as CREATION_DATE
            , to_char(ppi.FIRST_TRUE_ANSWER_DATE, 'dd.mm.yyyy hh24:mi:ss') as FIRST_TRUE_ANSWER_DATE
            , pr.START_DATE
            , pr.END_DATE
            , case when pr.END_DATE < trunc(sysdate) then 'inactive' end as STUDENT_STATUS
            , u.NAME
            , ppi2.NUM_STAGES_ASSIGNED
            , ppi2.NUM_ALL_COMPLETE_TASKS
            , ppi2.NUM_ALL_ANSWER_TASKS
            , ppi2.NUM_ALL_TASKS_STAGES
        FROM
            DIPLOM.PRACTICE_PROGRESS_INFO ppi
            join DIPLOM.PERSON_RELATIONS pr
                on pr.CHILD = PPI.STUDENT_ID
                and pr.END_DATE > trunc(sysdate - 62)
                and pr.PARENT = :p_user
            join DIPLOM.USERS u
                on ppi.STUDENT_ID = u.ID
            left join DIPLOM.ANSWER a
                on a.TASK = ppi.TASK_ID
                and a.PERSON = ppi.STUDENT_ID
            left join (
                SELECT
                    STUDENT_ID
                    , count(STAGE_ID) as NUM_STAGES_ASSIGNED
                    , sum(TASK_COMPLETE_IN_STAGE) as NUM_ALL_COMPLETE_TASKS
                    , sum(TASK_ANSWER_IN_STAGE) as NUM_ALL_ANSWER_TASKS
                    , sum(STAGE_NUM_TASKS) as NUM_ALL_TASKS_STAGES
                FROM
                    (
                        SELECT
                            STUDENT_ID
                            , STAGE_ID
                            , TASK_COMPLETE_IN_STAGE
                            , TASK_ANSWER_IN_STAGE
                            , STAGE_NUM_TASKS
                            , MAX(LAST_DATE)
                        FROM
                            DIPLOM.PRACTICE_PROGRESS_INFO
                        WHERE 1 = 1
                        GROUP BY
                            STUDENT_ID
                            , STAGE_ID
                            , TASK_COMPLETE_IN_STAGE
                            , TASK_ANSWER_IN_STAGE
                            , STAGE_NUM_TASKS
                    )
                WHERE 1 = 1
                GROUP BY
                    STUDENT_ID
            ) ppi2
                on ppi2.STUDENT_ID = ppi.STUDENT_ID
        WHERE 1 = 1
        ORDER BY
            14 desc, 1 desc, 3 desc, 6 desc, 10 desc
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
            , q.STUDENT_ID
        FROM
            (
                SELECT
                    u.ID STUDENT_ID
                    , u.NAME STUDENT_NAME
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
                    u.ID
                    , u.NAME
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
            , q.STUDENT_ID
    ";

    $get_all_student = "
        SELECT
            q.STUDENT_NAME
            , q.START_DATE
            , q.END_DATE
            , q.ID
            , case when q.END_DATE < trunc(sysdate)
                then 'inactive'
            end STATUS
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
            , case when q.END_DATE < trunc(sysdate)
                then 'INACTIVE'
                else 'ACTIVE'
            end
        ORDER BY
            5 desc, 2
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
        BEGIN 
            diplom.fnd_user.change_password(
                p_login => :p_login
                , p_password_old => :p_password_old
                , p_password_new => :p_password_new
                , p_error => :p_error
            ); 
        END;
    ";

    $create_user = "
        BEGIN
            diplom.fnd_user.add_user(
                p_login => :p_login
                , p_password => :p_password
                , p_user_type => :p_user_type
                , p_username => :p_username
                , p_email => :p_email
                , p_phone => :p_phone
                , p_start_date => :p_start_date
                , p_end_date => :p_end_date
                , p_user => :p_user
                , p_give_stage => :p_stage
                , p_error => :p_error
            );
        END;
    ";

    $get_all_tasks_info = "
        SELECT
            *
        FROM
            DIPLOM.ALL_TASKS
        WHERE 1 = 1
        ORDER BY
            11 desc, 1
    ";

    $get_all_tasks_types = "
        SELECT * FROM DIPLOM.TASK_TYPES
    ";

    $add_task = "
        BEGIN
            DIPLOM.FND_TASKS.ADD_TASK(
                p_meaning => :p_meaning
                , p_desc => :p_desc
                , p_type => :p_type
                , p_author => :p_author
                , p_id_task => :p_id_task
                , p_error => :p_error
            );
        END;
    ";

    $add_answer = "
        BEGIN
            DIPLOM.FND_TASKS.ADD_ANSWER(
                p_user => :p_user
                , p_answer => :p_answer
                , p_task => :p_task
                , p_error => :p_error
                , p_status => :p_status
            );
        END;
    ";

    $get_all_stages_info = "
        SELECT * FROM DIPLOM.TASKS_INFO ORDER BY 15 desc, 1
    ";

    $get_all_stages_info_orig = "
        SELECT * FROM DIPLOM.STAGES
    ";

    $create_stage = "
        BEGIN
            DIPLOM.FND_TASKS.ADD_STAGE(
                p_meaning => :p_meaning
                , p_stage_name => :p_stage_name
                , p_author => :p_author
                , p_stage_id => :p_stage_id
                , p_error => :p_error
            );
        END;
    ";

    $connect_stage = "
        BEGIN
            DIPLOM.fnd_tasks.connect_stage(
                p_parent => :p_parent
                , p_child => :p_child
                , p_error => :p_error
            );
        END;
    ";

    $connect_task = "
        BEGIN
            DIPLOM.fnd_tasks.connect_task(
                p_stage => :p_stage
                , p_task => :p_task
                , p_num_task => :p_num_task
                , p_start_date => :p_start_date
                , p_end_date => :p_end_date
                , p_error => :p_error
            );
        END;
    ";

    $update_user = "
        BEGIN
            DIPLOM.FND_USER.update_user(
                p_tutor => :p_tutor
                , p_login => :p_login
                , p_password => :p_password
                , p_username => :p_username
                , p_email => :p_email
                , p_phone => :p_phone
                , p_start_date => :p_start_date
                , p_end_date => :p_end_date
                , p_user => :p_user
                , p_error => :p_error
            );
        END;
    ";

    $update_task = "
        BEGIN
            DIPLOM.FND_TASKS.update_task(
                p_task_id => :p_task_id
                , p_task_meaning => :p_task_meaning
                , p_task_descrip => :p_task_descrip
                , p_task_type_id => :p_task_type_id
                , p_task_start_date => :p_task_start_date
                , p_task_end_date => :p_task_end_date
                , p_task_answer => :p_task_answer
                , p_user => :p_user
                , p_error => :p_error
            );
        END;
    ";
    
?>