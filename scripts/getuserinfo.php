<?php
/* session_start(); */
require_once "sessions.php";
require_once "db_connect.php";
require_once "cursors.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    if ($conn){
        if (
            !empty($_POST["user_id"]) 
        ){
            $user_id = $_POST["user_id"];

            $getuserinfo = "
                SELECT 
                    USER_ID
                    , USER_NAME
                    , USER_MAIL
                    , USER_PHONE
                    , to_char(USER_START_DATE, 'YYYY-MM-DD') as USER_START_DATE
                    , to_char(USER_INACTIVE_DATE, 'YYYY-MM-DD') as USER_INACTIVE_DATE
                    , USER_TYPE
                    , USER_LOGIN
                FROM
                    DIPLOM.PERSONAL_INFO 
                WHERE 1 = 1
                    and USER_ID = :p_user
            ";
    
            $stmt = oci_parse($conn, $getuserinfo);
            oci_bind_by_name($stmt, ":p_user", $user_id);
    
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
                            , "login" => $row['USER_LOGIN']
                            , "name" => $row['USER_NAME']
                            , "startdate" => $row['USER_START_DATE']
                            , "enddate" => $row['USER_INACTIVE_DATE']
                            , "email" => $row['USER_MAIL']
                            , "phone" => $row['USER_PHONE']
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