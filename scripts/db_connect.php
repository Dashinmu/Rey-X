<?php
// Параметры подключения
$user = 'DIPLOM';
$password = 'pass4diplom';
$host = 'localhost';
$port = 1521;
$service = 'XEPDB1';

// Строка подключения
$conn_str = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$host)(PORT=$port))(CONNECT_DATA=(SERVICE_NAME=$service)))";

// Подключение к базе данных с заданной кодировкой
$conn = oci_connect($user, $password, $conn_str, 'AL32UTF8');

// Проверка соединения
if (!$conn) {
    $error = oci_error();
    die("Ошибка подключения: " . $error['message']);
} else {
    /* echo "Подключение к базе данных Oracle успешно установлено."; */
}
