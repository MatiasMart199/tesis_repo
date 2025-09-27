<?php
header('Content-type: application/json; charset=utf-8');
include '../../deshabilitar_error.php';
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_inscrip = $_POST['id_inscrip'];
$ins_aprobacion = $_POST['ins_aprobacion'];
$ins_edad = $_POST['ins_edad'];
$ins_peso = $_POST['ins_peso'];
$ins_altura = $_POST['ins_altura'];
$ins_seguro_medico = $_POST['ins_seguro_medico'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_cliente = $_POST['id_cliente'];
$id_es = $_POST['id_es'];
$id_plan_servi = $_POST['id_plan_servi'];
$dia = $_POST['dia'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_servicios_inscripciones($id_inscrip,'$ins_aprobacion',$ins_edad,$ins_peso,$ins_altura,'$ins_seguro_medico',$id_sucursal,$id_funcionario,$id_cliente,$id_es,$id_plan_servi,$dia,'$usuario',$operacion);");
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
sp_servicios_inscripciones(
id_inscrip, 
ins_aprobacion, 
ins_edad, 
ins_peso,
ins_altura,
ins_seguro_medico,
id_sucursal, 
id_funcionario, 
id_cliente, 
id_es,
id_plan_servi, 
dia, 
usuario character varying, 
operacion integer)
*/

