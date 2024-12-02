<?php
header('Content-type: application/json; charset=utf-8');

include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_med = $_POST['id_med'];
$med_fecha = $_POST['med_fecha'];
$med_edad = $_POST['med_edad'];
$med_observacion = $_POST['med_observacion'];
$id_cliente = $_POST['id_cliente'];
$id_personal = $_POST['id_personal'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_tip_med = $_POST['id_tip_med'];
$valor = $_POST['valor'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_mediciones ($id_med,
                                                '$med_fecha' ,
                                                $med_edad,
                                                '$med_observacion',
                                                $id_cliente,
                                                $id_personal,
                                                $id_sucursal,
                                                $id_funcionario ,
                                                $id_tip_med,
                                                $valor,
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



