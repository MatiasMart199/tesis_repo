<?php
header('Content-type: application/json; charset=utf-8');
include '../../deshabilitar_error.php';
require_once "{$_SERVER['DOCUMENT_ROOT']}/tesis/Conexion.php";
require_once "{$_SERVER['DOCUMENT_ROOT']}/tesis/session.php";
$conexion = new Conexion();
$conn = $conexion->getConexion();

$id_vc = $_POST['id_vc'];
$vc_fecha = $_POST['vc_fecha'];
$vc_intervalo = $_POST['vc_intervalo'];
$vc_nro_factura = $_POST['vc_nro_factura'];
$vc_tipo_factura = $_POST['vc_tipo_factura'];
$vc_cuota = $_POST['vc_cuota'];
$iva5 = $_POST['iva5'];
$iva10 = $_POST['iva10'];
$exenta = $_POST['exenta'];
$monto = $_POST['monto'];
$saldo = $_POST['saldo'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_tim = $_POST['id_tim'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_cliente = $_POST['id_cliente'];
$id_item = $_POST['id_item'];
$cantidad = $_POST['cantidad'];
$precio = $_POST['precio'];
$id_vped = $_POST['id_vped'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];

$grabar = pg_query($conn, "SELECT sp_ventas(
    $id_vc,
    '$vc_fecha',
    $vc_intervalo,
    '$vc_nro_factura',
    '$vc_tipo_factura',
    $vc_cuota,
    $iva5,
    $iva10,
    $exenta,
    $monto,
    $saldo,
    $id_sucursal,
    $id_tim,
    $id_funcionario ,
    $id_cliente,
    $id_item,
    $cantidad,
    $precio,
    $id_vped,
    '$usuario',
    $operacion);");
    
$response = array();
if ($grabar) {
    $response['success'] = true;
    $response['message'] =  pg_last_notice($conn);
} else {
    $response['success'] = false;
    $response['message'] = pg_last_error($conn);
}
$resul = json_encode($response);
echo $resul;
/*
sp_ventas(
id_vc integer, 
vc_fecha date, 
vc_intervalo integer,
vc_nro_factura varchar,
vc_tipo_factura character varying, 
vc_cuota integer,
iva5 numeric,
iva10 numeric,
exenta numeric,
monto numeric,
saldo numeric,
id_tim integer,
id_cliente integer,
id_item integer, 
cantidad integer, 
precio integer, 
id_vped integer, 
usuario character varying,
operacion integer)
*/

