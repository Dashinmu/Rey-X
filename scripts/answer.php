<?php
require_once "db_connect.php";


if (isset($_POST["answer"]) && isset($_POST["task"]) && isset($_POST["user"])) {
    $user = (int)$_POST["user"];
    $answer = $_POST["answer"];
    $task = (int)$_POST["task"];

    if ($conn) {
        $sql = "BEGIN diplom.fnd_tasks.add_answer(:user, :answer, :task, :error, :status); END;";
        $stmt = oci_parse($conn, $sql);
        oci_bind_by_name($stmt, ":user", $user);
        oci_bind_by_name($stmt, ":answer", $answer);
        oci_bind_by_name($stmt, ":task", $task);
        oci_bind_by_name($stmt, ":error", $error, 400, SQLT_CHR);
        oci_bind_by_name($stmt, ":status", $status, 2, SQLT_INT);
    
        if (oci_execute($stmt)) {
            if (is_null($error)) {
                echo json_encode(array("message" => 2, "error_message" => $status));
            } else {
                echo json_encode(array("message" => 1, "error_message" => $error));
            }
        } else {
            echo json_encode(array("message" => 0, "error_message" => "Ошибка в oci_execute."));
        }
    
        oci_free_statement($stmt);
    } else {
        echo json_encode(array("message" => 0, "error_message" => "Ошибка в подключении к БД."));
    }
   
    oci_close($conn);
} else {
    //Вернуть 0 если ошибка в получении параметров
   echo json_encode(array("message" => 0, "error_message" => "Ошибка в получении параметров isset(POST)."));
}
?>