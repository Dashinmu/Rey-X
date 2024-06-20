<?php
require_once "sessions.php";
require_once "db_connect.php";
require_once "cursors.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    if ($conn){
        if (
            !empty($_POST["task_meaning"])
            && !empty($_POST["task_descrip"]) 
            && !empty($_POST["task_type_id"])
            && isset($_POST["task_creation_date"])
            && isset($_POST["task_inactive_date"])
            && !empty($_POST["task_answer"])
            && !empty($_POST["task_id"])
            && !empty($_POST["user_id"])
        ){
            $task_meaning = $_POST["task_meaning"];
            $task_descrip = $_POST["task_descrip"];
            $task_type_id = $_POST["task_type_id"];
            $task_creation_date = $_POST["task_creation_date"];
            $task_inactive_date = $_POST["task_inactive_date"];
            $task_answer = $_POST["task_answer"];
            $task_id = $_POST["task_id"];
            $p_user = $_POST["user_id"];
    
            $stmt = oci_parse($conn, $update_task);
            oci_bind_by_name($stmt, ":p_task_id", $task_id);
            oci_bind_by_name($stmt, ":p_task_meaning", $task_meaning);
            oci_bind_by_name($stmt, ":p_task_descrip", $task_descrip);
            oci_bind_by_name($stmt, ":p_task_type_id", $task_type_id);
            oci_bind_by_name($stmt, ":p_task_start_date", $task_creation_date);
            oci_bind_by_name($stmt, ":p_task_end_date", $task_inactive_date);
            oci_bind_by_name($stmt, ":p_task_answer", $task_answer);
            oci_bind_by_name($stmt, ":p_user", $p_user);
            oci_bind_by_name($stmt, ":p_error", $p_error, 400, SQLT_CHR);
    
            if (oci_execute($stmt)) {
                if (is_null($p_error)) {
                    echo json_encode(array("message" => 2, "error_message" => "Данные задания обновлены!"));
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

} else {
    echo json_encode(array("message" => 0, "error_message" => "REQUEST ERROR"));
}
?>