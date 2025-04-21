<?php
header('Content-type: application/json; charset=utf-8');

// Deshabilitar la salida de errores y registrar en archivo
//include '../../deshabilitar_error.php';
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_cob = $_POST['id_cob'];
$cob_fecha = $_POST['cob_fecha'];
$id_vac = $_POST['id_vac'];
$id_caja = $_POST['id_caja'];
$id_vc = $_POST['id_vc'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_cue = $_POST['id_cue'];
$id_fc = $_POST['id_fc'];
$cob_monto_efe = $_POST['cob_monto_efe'];
$monto = $_POST['monto'];
$che_nro_cheque = $_POST['che_nro_cheque'];
$che_vencimiento = $_POST['che_vencimiento'];
$che_monto = $_POST['che_monto'];
$che_tipo_cheque = $_POST['che_tipo_cheque'];
$id_ee = $_POST['id_ee'];
$id_ee_des = $_POST['id_ee_des'];
$tar_nro_tarjeta = $_POST['tar_nro_tarjeta'];
$tar_vencimiento = $_POST['tar_vencimiento'];
$tar_monto = $_POST['tar_monto'];
$id_mt = $_POST['id_mt'];
$tra_nro_cuenta = $_POST['tra_nro_cuenta'];
$tra_monto = $_POST['tra_monto'];
$tra_motivo = $_POST['tra_motivo'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_vent_cobros($id_cob, 
                                                '$cob_fecha', 
                                                $id_vac, 
                                                $id_caja,
                                                $id_vc,
                                                $id_sucursal, 
                                                $id_funcionario, 
                                                $id_cue,                
                                                $id_fc, 
                                                $cob_monto_efe, 
                                                $monto,
                                                '$che_nro_cheque',
                                                '$che_vencimiento',
                                                $che_monto,
                                                '$che_tipo_cheque',
                                                $id_ee,
                                                $id_ee_des,
                                                '$tar_nro_tarjeta',
                                                '$tar_vencimiento',
                                                $tar_monto,
                                                $id_mt,
                                                '$tra_nro_cuenta',  
                                                $tra_monto,
                                                '$tra_motivo',
                                                '$usuario', $operacion);");


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
CREATE OR REPLACE FUNCTION public.sp_vent_cobros(
id_cob integer, 
cob_fecha timestamp, 
id_vac int,
id_caja int,
id_vc int,
id_cue int,
id_fc integer, 
cob_monto_efe numeric, 
monto numeric,
che_nro_cheque varchar,
che_vencimiento date,
che_monto numeric,
che_tipo_cheque varchar,
id_ee int,
id_ee_des int,
tar_nro_tarjeta varchar,
tar_vencimiento date,
tar_monto numeric,
id_mt int,
tra_nro_cuenta varchar,
tra_monto numeric,
tra_motivo varchar,
*/