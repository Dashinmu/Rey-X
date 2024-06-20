<?php
require_once "sessions.php";
require_once "db_connect.php";
require_once "cursors.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    if ($conn){
        if (
            !empty($_POST["p_stage"]) 
            && !empty($_POST["p_task"])
            && isset($_POST["p_num_task"])
            && isset($_POST["p_start_date"])
            && isset($_POST["p_end_date"])
        ){
            $p_stage = $_POST["p_stage"];
            $p_task = $_POST["p_task"];
            $p_num_task = $_POST["p_num_task"];
            $p_start_date = $_POST["p_start_date"];
            $p_end_date = $_POST["p_end_date"];
    
            $stmt = oci_parse($conn, $connect_task);
            oci_bind_by_name($stmt, ":p_stage", $p_stage);
            oci_bind_by_name($stmt, ":p_task", $p_task);
            oci_bind_by_name($stmt, ":p_num_task", $p_num_task);
            oci_bind_by_name($stmt, ":p_start_date", $p_start_date);
            oci_bind_by_name($stmt, ":p_end_date", $p_end_date);
            oci_bind_by_name($stmt, ":p_error", $p_error, 400, SQLT_CHR);
    
            if (oci_execute($stmt)) {
                if (is_null($p_error)) {
                    echo json_encode(array("message" => 2, "error_message" => "Задание связано."));
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