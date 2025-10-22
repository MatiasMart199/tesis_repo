<?php
header('Content-type: application/json; charset=utf-8');
include '../../deshabilitar_error.php';
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_tra = $_POST['id_tra'];
$tra_fecha_elabo = $_POST['tra_fecha_elabo'];
$tra_fecha_salida = $_POST['tra_fecha_salida'];
$tra_fecha_recep = $_POST['tra_fecha_recep'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_sucursal_ori = $_POST['id_sucursal_ori'];
$id_sucursal_des = $_POST['id_sucursal_des'];
$id_deposito_ori = $_POST['id_deposito_ori'];
$id_deposito_des = $_POST['id_deposito_des'];
$id_vehiculo = $_POST['id_vehiculo'];
$id_chofer = $_POST['id_chofer'];
$observacion = $_POST['observacion'];
$id_item = $_POST['id_item'];
$cantidad = $_POST['cantidad'];

$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_comp_transfers(
                                                    $id_tra, 
                                                    '$tra_fecha_elabo', 
                                                    '$tra_fecha_salida', 
                                                    '$tra_fecha_recep', 
                                                    $id_sucursal, 
                                                    $id_funcionario, 
                                                    $id_sucursal_ori, 
                                                    $id_sucursal_des, 
                                                    $id_deposito_ori, 
                                                    $id_deposito_des, 
                                                    $id_vehiculo, 
                                                    $id_chofer, 
                                                    '$observacion',
                                                    $id_item, 
                                                    $cantidad, 
                                                    '$usuario',
                                                    $operacion);");
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

/*
sp_comp_transfers(
id_tra integer, 
tra_fecha_elabo date, 
tra_fecha_salida date,
tra_fecha_recep date,
id_sucursal integer,
id_funcionario integer, 
id_sucursal_ori int,
id_sucursal_des int,
id_deposito_ori int,
id_deposito_des int,
id_vehiculo int,
id_chofer int,
observacion text,
id_item integer, 
cantidad int, 

usuario character varying, 
operacion integer
*/