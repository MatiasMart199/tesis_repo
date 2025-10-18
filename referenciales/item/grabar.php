<?php 
include '../../deshabilitar_error.php';
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/Conexion.php";
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/session.php";

$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_item = $_POST['id_item'];
$item_descrip = $_POST['item_descrip'];
$precio_compra = $_POST['precio_compra'];
$precio_venta = $_POST['precio_venta'];
$id_mar = $_POST['id_mar'];
$id_tip_item = $_POST['id_tip_item']; 
$id_tip_impuesto = $_POST['id_tip_impuesto']; 
$item_concepto = $_POST['item_concepto']; 
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];

$grabar = pg_query($conn, "SELECT * FROM sp_items(
    $id_item, 
    '$item_descrip', 
    $precio_compra, 
    $precio_venta, 
    $id_mar,
    $id_tip_item,
    $id_tip_impuesto,
    '$item_concepto',
    '$usuario', 
    $operacion);");

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