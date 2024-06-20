<?php
session_start();
// Проверяем, установлена ли сессия и существует ли имя пользователя в сессии 
if (isset($_SESSION['userlogin']) && isset($_SESSION['usertype']) && isset($_SESSION['userid'])) {
    $userlogin = $_SESSION['userlogin'];
    $usertype = $_SESSION['usertype'];
    $userid = $_SESSION['userid'];
} else {
    header("Location: /login.php");
    exit();
}
?>