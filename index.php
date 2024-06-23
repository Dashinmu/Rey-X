<?php
$page_title = "Авторизация"; // Устанавливаем заголовок страницы
require_once "./scripts/sessions.php";
require_once "header.php"; // Подключаем header.php
require_once "./scripts/db_connect.php"; // Подключаем файл с подключением к базе данных

$sql = "BEGIN diplom.fnd_user.get_personal_data(
    p_login => :userlogin
    , p_username => :user_fio
    , p_userphone => :user_phone
    , p_usermail => :user_mail
    , p_type_meaning => :user_type_mean
    , p_tutor_name => :tutor_fio
    , p_tutor_type => :tutor_type_mean
    , p_tutor_phone => :tutor_phone
); END;";

$stmt = oci_parse($conn, $sql);
oci_bind_by_name($stmt, ":userlogin", $userlogin);
oci_bind_by_name($stmt, ":user_fio", $user_fio, 50, SQLT_CHR);
oci_bind_by_name($stmt, ":user_phone", $user_phone, 50, SQLT_CHR);
oci_bind_by_name($stmt, ":user_mail", $user_mail, 50, SQLT_CHR);
oci_bind_by_name($stmt, ":user_type_mean", $user_type_mean, 50, SQLT_CHR);
oci_bind_by_name($stmt, ":tutor_fio", $tutor_fio, 50, SQLT_CHR);
oci_bind_by_name($stmt, ":tutor_type_mean", $tutor_type_mean, 50, SQLT_CHR);
oci_bind_by_name($stmt, ":tutor_phone", $tutor_phone, 50, SQLT_CHR);

if (oci_execute($stmt)) {
    if ($user_fio == '000') {
        $user_fio = 'НЕОПРЕДЕЛЁН';
        $user_type_mean = $user_fio;
    }
}
oci_free_statement($stmt);

require_once "cursors.php"; // Подключить запросы
require_once "menu.php"; // Подключить meny.php

