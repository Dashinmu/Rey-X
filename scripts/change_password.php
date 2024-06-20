<?php
require_once "sessions.php";
require_once "db_connect.php";
require_once "cursors.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    if (!empty($_POST["oldPassword"]) && !empty($_POST["newPassword"]) && !empty($_POST["confirmPassword"])) {
        if (!$conn) {
            echo "!CONN";
        }

        $p_password_old = $_POST["oldPassword"];
        $p_password_new = $_POST["newPassword"];
        $p_password_confirm = $_POST["confirmPassword"];

        if ($p_password_new == $p_password_confirm) {

            $stmt = oci_parse($conn, $change_password);
            oci_bind_by_name($stmt, ":p_login", $userlogin);
            oci_bind_by_name($stmt, ":p_password_old", $p_password_old);
            oci_bind_by_name($stmt, ":p_password_new", $p_password_new);
            oci_bind_by_name($stmt, ":p_error", $p_error, 200, SQLT_CHR);
            
            if (oci_execute($stmt)) {
                if (is_null($p_error)) {
                    if (strpos($_SERVER['HTTP_REFERER'], "?") === false) {
                        header("Location: ".$_SERVER['HTTP_REFERER']."?accept=password_change");
                        exit();
                    } else {
                        header("Location: ".substr($_SERVER['HTTP_REFERER'], 0, strpos($_SERVER['HTTP_REFERER'], "?") )."?accept=password_change");
                        exit();
                    }
                } else {
                    if (strpos($_SERVER['HTTP_REFERER'], "?") === false) {
                        header("Location: ".$_SERVER['HTTP_REFERER']."?error=auth_not_match");
                        exit();
                    } else {
                        header("Location: ".substr($_SERVER['HTTP_REFERER'], 0, strpos($_SERVER['HTTP_REFERER'], "?") )."?error=auth_not_match");
                        exit();
                    }
                }
            } else {
                if (strpos($_SERVER['HTTP_REFERER'], "?") === false) {
                    header("Location: ".$_SERVER['HTTP_REFERER']."?error=cancel_execute");
                    exit();
                } else {
                    header("Location: ".substr($_SERVER['HTTP_REFERER'], 0, strpos($_SERVER['HTTP_REFERER'], "?") )."?error=cancel_execute");
                    exit();
                }
            }
        } else {
            if (strpos($_SERVER['HTTP_REFERER'], "?") === false) {
                header("Location: ".$_SERVER['HTTP_REFERER']."?error=password_not_match");
                exit();
            } else {
                header("Location: ".substr($_SERVER['HTTP_REFERER'], 0, strpos($_SERVER['HTTP_REFERER'], "?") )."?error=password_not_match");
                exit();
            }
        }

    }
} else {
    if (strpos($_SERVER['HTTP_REFERER'], "?") === false) {
        header("Location: ".$_SERVER['HTTP_REFERER']."?error=method_error");
        exit();
    } else {
        header("Location: ".substr($_SERVER['HTTP_REFERER'], 0, strpos($_SERVER['HTTP_REFERER'], "?") )."?error=method_error");
        exit();
    }
}
?>