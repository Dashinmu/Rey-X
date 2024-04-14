<?php
session_start();
// Проверяем, установлена ли сессия и существует ли имя пользователя в сессии
if (isset($_SESSION['username'])) {
    $username = $_SESSION['username'];
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $page_title; ?></title>
    <link rel="stylesheet" href="styles.css">
    <script async data-id="five-server" src="http://localhost:5500/fiveserver.js"></script>
    <!-- <script src="scripts/scripts.js"></script> -->
</head>
<body>
