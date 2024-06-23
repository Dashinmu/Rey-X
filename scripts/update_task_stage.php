<?php
require_once "sessions.php";
require_once "db_connect.php";
require_once "cursors.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    if ($conn){
        if (
            !empty($_POST["task_id"])
            && !empty($_POST["stage_id"]) 
            && !empty($_POST["start_date"]) 
            && !empty($_POST["end_date"]) 
        ){
            $task_id = $_POST["task_id"];
            $stage_id = $_POST["stage_id"];
            $start_date = $_POST["start_date"];
            $end_date = $_POST["end_date"];

            $query = "
                BEGIN
                    DIPLOM.FND_TASK.UPDATE_CONNECT_STAGE_TASK(
                        p_task => :p_task
                        , p_stage => :p_stage
                        , p_start_date => :p_start_date
                        , p_end_date => :p_end_date
                        , p_error => :p_error
                    );
                END;
            ";
    
            $stmt = oci_parse($conn, $query);
            oci_bind_by_name($stmt, ":p_task", $task_id);
            oci_bind_by_name($stmt, ":p_stage", $stage_id);
            oci_bind_by_name($stmt, ":p_start_date", $start_date);
            oci_bind_by_name($stmt, ":p_end_date", $end_date);
            oci_bind_by_name($stmt, ":p_error", $p_error, 400, SQLT_CHR);
    
            if (oci_execute($stmt)) {
                if (is_null($p_error)) {
                    echo json_encode(array("message" => 2, "error_message" => "Данные обновлены!"));
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