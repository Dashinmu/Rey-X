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
            <?php if (!is_null($tutor_fio)) 
                echo "
                    <div class='user-info'>
                        <img src='img/avatar.png' alt='User Avatar' class='avatar'>
                        <div class = 'user-detail'>
                            <span class='text'>".$tutor_fio."</span>
                            <span class='user-role'>".$tutor_type_mean."</span>
                            <span class='user-phone'>".$tutor_phone."</span>
                        </div>
                    </div>
                ";
            ?>
            <ul class="menu-list">
                <li class="menu-item first"><a href="/index.php" class="menu-link">Главная</a></li>
                <li class="menu-item"><a href="/task.php" class="menu-link">Задания</a></li>
                <li class="menu-item"><a href="#" class="menu-link" data-toggle="modal" data-target="#settingsModal">Изменить пароль</a></li>
                <li class="menu-item last"><a href="/login.php" class="menu-link">Выйти</a></li>
            </ul>
        </div>
        <div class="pages_link">
            <a href="/index.php" class="btn btn-outline-light active btn-sm" aria-current="page">Главная</a>
            <a href="/task.php" class="btn btn-outline-light btn-sm">Задания</a>
        </div>
    </div>
</menu>