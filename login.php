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


require_once 'Conexion.php';
session_start();
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

require 'phpmailer/Exception.php';
require 'phpmailer/PHPMailer.php';  
require 'phpmailer/SMTP.php';

//Create an instance; passing `true` enables exceptions
$mail = new PHPMailer(true);


if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['usuario']) && !empty($_POST['contrasena'])) {
    $usuario = trim($_POST['usuario']);
    $contrasena = trim($_POST['contrasena']);
    $hashedPassword = md5($contrasena); // Hash de la contraseña con md5

    $conexion = new Conexion();
    $conn = $conexion->getConexion();

    $query = "SELECT id_usuario, usu_contrasena, per_correo FROM v_usuarios WHERE usu_login = $1";
    $result = pg_query_params($conn, $query, [$usuario]);

    if ($result && $user = pg_fetch_assoc($result)) {
        if ($hashedPassword === $user['usu_contrasena']) {
            $_SESSION['id_usuario'] = $user['id_usuario'];
            $_SESSION['per_correo'] = $user['per_correo'];
            
            $vericationCode = rand(100000, 999999);
            $expirationTime = date("Y-m-d H:i:s", strtotime('+10 minutes'));

            //Guardar codigo para verificar en la base de datos
            $queryUpdate = "UPDATE auth_2fa SET codigo = $1, fecha_expiracion = $2 WHERE id_usuario = $3";
            pg_query_params($conn, $queryUpdate, [$vericationCode, $expirationTime, $_SESSION['id_usuario']]);

            // if (!isset($_SESSION['per_correo']) || empty($_SESSION['per_correo'])) {
            //    $_SESSION['mensaje'] = "Error: La dirección de correo no está configurada correctamente.";
            // } else {
            //     $_SESSION['mensaje'] = "Si llega el correo.";
            // }

            // Enviar el código al correo del usuario (aquí usarías una función de envío de correo)

            try {
                //Server settings
                $mail->SMTPDebug = SMTP::DEBUG_OFF;                      //Enable verbose debug output
                $mail->isSMTP();                                            //Send using SMTP
                $mail->Host       = 'smtp.gmail.com';                     //Set the SMTP server to send through
                $mail->SMTPAuth   = true;                                   //Enable SMTP authentication
                $mail->Username   = 'laragonmathias@gmail.com';                     //SMTP username
                $mail->Password   = 'brkx bipn rexm dceo';                               //SMTP password
                $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;            //Enable implicit TLS encryption
                $mail->Port       = 587;                                    //TCP port to connect to; use 587 if you have set `SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS`

                //Recipients
                $mail->setFrom('laragonmathias@gmail.com', 'ENERGYM');
                $mail->addAddress($_SESSION['per_correo']);     //Add a recipient
                
                 // Ajustar codificación
                $mail->CharSet = 'UTF-8';
                $mail->Encoding = 'base64';

                //Content
                $mail->isHTML(true);                                  //Set email format to HTML
                $mail->Subject = 'Código de Verificación de ENERGYM';
                $mail->Body = 'Tu código de verificación es: ' . $vericationCode;

                $mail->send();
                //$_SESSION['mensaje'] = "Se envió el código a tu correo.";
            } catch (Exception $e) {
                echo "Message could not be sent. Mailer Error: {$mail->ErrorInfo}";
            }

            // Redirigir a la página de verificación
            header('Location: /tesis/autentificacion/index.php');
            exit();
        }
        $_SESSION['mensaje'] = "La contraseña no coincide.";
    } else {
        $_SESSION['mensaje'] = "No existe el usuario.";
    }
    header('Location: /tesis/index.php');
    exit();
} else {
    $_SESSION['mensaje'] = "Credenciales incompletas.";
    header('Location: /tesis/index.php');
    exit();
}
