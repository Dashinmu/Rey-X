<?php
session_start();
// Проверяем, установлена ли сессия и существует ли имя пользователя в сессии
if (isset($_SESSION['userlogin']) && isset($_SESSION['usertype'])) {
    $userlogin = $_SESSION['userlogin'];
    $usertype = $_SESSION['usertype'];
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $page_title; ?></title>
    <script async data-id="five-server" src="http://localhost:5500/fiveserver.js"></script>
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.4/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="styles_test.css">
</head>
<body>
