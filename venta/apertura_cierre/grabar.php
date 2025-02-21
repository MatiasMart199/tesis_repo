<?php
header('Content-type: application/json; charset=utf-8');

// Deshabilitar la salida de errores y registrar en archivo
//include '../../deshabilitar_error.php';
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_vac = $_POST['id_vac'];
$vac_fecha_ape = $_POST['vac_fecha_ape'];
$vac_fecha_cie = $_POST['vac_fecha_cie'];
$vac_monto_efec = $_POST['vac_monto_efec'];
$vac_monto_cheq = $_POST['vac_monto_cheq'];
$vac_monto_tarj = $_POST['vac_monto_tarj'];
$vac_monto_ape = $_POST['vac_monto_ape'];
$vac_monto_cie = $_POST['vac_monto_cie'];
$id_caja = $_POST['id_caja'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_ee = $_POST['id_ee']; //id_ee
$id_fun_solicitante = $_POST['id_fun_solicitante']; //id_ee
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_aperturas_cierres($id_vac, '$vac_fecha_ape','$vac_fecha_cie', $vac_monto_efec, $vac_monto_cheq , $vac_monto_tarj, $vac_monto_ape, $vac_monto_cie, $id_caja, $id_sucursal, $id_funcionario,$id_ee ,$id_fun_solicitante, '$usuario', $operacion);");
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
sp_aperturas_cierres(
    id_vac integer,
    vac_fecha_ape timestamp, 
    vac_fecha_cie timestamp,
    vac_monto_efec numeric,
    vac_monto_cheq numeric,
    vac_monto_tarj numeric,
    vac_monto_ape numeric,
    vac_monto_cie numeric,
    id_caja int,
    
    id_ee,
    id_fun_solicitante,
*/