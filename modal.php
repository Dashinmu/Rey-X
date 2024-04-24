<div class = "notification">
    <span class = "message"></span>
    <button onclick = "closeNotification()">OK</button>
</div>
<!-- Modal Password -->
<div class="modal fade" id="settingsModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">Изменить пароль</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form method = "post" action = "./scripts/change_password.php">
                    <div class="form-group">
                        <input type="password" class="form-control" name="oldPassword" placeholder="Введите старый пароль" required>
                    </div>
                    <div class="form-group">
                        <input type="password" class="form-control" name="newPassword" placeholder="Введите новый пароль" required>
                    </div>
                    <div class="form-group">
                        <input type="password" class="form-control" name="confirmPassword" placeholder="Подтвердите новый пароль" required>
                    </div>
                    <div class="modal-footer">
                        <button type="submit" class="btn btn-primary btn-block">Подтвердить</button>
                        <button type="button" class="btn btn-secondary btn-block" data-dismiss="modal">Закрыть</button>
                    </div>
                    <script>
                        function showNotification(message, status) {
                            document.querySelector('.notification .message').innerText = message;
                            if (status == "accept") {
                                document.querySelector('.notification').classList.toggle("display_notification_accept");
                            } else {
                                document.querySelector('.notification').classList.toggle("display_notification");
                            }
                        }
                        function closeNotification() {
                            if (document.querySelector('.notification').classList.contains("display_notification_accept")) {
                                document.querySelector('.notification').classList.toggle("display_notification_accept");
                            } else {
                                document.querySelector('.notification').classList.toggle("display_notification");
                            }
                        }
                    </script>
                    <?php
                        if (isset($_GET["error"])) {
                            $error = $_GET["error"];
                            if ($error == "method_error") {$errorMessage = "Ошибка формы. Обратитесь к администратору";}
                            else if ($error == "empty_values") {$errorMessage = "Поля ввода не могут быть пустыми";}
                            else if ($error == "password_not_match") {$errorMessage = "Новый пароль не совпадает";}
                            else if ($error == "cancel_execute") {$errorMessage = "Ошибка при смене пароля. Обратитесь к администратору";}
                            else if ($error == "auth_not_match") {$errorMessage = "Старый пароль введён неверно";}
                            echo "<script>showNotification('$errorMessage', 'status');</script>";
                        } else if (isset($_GET["accept"])) {
                            $confirm = $_GET["accept"];
                            if ($confirm == "password_change") {$confirmMessage = "Пароль успешно изменён";}
                            echo "<script>showNotification('$confirmMessage', 'accept');</script>";
                        }
                    ?>  
                </form>
            </div>
        </div>
    </div>
</div>