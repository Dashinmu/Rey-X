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

if ($usertype == 1 || $usertype == 2) { ?>
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

<!-- Этапы и история заданий -->
<div class = "students-activity min">
    <div class = "label">
        <span>Практиканты</span>
        <a href="#" class="create-account-btn" data-toggle="modal" data-target="#createAccountModal">Создать учётную запись</a>
        <!-- <span class = "create-account-btn">Создать учётную запись</span> -->
    </div>

    <div class = "active-students">
        <!-- Запрос на получение последних 2х этапов -->
        <?php 
            $stage_info = oci_parse($conn, $get_all_student);
            oci_bind_by_name($stage_info, ":user_id", $userid);
            oci_execute($stage_info);
            while ( $row = oci_fetch_array($stage_info, OCI_RETURN_NULLS + OCI_ASSOC) ) {
        ?>
            <div class = "student-info <?php echo $row['STATUS']?>">
                <div class = "student-info1">
                    <span class = "student-name"><?php echo $row['STUDENT_NAME']?></span>
                    <span class = "student-date <?php echo $row['STATUS']?>">с <?php echo $row['START_DATE']?> по <?php echo $row['END_DATE']?></span>
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
</div>
</main>
<?php 
}
require_once "modal.php";
?>
<script>
    $(function() {
        $(".stage").click(function() {
            window.location.href = "/task.php";
        })
    });
    $(function() {
        $("#createAccountModal").submit(function(e){
            e.preventDefault();
            var p_login = $("#login").val();
            var p_username = $("#username").val();
            var p_password = $("#password").val();
            var p_start_date = $("#startdate").val();
            var p_end_date = $("#enddate").val();
            var p_email = $("#email").val();
            var p_phone = $("#phone").val();
            var p_user_type = <?php if ($userid == 1) { echo 1; } else { echo 2; }?>;
            $.ajax({
                url:"./scripts/create_account.php"
                , type: "POST"
                , data: {
                    p_login: p_login
                    , p_username: p_username
                    , p_password: p_password
                    , p_start_date: p_start_date
                    , p_end_date: p_end_date
                    , p_email: p_email
                    , p_phone: p_phone
                    , p_user_type: p_user_type
                    , p_user: <?php echo $userid;?>
                }
                , success: function(response){
                    var result = JSON.parse(response);
                    if (result.message != 0){
                        if (result.message != 1){
                            showNotification("Учётная запись успешна создана!", 'accept');
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
</script>
<?php
require_once "footer.php"; // Подключаем footer.php
?>