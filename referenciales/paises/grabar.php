<?php 
include '../../deshabilitar_error.php';
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/Conexion.php";
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/session.php";

$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_pais = $_POST['id_pais'];
$pais_descrip = $_POST['pais_descrip'];
$pais_gentilicio = $_POST['pais_gentilicio'];
$pais_codigo = $_POST['pais_codigo']; // Corregido aquí, elimina el | al final.
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];

$grabar = pg_query($conn, "SELECT sp_paises($id_pais, '$pais_descrip', '$pais_gentilicio', '$pais_codigo', '$usuario', $operacion);");

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