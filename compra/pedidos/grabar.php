<?php
header('Content-type: application/json; charset=utf-8');

// Deshabilitar la salida de errores y registrar en archivo
include '../../deshabilitar_error.php';
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_cp = $_POST['id_cp'];
$cp_fecha_aprob = $_POST['cp_fecha_aprob'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_item = $_POST['id_item'];
$cantidad = $_POST['cantidad'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_compras_pedidos($id_cp, '$cp_fecha_aprob', $id_sucursal, $id_funcionario, $id_item, $cantidad, '$usuario', $operacion);");
// if($grabar){
//     echo pg_last_notice($conn);
// }else{
//     echo pg_last_error();
// }

$response = array();
if ($grabar) {
    $response['success'] = true;
    $response['message'] =  pg_last_notice($conn);
} else {
    $response['success'] = false;
    $response['message'] = pg_last_error($conn);
}
echo json_encode($response);
