<?php
// if(isset($_POST['usuario']) && isset($_POST['contrasena'])){
//     echo"SE RECIBIERON LOS PARAMETROS";
//     echo "<br><br>El usuario es: ".$_POST['usuario'];
//     echo "<br><br>La contraseña es : ".$_POST['contrasena'];
// }else{
//     echo"NO SE RECIBIERON LOS PARAMETROS";
// }

// if(isset($_POST['usuario']) && isset($_POST['contrasena'])){
//     require_once('Conexion.php');
//     $conexion = new Conexion();
//     $conn= $conexion->getConexion();
//     $usu= $_POST['usuario'];
//     $contra=$_POST['contrasena'];
//     $resul= pg_fetch_all(pg_query($conn, "select * from usuarios where usu_login = trim('$usu');"));
//     if (empty($resul)) {
//         echo "NO EXITE ESTE USUARIO";
//     } else {
//         echo "EXITE ESTE USUARIO EL USUARIO: $usu Y CONTRASEÑA $contra";
//     }

// }else{
//     header('Location: /conexionphp');
// }
// session_start();
// if(isset($_POST['usuario']) && isset($_POST['contrasena'])){
//     require_once('Conexion.php');
//     $conexion = new Conexion();
//     $conn= $conexion->getConexion();
//     $usu= $_POST['usuario'];
//     $contra=$_POST['contrasena'];
//     $resul= pg_fetch_all(pg_query($conn, "select * from usuarios where usu_login = trim('$usu');"));

//     if (empty($resul)) {    //SI NO EXISTE EL USUARIO
//         $_SESSION['mensaje']="NO EXISTE EL USUARIO";
//         header('Location: /tesis');
//     } else {

//         if($resul[0]['usu_contrasena'] == md5($contra)){
//             $_SESSION['id_usuario']= $resul[0]['id_usuario'];
//             header('Location: /tesis/inicio.php');


//         }else{ //SI LA CONTRASEÑA NO COINCIDE
//             $_SESSION['mensaje']="LA CONTRASEÑA NO COINCIDE";
//             header('Location: /tesis');
//         }
//     }

// }else{//SI NO LLEGA LOS PARAMETROS
//     $_SESSION['mensaje']="NO LLEGA LOS PARAMETROS";
//     header('Location: /tesis');
// }


// session_start();
// if (isset($_POST['usuario']) && isset($_POST['contrasena'])) {
//     require_once('Conexion.php');
//     $conexion = new Conexion();
//     $conn = $conexion->getConexion();
//     $usu = $_POST['usuario'];
//     $contra = $_POST['contrasena'];

//     $resul = pg_fetch_all(pg_query($conn, "SELECT * FROM usuarios WHERE usu_login = trim('$usu');"));
//     if (empty($resul)) {    // SI NO EXISTE EL USUARIO
//         $_SESSION['mensaje'] = "NO EXISTE EL USUARIO";
//         header('Location: /tesis');

//     } else {
//         if ($resul[0]['usu_contrasena'] == md5($contra)) {
//             $_SESSION['id_usuario'] = $resul[0]['id_usuario'];
//             header('Location: /tesis/inicio.php');

//         } else { // SI LA CONTRASEÑA NO COINCIDE
//             $_SESSION['mensaje'] = "LA CONTRASEÑA NO COINCIDE";
//             header('Location: /tesis');

//         }
//     }
// } 


//require_once 'Conexion.php';
//session_start();
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

require 'phpmailer/Exception.php';
require 'phpmailer/PHPMailer.php';  
require 'phpmailer/SMTP.php';

//Create an instance; passing `true` enables exceptions
$mail = new PHPMailer(true);

require "{$_SERVER['DOCUMENT_ROOT']}/tesis/Conexion.php";
//require "{$_SERVER['DOCUMENT_ROOT']}/tesis/session.php";

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['usuario']) && !empty($_POST['contrasena'])) {
    $usuario = trim($_POST['usuario']);
    $contrasena = trim($_POST['contrasena']);
    $hashedPassword = md5($contrasena);

    $conexion = new Conexion();
    $conn = $conexion->getConexion();

    // 🔹 Obtener IP del cliente
    function obtenerIP() {
        if (!empty($_SERVER['HTTP_CLIENT_IP'])) return $_SERVER['HTTP_CLIENT_IP'];
        if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) return $_SERVER['HTTP_X_FORWARDED_FOR'];
        return $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
    }

    $ip = obtenerIP();
    $fecha = date('Y-m-d H:i:s');
    $id_usuario = null;
    $usu_login = null;

    $query = "SELECT id_usuario, usu_contrasena, per_correo, usu_login FROM v_usuarios WHERE usu_login = $1";
    $result = pg_query_params($conn, $query, [$usuario]);

    if ($result && $user = pg_fetch_assoc($result)) {
        if ($hashedPassword === $user['usu_contrasena']) {
            // ✅ Login correcto
            $id_usuario = $user['id_usuario'];
            $usu_login = $user['usu_login'];
            $_SESSION['id_usuario'] = $id_usuario;
            $_SESSION['per_correo'] = $user['per_correo'];

            // 🔸 Registrar acceso correcto
            pg_query_params($conn,
                "SELECT sp_acceso($1, $2, $3, $4, $5, $6)",
                [$id_usuario, $usuario, $contrasena, $ip, $fecha, $usu_login]
            );

            $vericationCode = rand(100000, 999999);
            $expirationTime = date("Y-m-d H:i:s", strtotime('+10 minutes'));

            $queryUpdate = "UPDATE auth_2fa SET codigo = $1, fecha_expiracion = $2 WHERE id_usuario = $3";
            pg_query_params($conn, $queryUpdate, [$vericationCode, $expirationTime, $id_usuario]);

            try {
                $mail->SMTPDebug = SMTP::DEBUG_OFF;
                $mail->isSMTP();
                $mail->Host = 'smtp.gmail.com';
                $mail->SMTPAuth = true;
                $mail->Username = 'laragonmathias@gmail.com';
                $mail->Password = 'crvu yisr zyai jhka';
                $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
                $mail->Port = 587;
                $mail->setFrom('laragonmathias@gmail.com', 'ENERGYM');
                $mail->addAddress($_SESSION['per_correo']);
                $mail->CharSet = 'UTF-8';
                $mail->Encoding = 'base64';
                $mail->isHTML(true);
                $mail->Subject = 'Código de Verificación de ENERGYM';
                $mail->Body = 'Tu código de verificación es: ' . $vericationCode;
                $mail->send();
            } catch (Exception $e) {
                echo "Mailer Error: {$mail->ErrorInfo}";
            }

            header('Location: /tesis/autentificacion/index.php');
            exit();
        }

        // ❌ Contraseña incorrecta
        pg_query_params($conn,
            "SELECT sp_acceso(NULL, $1, $2, $3, $4, $5)",
            [$usuario, $contrasena, $ip, $fecha, null]
        );
        $_SESSION['mensaje'] = "La contraseña no coincide.";

    } else {
        // ❌ Usuario no existe
        pg_query_params($conn,
            "SELECT sp_acceso(NULL, $1, $2, $3, $4, $5)",
            [$usuario, $contrasena, $ip, $fecha, null]
        );
        $_SESSION['mensaje'] = "No existe el usuario.";
    }

    header('Location: /tesis/index.php');
    exit();

} else {
    $_SESSION['mensaje'] = "Credenciales incompletas.";
    header('Location: /tesis/index.php');
    exit();
}
?>
