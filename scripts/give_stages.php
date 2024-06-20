<?php
/* session_start(); */
require_once "sessions.php";
require_once "db_connect.php";
require_once "cursors.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    if ($conn){
        if (
            !empty($_POST["p_stage"]) 
            && !empty($_POST["p_student"]) 
            && !empty($_POST["p_user"])
        ){
            $p_stage = $_POST["p_stage"];
            $p_student = $_POST["p_student"];
            $p_user = $_POST["p_user"];

            $query = "
                BEGIN 
                    DIPLOM.FND_TASKS.give_stage(
                        P_USER => :p_user
                        , P_STAGE => :p_stage
                        , P_STUDENT => :p_student
                        , P_ERROR => :p_error
                    );
                END;
            ";
    
            $stmt = oci_parse($conn, $query);
            oci_bind_by_name($stmt, ":p_user", $p_user);
            oci_bind_by_name($stmt, ":p_stage", $p_stage);
            oci_bind_by_name($stmt, ":p_student", $p_student);
            oci_bind_by_name($stmt, ":p_error", $p_error, 400, SQLT_CHR);
    
            if (oci_execute($stmt)) {
                if (is_null($p_error)) {
                    echo json_encode(array("message" => 2, "error_message" => "Этап выдан"));
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