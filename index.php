<?php
$page_title = "Авторизация"; // Устанавливаем заголовок страницы
require_once "header.php"; // Подключаем header.php
require_once "./scripts/db_connect.php"; // Подключаем файл с подключением к базе данных

// Проверяем, установлена ли сессия и существует ли имя пользователя в сессии
if (!isset($_SESSION['username'])) {
    // Если сессия не установлена или имя пользователя отсутствует, перенаправляем на страницу авторизации
    header("Location: /login.php");
    exit();
}
?>

<div class="container">
    <div class="personal-info">
        <?php 
            $qua = "
                select
                    *
                from
                    PERSONAL_INFO
                where 1 = 1
                    and user_login = upper(:username)
            ";
            $res = oci_parse($conn, $qua);
            oci_bind_by_name($res, ':username', $username);
            oci_execute($res);
            $userData = oci_fetch_assoc($res);
        ?>
        <div class="avatar">
            <img src="img/avatar.png" alt="Аватар пользователя">
        </div>
        <div class="user-details">
            <h2>Личная информация</h2>
            <p><span class="lime-text">Имя:</span> <?php echo $userData['USER_NAME'];?></p>
            <p><span class="lime-text">Почта:</span> <?php echo $userData['USER_MAIL']?></p>
            <p><span class="lime-text">Телефон:</span> <?php echo $userData['USER_PHONE']?></p>
            <p><span class="lime-text">Права:</span> <?php echo $userData['USER_TYPE']?></p>
            <button type="submit">Сменить пароль</button>
        </div>
        
    </div>
</div>


<?php
require_once "footer.php"; // Подключаем footer.php
?>