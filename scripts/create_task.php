<?php
/* session_start(); */
require_once "sessions.php";
require_once "db_connect.php";
require_once "cursors.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    if ($conn){
        if (
            !empty($_POST["p_meaning"]) 
            && !empty($_POST["p_desc"]) 
            && !empty($_POST["p_type"])
            && !empty($_POST["p_author"])
        ){
            $p_meaning = $_POST["p_meaning"];
            $p_desc = $_POST["p_desc"];
            $p_type = $_POST["p_type"];
            $p_author = $_POST["p_author"];
    
            $stmt = oci_parse($conn, $add_task);
            oci_bind_by_name($stmt, ":p_meaning", $p_meaning);
            oci_bind_by_name($stmt, ":p_desc", $p_desc);
            oci_bind_by_name($stmt, ":p_type", $p_type);
            oci_bind_by_name($stmt, ":p_author", $p_author);
            oci_bind_by_name($stmt, ":p_id_task", $p_id_task, 4, SQLT_INT);
            oci_bind_by_name($stmt, ":p_error", $p_error, 400, SQLT_CHR);
    
            if (oci_execute($stmt)) {
                if (is_null($p_error)) {
                    echo json_encode(array("message" => 2, "error_message" => $p_id_task));
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