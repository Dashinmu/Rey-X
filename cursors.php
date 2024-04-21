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
?>