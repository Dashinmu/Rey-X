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
                                <div class = "task">
                                    <div class = "task-info <?php echo $status ?>">
                                        <span class = "task-stage-name"><?php echo $row['STAGE_NAME'] ?><span class = "task-num"> - <?php echo $row['TASK_NUM'] ?></span></span>
                                        <span class = "task-descrip"><?php echo $row['TASK_NAME'] ?></span>
                                        <span class = "task-rating">Статус:
                                            <span class = "task-rating-score <?php echo $status ?>"> 
                                                <?php if (($status == "wrong") || ($status == "inactive")) {echo "Не решено";} else {echo "Решено";} ?>
                                            </span>
                                        </span>
                                    </div>
                                    <div id = <?php echo $row['TASK_ID']?> class = "task-answer <?php echo $status ?> hidden">
                                        <div class = "task-answer-desc">
                                            <span class = "task-answer-span"><?php echo $row['TASK_DESC'] ?></span>
                                        </div>
                                        <div class = "task-answer-area">
                                            <textarea class = "textarea" placeholder = "Введите решение"></textarea>
                                        </div>
                                        <button type="button" class="btn answer btn-primary btn-block <?php echo $status ?>">Отправить на проверку</button>
                                    </div>
                                </div>
            <?php
                    } else {
            ?>
                                <div class = "task">
                                    <div class = "task-info <?php echo $status ?>">
                                        <span class = "task-stage-name"><?php echo $row['STAGE_NAME'] ?><span class = "task-num"> - <?php echo $row['TASK_NUM'] ?></span></span>
                                        <span class = "task-descrip"><?php echo $row['TASK_NAME'] ?></span>
                                        <span class = "task-rating">Статус:
                                            <span class = "task-rating-score <?php echo $status ?>"> 
                                                <?php if (($status == "wrong") || ($status == "inactive")) {echo "Не решено";} else {echo "Решено";} ?>
                                            </span>
                                        </span>
                                    </div>
                                    <div id = <?php echo $row['TASK_ID']?> class = "task-answer <?php echo $status ?> hidden">
                                        <div class = "task-answer-desc">
                                            <span class = "task-answer-span"><?php echo $row['TASK_DESC'] ?></span>
                                        </div>
                                        <div class = "task-answer-area">
                                            <textarea class = "textarea" placeholder = "Введите решение"></textarea>
                                        </div>
                                        <button type="button" class="btn answer btn-primary btn-block <?php echo $status ?>">Отправить на проверку</button>
                                    </div>
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
} else { ?>
    <main>
        <!-- Личные данные -->
        <div class="personal-info">
            <div class = "personal-avatar">
                <img src="img/student.jpg" alt="User Avatar">
            </div>
            <div class = 'div-personal-name'>
                <span><?php echo $user_fio?></span>
            </div>
            <div class="tutor-detail">
                <span class="text"><b>Телефон:</b> <?php echo $user_phone?></span>
                <span class="text"><b>Почта:</b> <?php echo $user_mail?></span>
            </div>
        </div>
        <div class = "second-block">
    <?php
        if ($_GET['a'] == 'stage') {
            $all_stages_info = oci_parse($conn, $get_all_stages_info);
            oci_execute($all_stages_info);
    ?>   
            <div class = "label">
                <span>Этапы практики</span>
                <a href="#" class="create-btn" data-toggle="modal" data-target="#createStage">Создать этап</a>
            </div>
            <div class = "stages-info-block">
                <div class = "stage-info-item">
                    <?php
                        $lastrow = 0;
                        while ($row = oci_fetch_array($all_stages_info, OCI_RETURN_NULLS + OCI_ASSOC)) {
                            if ($lastrow != 0 && $row['STAGE_ID'] != $lastrow) {
                    ?>
                    </div>
                </div>
                <div class = "stage-info-item">
                    <?php
                            }
                            if ($lastrow == 0 || $row['STAGE_ID'] != $lastrow) {
                    ?>
                        <div class = "stage-info">
                            <div class = "stage-marks">
                            </div>
                            <div class = "stage-subinfo">
                                <div>
                                    <span class = "stage-name"><?php echo $row['STAGE_NAME'] ?></span>
                                    <span class = "stage-mean"><?php echo $row['STAGE_MEANING']?></span>
                                </div>
                                <span class = "stage-num-task">Количество заданий: <?php echo $row['STAGE_NUM_TASKS']?></span>
                            </div>
                        </div>
                        <div class = "stage-items-info hidden">
                    <?php                            
                            }
                    ?> 
                            <div class = "item-info">
                                <div class = "item-name">
                                    <div>
                                        <span class = "task-num"><?php echo $row['TASK_NUM_IN_STAGE'] ?></span>
                                        <span class = "task-name"><?php echo $row['TASK_NAME']?></span>
                                    </div>
                                    <span class = "task-date">по <?php echo $row['TASK_INACTIVE_DATE']?></span>
                                </div>
                                <div class = "item-descrip hidden">
                                    <span class = "task-desc"><?php echo $row['TASK_DESC']?></span>
                                    <code class = "task-answer"><?php echo $row['TRUE_ANSWER']?></code>
                                </div>
                            </div>
                    <?php
                            $lastrow = $row['STAGE_ID'];
                        }
                    ?>
                    </div>
                </div>
            </div>
    <?php
        } else {
            $all_tasks_info = oci_parse($conn, $get_all_tasks_info);
           /*  oci_bind_by_name($all_tasks_info, ":user_id", $userid); */
            oci_execute($all_tasks_info);
    ?>      
            <div class = "label">
                <span>Банк заданий</span>
                <a href="#" class="create-btn" data-toggle="modal" data-target="#createTask">Создать задание</a>
            </div>
            <div class = "tasks-info-block">
                <?php
                    while ($row = oci_fetch_array($all_tasks_info, OCI_RETURN_NULLS + OCI_ASSOC)) {
                ?>
                    <div class = "task-info-item <?php echo $row['TASK_INACTIVE_STATUS']?>">
                        <div class = "item-info">
                            <span class = "task-name"><?php echo $row['TASK_MEANING']?></span>
                            <span class = "task-type"><?php echo $row['TASK_TYPE']?></span>
                            <span class = "task-date">Дата: <?php echo $row['TASK_CREATION_DATE']?> - <?php echo $row['TASK_INACTIVE_DATE']?></span>
                        </div>
                        <div class = "item-descrip hidden">
                        <?php
                            if (!is_null($row['LINKS_TO_STAGES'])) {
                        ?>
                            <div class = "marks">
                                <?php 
                                    $links = explode(';', $row['LINKS_TO_STAGES']);
                                    for ($i = 0; $i < count($links); $i++){
                                ?>
                                    <span class = "links"><?php echo $links[$i]?></span>
                                <?php
                                    }
                                ?>   
                            </div>
                        <?php
                            }
                        ?>
                            <span class = "task-desc"><?php echo $row['TASK_DESCRIPTION']?></span>
                            <code class = "task-answer"><?php echo $row['ANSWER']?></code>
                        </div>
                    </div>
                <?php
                    }
                ?>
            </div>
        </div>
    <?php
        }
    ?>
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
    };

    $(function() {
        $(".task-info").click(function() {
            if ($(this).hasClass("inactive")) {
                $(this).toggleClass("active").toggleClass("inactive");
            } else {
                $(this).toggleClass("active");
            }
            $(this).closest(".task").children(".task-answer").toggleClass("hidden");
        })
    });

    $(function() {
        $(".answer").click(function() {
            var answer = $(this).closest(".task-answer").children(".task-answer-area").children(".textarea").val();
            var taskID = $(this).closest(".task-answer").attr("id");
            var user = <?php echo $userid?>;
            $.ajax({
                url:"./scripts/answer.php"
                , type: "POST"
                , data: {
                    answer: answer
                    , task: taskID
                    , user: user
                }
                , success: function(response){
                    var result = JSON.parse(response);
                    if (result.message != "0") {
                        if (result.error_message != "0") {
                            if(
                                $(this).closest(".task").children("task-info").hasClass("wrong")
                                && $(this).closest(".task").children("task-answer").hasClass("wrong")
                            ) {
                                $(this).closest(".task").children("task-info").toggleClass("wrong");
                                $(this).closest(".task").children("task-answer").toggleClass("wrong");
                            }
                        } else {
                            if (!$(this).closest(".task").children("task-info").hasClass("wrong")
                                && !$(this).closest(".task").children("task-answer").hasClass("wrong")
                            ){
                                $(this).closest(".task").children("task-info").toggleClass("wrong");
                                $(this).closest(".task").children("task-answer").toggleClass("wrong");
                            }
                        }
                        alert(result.error_message);
                    } else {
                        alert(result.error_message);
                    }
                }
                , error: function(){
                   alert("Не удалось отправить запрос на проверку...");
                }
            });
        })
    });

    $(function() {
        $(".task-info-item").click(function() {
            $(this).toggleClass("open");
            $(this).children(".item-descrip").toggleClass("hidden");
        })
    });

    $(function() {
        $("#btn_create_task").click(function(){
            var p_meaning = $("#task_meaning").val();
            var p_desc = $("#task_desc").val();
            var p_type = $("#task_type").val();
            var p_author = <?php echo $userid ?>;
            var p_answer = $("#task_answer").val();
            $.ajax({
                url:"./scripts/create_task.php"
                , type: "POST"
                , data: {
                    p_meaning: p_meaning
                    , p_desc: p_desc
                    , p_type: p_type
                    , p_author: p_author
                }
                , success: function(response){
                    var result = JSON.parse(response);
                    if (result.message != 0){
                        if (result.message != 1){
                            /* showNotification("Задание успешно создано!", 'accept'); */
                            $.ajax({
                                url:"./scripts/answer.php"
                                , type: "POST"
                                , data: {
                                    user: p_author
                                    , task: result.error_message
                                    , answer: p_answer
                                }
                                , success: function(response) {
                                    var res = JSON.parse(response);
                                    if (res.message != 0) {
                                        if (res.message != 1) {
                                            showNotification("Задание успешно создано!", 'accept');
                                            /* location.reload(); */
                                        } else {
                                            alert(res.error_message)
                                        }
                                    } else {
                                        alert(res.error_message);
                                    }
                                }
                                , error: function() {
                                    alert("Не удалось отправить запрос на запись ответа...");
                                }
                            });
                        } else {
                            alert(result.error_message);
                        }
                    } else {
                        alert(result.error_message);
                    }
                }
                , error: function(){
                    alert("Не удалось отправить запрос на создание...");
                }
            });
        })
    });

    $(function() {
        $(".stage-info").click(function() {
            $(this).toggleClass("open");
            $(this).closest(".stage-info-item").children(".stage-items-info").toggleClass("hidden");
        })
    });

    $(function() {
        $(".item-name").click(function() {
            $(this).toggleClass("open");
            $(this).closest(".item-info").children(".item-descrip").toggleClass("hidden");
        })
    });

    $(function() {
        $("#btn_create_stage").click(function() {
            var p_stage_name = $("#stage_name").val();
            var p_meaning = $("#stage_mean").val();
            var p_author = <?php echo $userid ?>;
            $.ajax({
                url:"./scripts/create_stage.php"
                , type: "POST"
                , data: {
                    p_meaning: p_meaning
                    , p_stage_name: p_stage_name
                    , p_author: p_author
                }
                , success: function(response) {
                    var result = JSON.parse(response);
                    if (result.message != 0) {
                        if (result.message != 1) {
                            showNotification("Этап успешно создано!", 'accept');
                            /* location.reload(); */
                        } else {
                            alert(result.error_message)
                        }
                    } else {
                        alert(result.error_message);
                    }
                }
                , error: function() {
                    alert("Не удалось отправить запрос на запись этапа...");
                }
            });
        })
    });

</script>
<?php
require_once "footer.php"; // Подключаем footer.php
?>