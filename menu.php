<menu>
    <div class="menu">
        <div class="user-info" onclick="toggleMenu()">
            <img src="img/student.jpg" alt="User Avatar" class="avatar">
            <span class="text"><?php echo $user_fio?></span>
        </div>
        <div class="menu-content" id="menuContent">
            <div class="user-info">
                <img src="img/student.jpg" alt="User Avatar" class="avatar">
                <div class = "user-detail">
                    <span class="text"><?php echo $user_fio?></span>
                    <span class="user-role"><?php echo $user_type_mean?></span>
                </div>
            </div>
            <?php if (!is_null($tutor_fio) && $usertype != 1 && $usertype != 2) {?>
                    <div class='user-info'>
                        <img src='img/avatar.png' alt='User Avatar' class='avatar'>
                        <div class = 'user-detail'>
                            <span class='text'><?php echo $tutor_fio?></span>
                            <span class='user-role'><?php echo $tutor_type_mean?></span>
                            <span class='user-phone'><?php echo $tutor_phone?></span>
                        </div>
                    </div>
            <?php
            }
            ?>
            <ul class="menu-list">
                <li class="menu-item first"><a href="/index.php" class="menu-link">Главная</a></li>
                <?php if ($usertype == 1 || $usertype == 2) echo '<li class="menu-item"><a href="/accounts.php" class="menu-link">Пользователи</a></li>'?>
                <li class="menu-item"><a href="/task.php" class="menu-link">Задания</a></li>
                <li class="menu-item"><a href="#" class="menu-link" data-toggle="modal" data-target="#settingsModal">Изменить пароль</a></li>
                <li class="menu-item last"><a href="./scripts/logout.php" class="menu-link">Выйти</a></li>
            </ul>
        </div>
        <div class="pages_link">
            <a href="/index.php" class="btn btn-outline-light <?php if ($_SERVER['REQUEST_URI'] == '/index.php') { echo "active"; }?> btn-sm" aria-current="page">Главная</a>
            <?php if ($usertype == 1 || $usertype == 2) {?>
                <a href="/task.php" class="btn btn-outline-light <?php if ($_SERVER['REQUEST_URI'] == '/task.php') { echo "active"; }?> btn-sm">Этапы</a>
                <a href="/task.php" class="btn btn-outline-light <?php if ($_SERVER['REQUEST_URI'] == '/task.php') { echo "active"; }?> btn-sm">Задания</a>
                <a href="/index.php" class="btn btn-outline-light <?php if ($_SERVER['REQUEST_URI'] == '/history.php') { echo "active"; }?> btn-sm" aria-current="page">История</a>
                <a href="/accounts.php" class="btn btn-outline-light <?php if ($_SERVER['REQUEST_URI'] == '/accounts.php') { echo "active"; }?> btn-sm">Пользователи</a>
            <?php } else {?>
                <a href="/task.php" class="btn btn-outline-light <?php if ($_SERVER['REQUEST_URI'] == '/task.php') { echo "active"; }?> btn-sm">Задания</a>
            <?php }?>
        </div>
    </div>
</menu>

<script>
    function toggleMenu() {
        var menuContent = document.getElementById("menuContent");
        menuContent.classList.toggle("show-menu");
    }

    // Закрытие меню при клике вне его области
    window.addEventListener('click', function(event) {
        var menuContent = document.getElementById("menuContent");
        var menuToggler = document.querySelector(".user-info");
        var menuToggler1 = document.querySelector(".user-info img");
        var menuToggler2 = document.querySelector(".user-info span");
        if (
            !menuContent.contains(event.target) 
            && event.target !== menuToggler
            && event.target !== menuToggler1
            && event.target !== menuToggler2
        ) {
            menuContent.classList.remove("show-menu");
        }
    });
</script>