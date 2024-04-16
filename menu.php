<menu>
    <div class="menu">
        <div class="user-info" onclick="toggleMenu()">
            <img src="img/student.jpg" alt="User Avatar" class="avatar">
            <span class="text">Аврора Мясникова</span>
        </div>
        <div class="menu-content" id="menuContent">
            <div class="user-info">
                <img src="img/student.jpg" alt="User Avatar" class="avatar">
                <div class = "user-detail">
                    <span class="text">Аврора Мясникова</span>
                    <span class="user-role">Студент</span>
                </div>
            </div>
            <div class="user-info">
                <img src="img/avatar.png" alt="User Avatar" class="avatar">
                <div class = "user-detail">
                    <span class="text">Daniil Dashinmu</span>
                    <span class="user-role">Руководитель</span>
                    <span class="user-phone">+7-919-446-04-27</span>
                </div>
            </div>
            <ul class="menu-list">
                <li class="menu-item first"><a href="/index.php" class="menu-link">Главная</a></li>
                <li class="menu-item"><a href="#" class="menu-link">Задания</a></li>
                <li class="menu-item"><a href="#" class="menu-link" data-toggle="modal" data-target="#settingsModal">Изменить пароль</a></li>
                <li class="menu-item last"><a href="/login.php" class="menu-link">Выйти</a></li>
            </ul>
        </div>
        <div class="pages_link">
            <a href="index.html" class="btn btn-outline-light btn-sm" aria-current="page">Главная</a>
            <a href="tasks.html" class="btn btn-outline-light active btn-sm">Задания</a>
        </div>
    </div>
</menu>