<?php
$page_title = "Авторизация"; // Устанавливаем заголовок страницы
require_once "header.php"; // Подключаем header.php
require_once "menu.php"; // Подключить meny.php
require_once "./scripts/db_connect.php"; // Подключаем файл с подключением к базе данных

// Проверяем, установлена ли сессия и существует ли имя пользователя в сессии
if (!isset($_SESSION['username'])) {
    // Если сессия не установлена или имя пользователя отсутствует, перенаправляем на страницу авторизации
    header("Location: /login.php");
    exit();
}
?>

<main>
    <!-- Личные данные и оценка -->
    <div class="personal-info">
        <div class = "personal-avatar">
            <img src="img/student.jpg" alt="User Avatar">
        </div>
        <div class = 'div-personal-name'>
            <span>Аврора Мясникова</span>
        </div>
        <div class="tutor-detail">
            <span class="text"><b>Руководитель:</b> Daniil Dashinmu</span>
            <span class="text"><b>Телефон:</b> +7-919-446-04-27</span>
        </div>
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
            <span>Последние этапы практики</span>
        </div>
        <div class = "stages">
            <div class = "stage">
                <div class = "stage-info">
                    <span class = "stage-name">Stage #2</span>
                    <span class = "stage-desc">Введение в работу с PL/SQL</span>
                    <span class = "stage-tasks">Выполнено заданий: 3/13</span>
                    <div class = "stage-note">
                        <span class = "note-text">PL/SQL</span>
                        <span class = "note-text">Новичок</span>
                    </div>
                </div>
                <div class = "stage-progress-circle" data-correct-task = '1' data-all-task = '13'>
                    <span class = "progress-circle-left">
                        <span class = "progress-circle"></span>
                    </span>
                    <span class = "progress-circle-right">
                        <span class = "progress-circle"></span>
                    </span>
                    <div class = "stage-progress-value">
                        <span>1<span class = "stage-num-tasks">/13</span></span>
                    </div>
                </div>
            </div>
            <div class = "stage">
                <div class = "stage-info">
                    <span class = "stage-name">Stage #1</span>
                    <span class = "stage-desc">Организация практики</span>
                    <span class = "stage-tasks">Выполнено заданий: 10/10</span>
                    <div class = "stage-note">
                        <span class = "note-text">Ознакомление</span>
                    </div>
                </div>
                <div class = "stage-progress-circle" data-correct-task = '10' data-all-task = '10'>
                    <span class = "progress-circle-left">
                        <span class = "progress-circle"></span>
                    </span>
                    <span class = "progress-circle-right">
                        <span class = "progress-circle"></span>
                    </span>
                    <div class = "stage-progress-value">
                        <span>10<span class = "stage-num-tasks">/10</span></span>
                    </div>
                </div>
            </div>
        </div>
        <div class = "label last">
            <span>Последние задания</span>
        </div>
        <div class = "tasks">
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
</main>


<?php
require_once "modal.php";
require_once "footer.php"; // Подключаем footer.php
?>