if ($usertype != 1 && $usertype != 2) {
    
?>

<main>

    <!-- Личные данные и оценка -->
    <div class="personal-info">
        <div class = "personal-avatar">
            <img src="<?php if ($usertype == 3) { echo "img/student.png"; } else { echo "img/avatar.png"; } ?>" alt="User Avatar">
        </div>
        <div class = 'div-personal-name'>
            <span><?php echo $user_fio?></span>
        </div>
        <div class="tutor-detail">
            <span class="text"><b>Руководитель:</b> <?php echo $tutor_fio?></span>
            <span class="text"><b>Телефон:</b> <?php echo $tutor_phone?></span>
        </div>


        <!-- ДОРАБОТАТЬ -->
        <div class="user-rating">
            <span class="rating-label">Текущая оценка</span>
            <?php
                $get_rating_score = oci_parse($conn, "
                    BEGIN DIPLOM.FND_TASKS.GET_GENERAL_RATING(
                        p_user => :p_user
                        , p_current_rating => :p_current_rating
                        , p_max_rating => :p_max_rating
                        , p_string => :p_string
                    ); END;
                ");
                oci_bind_by_name($get_rating_score, ":p_user", $userid);
                oci_bind_by_name($get_rating_score, ":p_current_rating", $p_current_rating, 3, SQLT_INT);
                oci_bind_by_name($get_rating_score, ":p_max_rating", $p_max_rating, 3, SQLT_INT);
                oci_bind_by_name($get_rating_score, ":p_string", $p_string, 50, SQLT_CHR);
                if (oci_execute($get_rating_score)) {
            ?>
            <div class="rating-ellipse">
                <span class = "rating-ellipse3">
                    <span class = "rating-ellipse2"><?php echo $p_current_rating?></span>
                    /<?php echo $p_max_rating?>
                </span>
            </div>
            <?php
                }
                oci_free_statement($get_rating_score);
            ?>
        </div>


    </div>

    <!-- Этапы и история заданий -->
    <div class = "personal-history">
        <div class = "label">
            <span>Последние этапы практики</span>
        </div>

        <div class = "stages">
            <!-- Запрос на получение последних 2х этапов -->
            <?php 
                $stage_info = oci_parse($conn, $get_student_last_stages);
                oci_bind_by_name($stage_info, ":student_id", $userid);
                oci_execute($stage_info);
                while ( $row = oci_fetch_array($stage_info, OCI_RETURN_NULLS + OCI_ASSOC) ) {
                    if (!is_null($row['STAGE_ID'])) {
                        echo "
                            <div class = 'stage'>
                                <div class = 'stage-info'>
                                    <span class = 'stage-name'>".$row['STAGE_NAME']."</span>
                                    <span class = 'stage-desc'>".$row['STAGE_MEANING']."</span>
                                    <span class = 'stage-tasks'>Выполнено заданий: ".$row['TASK_ANSWER_IN_STAGE']."/".$row['STAGE_NUM_TASKS']."</span>
                                    <!-- <div class = 'stage-note'>
                                        <span class = 'note-text'>PL/SQL</span>
                                        <span class = 'note-text'>Новичок</span>
                                    </div> -->
                                </div>
                                <div class = 'stage-progress-circle' data-correct-task = '".$row['TASK_COMPLETE_IN_STAGE']."' data-all-task = '".$row['STAGE_NUM_TASKS']."'>
                                    <span class = 'progress-circle-left'>
                                        <span class = 'progress-circle'></span>
                                    </span>
                                    <span class = 'progress-circle-right'>
                                        <span class = 'progress-circle'></span>
                                    </span>
                                    <div class = 'stage-progress-value'>
                                        <span>".$row['TASK_COMPLETE_IN_STAGE']."<span class = 'stage-num-tasks'>/".$row['STAGE_NUM_TASKS']."</span></span>
                                    </div>
                                </div>
                            </div>
                        ";
                        unset($row);
                    }
                }
                oci_free_statement($stage_info);
            ?>
        </div>

        <div class = "label last">
            <span>Последние задания</span>
        </div>
        <div class = "tasks wrap">
            <!-- Запрос на получение последних 7ми заданий -->
            <?php 
                $tasks_info = oci_parse($conn, $get_student_last_answer);
                oci_bind_by_name($tasks_info, ":student_id", $userid);
                oci_execute($tasks_info);
                while ( $row = oci_fetch_array($tasks_info, OCI_RETURN_NULLS + OCI_ASSOC) ) {
                    if (!is_null($row['LAST_DATE'])) {
                        echo "
                        <div class = 'task-info "; if(is_null($row['FIRST_TRUE_ANSWER'])) {echo "wrong";} echo "'>
                            <span class = 'task-stage-name'>".$row['STAGE_NAME']."<span class = 'task-num'> - ".$row['TASK_NUM']."</span></span>
                            <span class = 'task-descrip'>".$row['TASK_NAME']."</span>
                            <span class = 'task-rating'>Статус:<span class = 'task-rating-score ";
                            if(is_null($row['FIRST_TRUE_ANSWER'])) {echo "wrong '> Не решено</span>";} else {echo "'> Решено</span>";} echo "
                                </span>
                        </div>
                        ";
                        unset($row);
                    }
                }
                oci_free_statement($tasks_info);
            ?>
        </div>
    </div>
</main>


<?php
} else {
?>
<main>
<!-- Личные данные -->
<div class="personal-info">
    <div class = "personal-avatar">
        <img src="<?php if ($usertype == 3) { echo "img/student.png"; } else { echo "img/avatar.png"; } ?>" alt="User Avatar">
    </div>
    <div class = 'div-personal-name'>
        <span><?php echo $user_fio?></span>
    </div>
    <div class="tutor-detail">
        <span class="text"><b>Телефон:</b> <?php echo $user_phone?></span>
        <span class="text"><b>Почта:</b> <?php echo $user_mail?></span>
    </div>
</div>

<!-- Этапы и история заданий -->
<div class = "students-activity">
    <div class = "label">
        <span>Активные практиканты</span>
    </div>

    <div class = "active-students">
        <!-- Запрос на получение последних 2х этапов -->
        <?php 
            $stage_info = oci_parse($conn, $get_active_student);
            oci_bind_by_name($stage_info, ":user_id", $userid);
            oci_execute($stage_info);
            while ( $row = oci_fetch_array($stage_info, OCI_RETURN_NULLS + OCI_ASSOC) ) {
        ?>
            <div class = "student-info">
                <div class = "student-info1">
                    <span class = "student-name"><?php echo $row['STUDENT_NAME']?></span>
                    <span class = "student-date">с <?php echo $row['START_DATE']?> по <?php echo $row['END_DATE']?></span>
                </div>
                <div class = "student-info2">
                    <span class = "student-stages">Этапы: <?php echo $row['STAGE_CNT']?></span>
                    <span class = "student-tasks">Выполнено заданий <?php echo $row['STAGE_TASKS_COMPLETE']?>/<?php echo $row['STAGE_TASKS']?></span>
                    <span class = "student-score">Оценка: <?php echo $row['STAGE_TASKS_COMPLETE']?>/<?php echo $row['STAGE_TASKS']?></span>
                </div>
            </div>
        <?php
                unset($row);
            }
            oci_free_statement($stage_info);
        ?>
    </div>

    <div class = "label last">
        <span>Последняя активность практикантов</span>
    </div>
    <div class = "tasks wrap">
        <!-- Запрос на получение последних 7ми заданий -->
        <?php 
            $tasks_info = oci_parse($conn, $get_student_activity);
            oci_bind_by_name($tasks_info, ":user_id", $userid);
            oci_execute($tasks_info);
            while ( $row = oci_fetch_array($tasks_info, OCI_RETURN_NULLS + OCI_ASSOC) ) {
                if (!is_null($row['LAST_DATE'])) {
        ?>
                <div class = "task-activity <?php if($row['RATING'] == 0) echo 'wrong'; ?>">
                    <div class = "task-info <?php if($row['RATING'] == 0) echo 'wrong'; ?>" >
                        <span class = "task-stage-name"><?php echo $row['STUDENT_NAME']?>
                            <span class = 'task-num'>: <?php echo $row['STAGE_NAME']?>
                                <span class = 'task-descrip'> - <?php 
                                    if (strlen($row['TASK_NAME']) > 50) {
                                        echo substr($row['TASK_NAME'], 0, 50).'...';
                                    } else {
                                        echo $row['TASK_NAME'];
                                    }
                                ?></span>
                            </span>
                        </span>
                        <span class = "task-activity-date <?php if($row['RATING'] == 0) echo 'wrong'; ?>">
                            <?php echo $row['LAST_DATE']?>
                        </span>
                    </div>
                    <span class = 'task-activity-answer'><?php echo $row['ANSWER']?></span>
                </div>
        <?php
                    unset($row);
                }
            }
            oci_free_statement($tasks_info);
        ?>
    </div>
</div>
</main>
<?php 
}
require_once "modal.php";
?>
<script>
    $(function() {
        $(".stage-progress-circle").each(function() {
            var v_cnt = $(this).attr('data-correct-task');
            var v_all = $(this).attr('data-all-task');
            var value = getpercentageToTask(v_cnt, v_all);
            var left = $(this).find('.progress-circle-left .progress-circle');
            var right = $(this).find('.progress-circle-right .progress-circle');
            if (value > 0) {
                if (value <= 0.5) {
                    right.css('transform', 'rotate(' + percentageToDegrees(value) + 'deg)')
                } else {
                    right.css('transform', 'rotate(180deg)')
                    left.css('transform', 'rotate(' + percentageToDegrees(value - 0.5) + 'deg)')
                }
            }
        })
        function getpercentageToTask(v_cnt, v_all) {
            return v_cnt / v_all
        }
        function percentageToDegrees(percentage) {
            return percentage * 360
        }
    });

    $(function() {
        $(".stage").click(function() {
            window.location.href = "/task.php";
        })
        $(".task-info").click(function() {
            window.location.href = "/task.php";
        })
        $(".task-activity").click(function() {
            if (<?php echo $usertype?> != 3) {
                window.location.href = "/history.php";
            } else {
                window.location.href = "/task.php";
            }
        })
        $(".active-students").click(function() {
            window.location.href = "/accounts.php";
        })
    });
</script>
<?php
require_once "footer.php"; // Подключаем footer.php
?>