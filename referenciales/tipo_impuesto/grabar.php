<?php 
include '../../deshabilitar_error.php';
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/Conexion.php";
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/session.php";

$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_tip_impuesto = $_POST['id_tip_impuesto'];
$tip_imp_descrip = $_POST['tip_imp_descrip'];
$tip_imp_tasa = $_POST['tip_imp_tasa'];
$tip_imp_tasa2 = $_POST['tip_imp_tasa2'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];

$grabar = pg_query($conn, "SELECT sp_tipos_impuestos($id_tip_impuesto, '$tip_imp_descrip', $tip_imp_tasa, $tip_imp_tasa2, '$usuario', $operacion);");

$response = array();
if ($grabar) {
    $response['success'] = true;
    $response['message'] =  pg_last_notice($conn);
} else {
    $response['success'] = false;
    $response['message'] = pg_last_error();
}
echo json_encode($response);

/*
sp_tipos_impuestos(
id_tip_impuesto integer, 
tip_imp_descrip character varying, 
tip_imp_tasa numeric,
tip_imp_tasa2 numeric,
operacion integer)
*/
?>