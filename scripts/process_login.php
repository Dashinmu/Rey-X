<?php
require_once "db_connect.php";
?>

<?php
// Проверяем, была ли отправлена форма
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Проверяем, есть ли данные в полях
    if (empty($_POST["username"]) || empty($_POST["password"])) {
        // Если поля пустые, перенаправляем обратно на страницу входа с ошибкой
        header("Location: /login.php?error=empty");
        exit();
    } else {
        // Иначе получаем введенные данные
        $userlogin = $_POST["username"];
        $password = $_POST["password"];

        if (!$conn) {
            // Если не удалось подключиться к базе данных, перенаправляем с ошибкой
            header("Location: /login.php?error=db_connect");
            exit();
        }

        // Формируем запрос на проверку данных пользователя
        $sql = "BEGIN diplom.fnd_user.valid_user( :username, :password, :usertype ); END;";
        $stmt = oci_parse($conn, $sql);
        // Ввод параметров
        oci_bind_by_name($stmt, ':username', $userlogin);
        oci_bind_by_name($stmt, ':password', $password);
        oci_bind_by_name($stmt, ':usertype', $usertype, 1, SQLT_INT);

        // Выполняем запрос
        if (oci_execute($stmt)) {
            if ( $usertype != 0 ) {
                // Если отсутствует ошибка - пользователь найден. Создаём сессию и перенаправляемся на главную
                session_start();
                $_SESSION["userlogin"] = $userlogin;
                $_SESSION["usertype"] = $usertype;
                header("Location: /index.php?access=$usertype");
                exit();
            } else {
                // Если пользователь не найден, перенаправляем обратно на страницу входа с ошибкой
                header("Location: /login.php?error=invalid");
                exit();
            }
        }

        // Закрываем соединение с базой данных
        oci_free_statement($stmt);
        oci_close($conn);
    }
} else {
    // Если форма не была отправлена, перенаправляем на страницу входа
    header("Location: /login.php");
    exit();
}
?>