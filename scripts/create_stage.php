<?php
/* session_start(); */
require_once "sessions.php";
require_once "db_connect.php";
require_once "cursors.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    if ($conn){
        if (
            !empty($_POST["p_meaning"]) 
            && !empty($_POST["p_stage_name"]) 
            && !empty($_POST["p_author"])
        ){
            $p_meaning = $_POST["p_meaning"];
            $p_stage_name = $_POST["p_stage_name"];
            $p_author = $_POST["p_author"];
    
            $stmt = oci_parse($conn, $create_stage);
            oci_bind_by_name($stmt, ":p_meaning", $p_meaning);
            oci_bind_by_name($stmt, ":p_stage_name", $p_stage_name);
            oci_bind_by_name($stmt, ":p_author", $p_author);
            oci_bind_by_name($stmt, ":p_error", $p_error, 400, SQLT_CHR);
    
            if (oci_execute($stmt)) {
                if (is_null($p_error)) {
                    echo json_encode(array("message" => 2, "error_message" => "Этап создан"));
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