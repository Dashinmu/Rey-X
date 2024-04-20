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
            <div class = "stages-item">
                <div class = "stage" id = "stage2" onclick="toggleStage('stage2', 'stage2-tasks')">
                    <div class = "stage-info">
                        <div class = "stage-note-2">
                            <span class = "note-text">PL/SQL</span>
                            <span class = "note-text">Новичок</span>
                        </div>
                        <div class = "stage-info-2">
                            <span class = "stage-name">Stage #2</span>
                            <span class = "stage-desc">Введение в работу с PL/SQL</span>
                            <span class = "stage-tasks">Выполнено заданий: 3/13</span>
                        </div>
                    </div>
                    <div 
                        class = "progress"
                        role = "progressbar"
                        data-correct-task = "1"
                        data-all-task = "13"
                    >
                        <div class = "progress-bar"></div>
                    </div>
                </div>
                <div class = "tasks hidden" id = 'stage2-tasks'>
                    <div class = "task wrong">
                        <span class = "task-stage-name">Stage #2<span class = "task-num"> - 3</span></span>
                        <span class = "task-descrip">Task 2-3 description</span>
                        <span class = "task-rating">Статус:<span class = "task-rating-score wrong"> Не решено</span></span>
                    </div>
                    <div class = "task wrong">
                        <span class = "task-stage-name">Stage #2<span class = "task-num"> - 2</span></span>
                        <span class = "task-descrip">Task 2-2 description</span>
                        <span class = "task-rating">Статус:<span class = "task-rating-score wrong"> Не решено</span></span>
                    </div>
                    <div class = "task">
                        <span class = "task-stage-name">Stage #2<span class = "task-num"> - 1</span></span>
                        <span class = "task-descrip">Task 2-1 description</span>
                        <span class = "task-rating">Статус:<span class = "task-rating-score"> Решено</span></span>
                    </div>
                    <div class = "task">
                        <span class = "task-stage-name">Stage #1<span class = "task-num"> - 10</span></span>
                        <span class = "task-descrip">Task 1-10 description</span>
                        <span class = "task-rating">Статус:<span class = "task-rating-score"> Решено</span></span>
                    </div>
                    <div class = "task">
                        <span class = "task-stage-name">Stage #1<span class = "task-num"> - 9</span></span>
                        <span class = "task-descrip">Task 1-9 description</span>
                        <span class = "task-rating">Статус:<span class = "task-rating-score"> Решено</span></span>
                    </div>
                    <div class = "task">
                        <span class = "task-stage-name">Stage #1<span class = "task-num"> - 8</span></span>
                        <span class = "task-descrip">Task 1-8 description</span>
                        <span class = "task-rating">Статус:<span class = "task-rating-score"> Решено</span></span>
                    </div>
                    <div class = "task">
                        <span class = "task-stage-name">Stage #1<span class = "task-num"> - 7</span></span>
                        <span class = "task-descrip">Task 1-7 description</span>
                        <span class = "task-rating">Статус:<span class = "task-rating-score"> Решено</span></span>
                    </div>
                </div>
            </div>
            <div class = "stages-item">
                <div class = "stage" id = "stage1" onclick="toggleStage('stage1', 'stage1-tasks')">
                    <div class = "stage-info">
                        <div class = "stage-note-2">
                            <span class = "note-text">Ознакомление</span>
                        </div>
                        <div class = "stage-info-2">
                            <span class = "stage-name">Stage #1</span>
                            <span class = "stage-desc">Ознакомление с практикой</span>
                            <span class = "stage-tasks">Выполнено заданий: 10/10</span>
                        </div>
                    </div>
                    <div 
                        class = "progress"
                        role = "progressbar"
                        data-correct-task = "10"
                        data-all-task = "10"
                    >
                        <div class = "progress-bar"></div>
                    </div>
                </div>
                <div class = "tasks hidden" id = "stage1-tasks">
                    <div class = "task">
                        <span class = "task-stage-name">Stage #1<span class = "task-num"> - 10</span></span>
                        <span class = "task-descrip">Task 1-10 description</span>
                        <span class = "task-rating">Статус:<span class = "task-rating-score"> Решено</span></span>
                    </div>
                    <div class = "task">
                        <span class = "task-stage-name">Stage #1<span class = "task-num"> - 9</span></span>
                        <span class = "task-descrip">Task 1-9 description</span>
                        <span class = "task-rating">Статус:<span class = "task-rating-score"> Решено</span></span>
                    </div>
                    <div class = "task">
                        <span class = "task-stage-name">Stage #1<span class = "task-num"> - 8</span></span>
                        <span class = "task-descrip">Task 1-8 description</span>
                        <span class = "task-rating">Статус:<span class = "task-rating-score"> Решено</span></span>
                    </div>
                    <div class = "task">
                        <span class = "task-stage-name">Stage #1<span class = "task-num"> - 7</span></span>
                        <span class = "task-descrip">Task 1-7 description</span>
                        <span class = "task-rating">Статус:<span class = "task-rating-score"> Решено</span></span>
                    </div>
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