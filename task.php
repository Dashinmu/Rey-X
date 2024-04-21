<?php
$page_title = "Авторизация"; // Устанавливаем заголовок страницы
require_once "header.php"; // Подключаем header.php
require_once "./scripts/db_connect.php"; // Подключаем файл с подключением к базе данных

// Проверяем, установлена ли сессия и существует ли имя пользователя в сессии
if (!isset($_SESSION['userlogin']) && !isset($_SESSION['usertype'])) {
    // Если сессия не установлена или имя пользователя отсутствует, перенаправляем на страницу авторизации
    header("Location: /login.php");
    exit();
} else {
    // Перенаправлять если хитрые хотят поменять права доступа
    if (!str_contains($_SERVER['REQUEST_URI'],"?access=$usertype")) {
        header("Location: /task.php?access=$usertype");
        exit();
    };
}

$sql = "BEGIN diplom.fnd_user.get_personal_data(
    p_login => :userlogin
    , p_username => :user_fio
    , p_type_meaning => :user_type_mean
    , p_tutor_name => :tutor_fio
    , p_tutor_type => :tutor_type_mean
    , p_tutor_phone => :tutor_phone
); END;";
$stmt = oci_parse($conn, $sql);
oci_bind_by_name($stmt, ":userlogin", $userlogin);
oci_bind_by_name($stmt, ":user_fio", $user_fio, 50, SQLT_CHR);
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
                <img src="img/student.jpg" alt="User Avatar">
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
                <div class="rating-ellipse">
                    <span>N/A</span>
                </div>
            </div>
        </div>

        <!-- Этапы и история заданий -->
        <div class = "personal-history">
            <div class = "label">
                <span>Этапы практики</span>
            </div>
            <?php 
                $all_info = oci_parse($conn, $get_student_all_stage);
                oci_bind_by_name($all_info, ":student_id", $userid);
                oci_execute($all_info);
                $last_row = 0;
            ?>
                <div class = "stages-item">
            <?php
                while ( $row = oci_fetch_array($all_info, OCI_RETURN_NULLS + OCI_ASSOC) ) {
                    $status = "";
                    if (is_null($row['FIRST_TRUE_ANSWER']) && !is_null($row['LAST_DATE'])) {$status = "wrong";}
                    if (is_null($row['LAST_DATE'])) {$status = "inactive";}
                    if ($last_row <> $row['STAGE_ID'] && $last_row <> 0) {
            ?>              
                            </div>
                        </div>
                        <div class = "stages-item">
            <?php
                    }
                    if ($last_row <> $row['STAGE_ID'])
                    {
                        $last_row = $row['STAGE_ID'];
            ?>
                            <div class = "stage" id = "stage<?php echo $row['STAGE_ID']?>" onclick="toggleStage('stage<?php echo $row['STAGE_ID']?>', 'stage<?php echo $row['STAGE_ID']?>-tasks')">
                                <div class = "stage-info">
                                    <div class = "stage-note-2">
                                        <span class = "note-text"><?php echo "Ознакомление" ?></span>
                                    </div>
                                    <div class = "stage-info-2">
                                        <span class = "stage-name"><?php echo $row['STAGE_NAME'] ?></span>
                                        <span class = "stage-desc"><?php echo $row['STAGE_MEANING'] ?></span>
                                        <span class = "stage-tasks"><?php echo "Выполнено заданий: ".$row['TASK_ANSWER_IN_STAGE']."/".$row['STAGE_NUM_TASKS'] ?></span>
                                    </div>
                                </div>
                                <div 
                                    class = "progress"
                                    role = "progressbar"
                                    data-correct-task = "<?php echo $row['TASK_COMPLETE_IN_STAGE'] ?>"
                                    data-all-task = "<?php echo $row['STAGE_NUM_TASKS'] ?>"
                                >
                                    <div class = "progress-bar"></div>
                                </div>
                            </div>
                            <div class = "tasks hidden" id = "stage<?php echo $row['STAGE_ID']?>-tasks">
                                <div class = "task <?php echo $status ?>">
                                    <span class = "task-stage-name"><?php echo $row['STAGE_NAME'] ?><span class = "task-num"> - <?php echo $row['TASK_NUM'] ?></span></span>
                                    <span class = "task-descrip"><?php echo $row['TASK_NAME'] ?></span>
                                    <span class = "task-rating">Статус:
                                        <span class = "task-rating-score <?php echo $status ?>"> 
                                            <?php if (($status == "wrong") || ($status == "inactive")) {echo "Не решено";} else {echo "Решено";} ?>
                                        </span>
                                    </span>
                                </div>
            <?php
                    } else {
            ?>
                                <div class = "task <?php echo $status ?>">
                                    <span class = "task-stage-name"><?php echo $row['STAGE_NAME'] ?><span class = "task-num"> - <?php echo $row['TASK_NUM'] ?></span></span>
                                    <span class = "task-descrip"><?php echo $row['TASK_NAME'] ?></span>
                                    <span class = "task-rating">Статус:
                                        <span class = "task-rating-score <?php echo $status ?>"> 
                                            <?php if (($status == "wrong") || ($status == "inactive")) {echo "Не решено";} else {echo "Решено";} ?>
                                        </span>
                                    </span>
                                </div>
            <?php
                    }
                    unset($row);
                }
                oci_free_statement($all_info);
            ?>
                </div>
            </div>
        </div>
    </main>  

<?php
}
require_once "modal.php";
?>
<script>
    $(function() {
        $(".stages-item .progress").each(function() {
            var v_cnt = $(this).attr('data-correct-task');
            var v_all = $(this).attr('data-all-task');
            var bar = $(this).find('.progress-bar');
            bar.css({
                width: getpercentageToTask(v_cnt, v_all) + "%"
            })
        })
        function getpercentageToTask(v_cnt, v_all) {
            return v_cnt / v_all * 100
        }
    });

    function toggleStage(elementId, tasksId) {
        var stageNum = document.getElementById(elementId);
        var stageTasks = document.getElementById(tasksId);
        stageNum.classList.toggle("active");
        stageTasks.classList.toggle("hidden");
    }

</script>
<?php
require_once "footer.php"; // Подключаем footer.php
?>