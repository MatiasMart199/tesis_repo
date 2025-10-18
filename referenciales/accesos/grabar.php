<?php 
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/Conexion.php";
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/session.php";

function obtenerIP() {
    if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
        $ip = $_SERVER['HTTP_CLIENT_IP']; // IP compartida por proxy
    } elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $ip = $_SERVER['HTTP_X_FORWARDED_FOR']; // IP pasada por proxy o balanceador
    } else {
        $ip = $_SERVER['REMOTE_ADDR']; // IP real del cliente
    }
    return $ip;
}

$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_usuario= $_SESSION['id_usuario'];
$acc_login = $_POST['acc_login'];
$acc_contrasena = $_POST['acc_contrasena'];
$acc_ip = obtenerIP();
$acc_fecha = date('Y-m-d H:i:s');
$usuario = $_SESSION['usu_login'];

$grabar = pg_query($conn, "SELECT sp_acceso($id_usuario,'$acc_login','$acc_contrasena','$acc_ip','$acc_fecha','$usuario');");

$response = array();
if ($grabar) {
    $response['success'] = true;
    $response['message'] =  pg_last_notice($conn);
} else {
    $response['success'] = false;
    $response['message'] = pg_last_error();
}
echo json_encode($response);

  
 
  
 
?>