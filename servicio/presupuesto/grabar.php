<?php
header('Content-type: application/json; charset=utf-8');
// Deshabilitar la salida de errores y registrar en archivo
include '../../deshabilitar_error.php';
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_pre = $_POST['id_pre'];
$pre_fecha = $_POST['pre_fecha'];
$pre_observacion = $_POST['pre_observacion'];
$id_cliente = $_POST['id_cliente'];
$id_personal = $_POST['id_personal'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_act = $_POST['id_act'];
$descrip = $_POST['descrip'];
$costo = $_POST['costo'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_presupuestos_preparacion (
                                                $id_pre,
                                                '$pre_fecha' ,
                                                '$pre_observacion',
                                                $id_cliente,
                                                $id_personal,
                                                $id_sucursal,
                                                $id_funcionario ,
                                                $id_act,
                                                '$descrip',
                                                $costo,
                                                '$usuario',$operacion);");
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
sp_presupuestos_preparacion(
id_pre integer, 
pre_fecha date, 
pre_observacion text,
id_cliente integer,
id_personal int,
id_act integer, 
descrip varchar,
costo numeric, 
*/