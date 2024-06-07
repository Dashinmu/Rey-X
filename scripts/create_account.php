<?php
/* session_start(); */
require_once "sessions.php";
require_once "db_connect.php";
require_once "cursors.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    if (
        !empty($_POST["login"]) 
        && !empty($_POST["password"]) 
        && !empty($_POST["username"])
        /* && !empty($_POST["email"])
        && !empty($_POST["phone"]) */
        && !empty($_POST["startdate"])
        && !empty($_POST["enddate"])
        && !empty($_POST["access"])
    ){
        if (!$conn) {
            echo "!CONN";
        }

        $p_login = $_POST["login"];
        $p_password = $_POST["password"];
        $p_username = $_POST["username"];
        $p_start_date = $_POST["startdate"];
        $p_end_date = $_POST["enddate"];
        $p_email = $_POST["email"];
        $p_phone = $_POST["phone"];
        if ($_POST["access"] == 1){
            $p_user_type = 2; /* Руководитель */
        } else {
            $p_user_type = 3; /* Студент */
        }

        $stmt = oci_parse($conn, $create_user);
        oci_bind_by_name($stmt, ":p_login", $p_login);
        oci_bind_by_name($stmt, ":p_password", $p_password);
        oci_bind_by_name($stmt, ":p_user_type", $p_user_type);
        oci_bind_by_name($stmt, ":p_username", $p_username);
        oci_bind_by_name($stmt, ":p_email", $p_email);
        oci_bind_by_name($stmt, ":p_phone", $p_phone);
        oci_bind_by_name($stmt, ":p_start_date", $p_start_date);
        oci_bind_by_name($stmt, ":p_end_date", $p_end_date);
        oci_bind_by_name($stmt, ":p_error", $p_error, 200, SQLT_CHR);

        if (oci_execute($stmt)) {
            if (is_null($p_error)) {
                echo json_encode(array("message" => 2, "error_message" => "Пользователь создан"));
            } else {
                echo json_encode(array("message" => 1, "error_message" => $error));
            }
        } else {
            echo json_encode(array("message" => 0, "error_message" => "Ошибка в oci_execute."));
        }

        oci_free_statement($stmt);
    } else {
        echo json_encode(array("message" => 0, "error_message" => "POST ERROR"));
    }

    oci_close($conn);
}

?>