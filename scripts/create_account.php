<?php
require_once "sessions.php";
require_once "db_connect.php";
require_once "cursors.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    if ($conn){
        if (
            !empty($_POST["p_login"]) 
            && !empty($_POST["p_username"]) 
            && !empty($_POST["p_password"])
            /* && !empty($_POST["email"])
            && !empty($_POST["phone"]) */
            /* && !empty($_POST["p_start_date"])
            && !empty($_POST["p_end_date"]) */
            && !empty($_POST["p_user_type"])
            && !empty($_POST["p_user"])
            && isset($_POST["p_give_stage"])
        ){
            $p_login = $_POST["p_login"];
            $p_password = $_POST["p_password"];
            $p_username = $_POST["p_username"];
            $p_start_date = $_POST["p_start_date"];
            $p_end_date = $_POST["p_end_date"];
            $p_email = $_POST["p_email"];
            $p_phone = $_POST["p_phone"];
            $p_user = $_POST["p_user"];
            $p_give_stage = $_POST["p_give_stage"];
            if ($_POST["p_user_type"] == 1){
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
            oci_bind_by_name($stmt, ":p_user", $p_user);
            oci_bind_by_name($stmt, ":p_stage", $p_give_stage);
            oci_bind_by_name($stmt, ":p_error", $p_error, 400, SQLT_CHR);
    
            if (oci_execute($stmt)) {
                if (is_null($p_error)) {
                    echo json_encode(array("message" => 2, "error_message" => "Пользователь создан"));
                } else {
                    echo json_encode(array("message" => 1, "error_message" => $p_error));
                }
            } else {
                echo json_encode(array("message" => 0, "error_message" => "Ошибка в oci_execute."));
            }
    
            oci_free_statement($stmt);
        } else {
            echo json_encode(array("message" => 0, "error_message" => "POST ERROR"));
        }

        oci_close($conn);
    } else {
        echo json_encode(array("message" => 0, "error_message" => "CONN ERROR"));
    }

}

?>