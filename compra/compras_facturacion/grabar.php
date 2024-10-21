<?php
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_corden = $_POST['id_corden'];
$ord_fecha = $_POST['ord_fecha'];
$ord_intervalo = $_POST['ord_intervalo'];
$ord_tipo_factura = $_POST['ord_tipo_factura'];
$ord_cuota = $_POST['ord_cuota'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_proveedor = $_POST['id_proveedor'];
$id_item = $_POST['id_item'];
$cantidad = $_POST['cantidad'];
$precio = $_POST['precio'];
$id_cpre = $_POST['id_cpre'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_compras_ordenes ($id_corden,'$ord_fecha' ,'$ord_intervalo','$ord_tipo_factura','$ord_cuota',$id_sucursal,$id_funcionario ,$id_proveedor,$id_item,$cantidad,$precio,$id_cpre,'$usuario',$operacion);");

$response = array();
if ($grabar) {
    $response['success'] = true;
    $response['message'] =  pg_last_notice($conn);
} else {
    $response['success'] = false;
    $response['message'] = pg_last_error();
}
echo json_encode($response);

