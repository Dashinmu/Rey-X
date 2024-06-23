<?php
require_once "sessions.php";
require_once "db_connect.php";
require_once "cursors.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    if ($conn){
        if (
            !empty($_POST["task_id"])
            && !empty($_POST["stage_id"]) 
        ){
            $task_id = $_POST["task_id"];
            $stage_id = $_POST["stage_id"];

            $getstageinfo = "
                UPDATE
                SELECT 
                    *
                FROM
                    DIPLOM.TASKS_INFO
                WHERE 1 = 1
                    and TASK_ID = :task_id
                    and STAGE_ID = :stage_id
            ";
    
            $stmt = oci_parse($conn, $getstageinfo);
            oci_bind_by_name($stmt, ":task_id", $task_id);
            oci_bind_by_name($stmt, ":stage_id", $stage_id);
    
            if (oci_execute($stmt)) {
                while ( $row = oci_fetch_array($stmt, OCI_RETURN_NULLS + OCI_ASSOC) ) {
                    echo json_encode(
                        array(
                            "message" => 2
                            , "error_message" => "Данные получены"
                            , "stage_id" => $row['STAGE_ID']
                            , "task_id" => $row['TASK_TYPE']
                            , "task_meaning" => $row['TASK_MEANING']
                            , "task_description" => $row['TASK_DESCRIPTION']
                            , "task_creation_date" => $row['TASK_CREATION_DATE']
                            , "task_inactive_date" => $row['TASK_INACTIVE_DATE']
                            , "author" => $row['AUTHOR_ID']
                            , "answer" => $row['ANSWER']
                        )
                    );
                    unset($row);
                }
                oci_free_statement($stmt);
            } else {
                echo json_encode(array("message" => 0, "error_message" => "Ошибка в oci_execute."));
            }
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