<?php
require_once "db_connect.php";
require_once "cursors.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    if (empty($_POST["oldPassword"]) || empty($_POST["newPassword"]) || empty($_POST["confirmPassword"])) {

    } else {
        if (!$conn) {

        }

        $p_password_old = $_POST["oldPassword"];
        $p_password_new = $_POST["newPassword"];
        $p_password_confirm = $_POST["confirmPassword"];

        $sql = $change_password;
    }

}
?>