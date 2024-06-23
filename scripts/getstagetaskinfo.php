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
                SELECT 
                    ti.STAGE_NAME
                    , ti.TASK_NAME
                    , to_char(tr.START_DATE, 'YYYY-MM-DD') as START_DATE
                    , to_char(tr.END_DATE, 'YYYY-MM-DD') as END_DATE
                FROM
                    DIPLOM.TASKS_INFO ti
                    join DIPLOM.TASK_RELATIONS tr
                        on tr.STAGE = ti.STAGE_ID
                        and tr.STAGE = :stage_id
                        and tr.TASK = ti.TASK_ID
                        and tr.TASK = :task_id
                WHERE 1 = 1
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
                            , "stage_mean" => $row['STAGE_NAME']
                            , "task_mean" => $row['TASK_NAME']
                            , "start_date" => $row['START_DATE']
                            , "end_date" => $row['END_DATE']
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