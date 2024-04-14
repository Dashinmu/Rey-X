<?php
session_abort();
$page_title = "Авторизация"; // Устанавливаем заголовок страницы
require_once "header.php"; // Подключаем header.php
?>

<div class="container">
    <form class="form" method="post" action="./scripts/process_login.php">
        <h2>Авторизация</h2>
        <div class="input-container">
            <input type="text" name="username" placeholder="Имя пользователя" required>
        </div>
        <div class="input-container">
            <input type="password" name="password" placeholder="Пароль" required>
            <p class="register-text">Нет аккаунта? <a href="/register.php">Зарегистрироваться</a></p>
        </div>
        <button type="submit">Войти</button>
        <?php
        // Отображаем сообщение об ошибке, если есть
        if (isset($_GET["error"])) {
            $error = $_GET["error"];
        ?>
            <!-- Окно уведомления и его функции-->
            <div class="notification">
                <span class="message"></span>
                <button onclick="closeNotification()">ОК</button>
            </div>
            <!-- Скрипт вывода диалогового окна с ошибкой -->
            <script>
                function showNotification(message) {
                    document.querySelector('.notification .message').innerText = message;
                    document.querySelector('.notification').style.display = 'block';
                }

                function closeNotification() {
                    document.querySelector('.notification').style.display = 'none';
                }
            </script>
        <?php
            if ($error == "empty") {
                $errorMessage = "Введите имя пользователя и пароль";
                echo "<script>showNotification('$errorMessage');</script>";
            } elseif ($error == "invalid") {
                $errorMessage = "Неверное имя пользователя или пароль";
                echo "<script>showNotification('$errorMessage');</script>";
            }
        }
        ?>
    </form>
</div>

<?php
require_once "footer.php"; // Подключаем footer.php
?>