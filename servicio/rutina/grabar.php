<?php
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_cpre = $_POST['id_cpre'];
$cpre_fecha = $_POST['cpre_fecha'];
$cpre_validez = $_POST['cpre_validez'];
$cpre_numero = $_POST['cpre_numero'];
$cpre_observacion = $_POST['cpre_observacion'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_proveedor = $_POST['id_proveedor'];
$id_item = $_POST['id_item'];
$cantidad = $_POST['cantidad'];
$precio = $_POST['precio'];
$id_cp = $_POST['id_cp'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_compras_presupuestos ($id_cpre,'$cpre_fecha' ,'$cpre_validez',$cpre_numero,'$cpre_observacion',$id_sucursal,$id_funcionario ,$id_proveedor,$id_item,$cantidad,$precio,$id_cp,'$usuario',$operacion);");
$response = array();
if ($grabar) {
    $response['success'] = true;
    $response['message'] =  pg_last_notice($conn);
} else {
    $response['success'] = false;
    $response['message'] = pg_last_error();
}
echo json_encode($response);


