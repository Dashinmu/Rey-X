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

<div class = "students-activity min">
    <div class = "label">
        <span>История практикантов</span>
    </div>

    <div class = "students-history">
        <?php 
            $students_info = oci_parse($conn, $get_all_students_history);
            oci_bind_by_name($students_info, ":p_user", $userid);
            oci_execute($students_info);
            $rownum = 0;
            $tasknum = 0;
            while ( $row = oci_fetch_array($students_info, OCI_RETURN_NULLS + OCI_ASSOC) ) {
                if ($rownum != $row['STUDENT_ID']) {
        ?>
            <?php if ($rownum != 0) echo "</div>";?>
            <div>
                <div class = "student-info <?php echo $row['STUDENT_STATUS']?>">
                    <div class = "student-info1">
                        <span class = "student-name"><?php echo $row['STUDENT_NAME']?></span>
                        <span class = "student-date <?php echo $row['STUDENT_STATUS']?>">с <?php echo $row['START_DATE']?> по <?php echo $row['END_DATE']?></span>
                    </div>
                    <div class = "student-info2">
                        <span class = "student-stages">Этапы: <?php echo $row['NUM_STAGES_ASSIGNED']?></span>
                        <span class = "student-tasks">Выполнено заданий <?php echo $row['NUM_ALL_ANSWER_TASKS']?>/<?php echo $row['NUM_STAGES_ASSIGNED']?></span>
                        <span class = "student-score">Оценка: <?php echo $row['NUM_ALL_ANSWER_TASKS']?>/<?php echo $row['NUM_STAGES_ASSIGNED']?></span>
                    </div>
                </div>
        <?php                    
                }
                if ($tasknum != $row['TASK_ID']) {
        ?>
                <?php if ($tasknum != 0) echo "</div>";?>
                <div class = "student-info-block">
                    <div class = "student-task-info">
                        
                    </div>
        <?php                    
                }
        ?>
                
        <?php
                $rownum = $row['STUDENT_ID'];
                unset($row);
            }
            oci_free_statement($students_info);
        ?>
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
    
</script>
<?php
require_once "footer.php"; // Подключаем footer.php
?>