<?php
header('Content-type: application/json; charset=utf-8');
include '../../deshabilitar_error.php';
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_inscrip = $_POST['id_inscrip'];
$ins_aprobacion = $_POST['ins_aprobacion'];
$ins_estad_salud = $_POST['ins_estad_salud'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_cliente = $_POST['id_cliente'];
$id_plan_servi = $_POST['id_plan_servi'];
$dia = $_POST['dia'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_servicios_inscripciones($id_inscrip,'$ins_aprobacion','$ins_estad_salud',$id_sucursal,$id_funcionario,$id_cliente,$id_plan_servi,$dia,'$usuario',$operacion);");
$response = array();
if ($grabar) {
    $response['success'] = true;
    $response['message'] =  pg_last_notice($conn);
} else {
    $response['success'] = false;
    $response['message'] = pg_last_error();
}
echo json_encode($response);



