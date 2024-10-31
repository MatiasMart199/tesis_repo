<?php 
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/Conexion.php";
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/session.php";

$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_acceso= $_POST['id_acceso'];
$id_usuario= $_SESSION['id_usuario'];
$usuario = $_SESSION['usu_login'];
$operacion= $_POST['operacion'];

$grabar = pg_query($conn, "SELECT sp_acceso($id_acceso, $id_usuario, '$usuario', $operacion);");

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