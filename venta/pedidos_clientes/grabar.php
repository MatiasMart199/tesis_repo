<?php
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_vped = $_POST['id_vped'];
$vped_aprobacion = $_POST['vped_aprobacion'];
$vped_observacion = $_POST['vped_observacion'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_cliente = $_POST['id_cliente'];
$id_item = $_POST['id_item'];
$cantidad = $_POST['cantidad'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_ventas_pedidos($id_vped,'$vped_aprobacion','$vped_observacion',$id_sucursal,$id_funcionario,$id_cliente,$id_item,$cantidad,'$usuario',$operacion);");
$response = array();
if ($grabar) {
    $response['success'] = true;
    $response['message'] =  pg_last_notice($conn);
} else {
    $response['success'] = false;
    $response['message'] = pg_last_error();
}
echo json_encode($response);



