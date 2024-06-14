<?php
/* session_start(); */
require_once "sessions.php";
require_once "db_connect.php";
require_once "cursors.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    if ($conn){
        if (
            !empty($_POST["task_id"]) 
        ){
            $task_id = $_POST["task_id"];

            $gettaskinfo = "
                SELECT 
                    TASK_ID
                    , TASK_TYPE_ID
                    , TASK_TYPE
                    , TASK_MEANING
                    , TASK_DESCRIPTION
                    , to_char(TASK_CREATION_DATE, 'YYYY-MM-DD') as TASK_CREATION_DATE
                    , to_char(TASK_INACTIVE_DATE, 'YYYY-MM-DD') as TASK_INACTIVE_DATE
                    , AUTHOR_ID
                    , AUTHOR
                    , ANSWER
                FROM
                    DIPLOM.ALL_TASKS 
                WHERE 1 = 1
                    and TASK_ID = :task_id
            ";
    
            $stmt = oci_parse($conn, $gettaskinfo);
            oci_bind_by_name($stmt, ":task_id", $task_id);
    
            if (oci_execute($stmt)) {
                while ( $row = oci_fetch_array($stmt, OCI_RETURN_NULLS + OCI_ASSOC) ) {
                    /* $name = $row['USER_NAME'];
                    $startdate = $row['USER_START_DATE'];
                    $enddate = $row['USER_INACTIVE_DATE'];
                    $email = $row['USER_MAIL'];
                    $phone = $row['USER_PHONE']; */
                    echo json_encode(
                        array(
                            "message" => 2
                            , "error_message" => "Данные получены"
                            , "task_type_id" => $row['TASK_TYPE_ID']
                            , "task_type" => $row['TASK_TYPE']
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