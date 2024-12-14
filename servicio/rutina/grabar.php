<?php
header('Content-type: application/json; charset=utf-8');

include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_rut = $_POST['id_rut'];
$rut_fecha = $_POST['rut_fecha'];
$rut_edad = $_POST['rut_edad'];
$rut_observacion = $_POST['rut_observacion'];
$id_plan_servi = $_POST['id_plan_servi'];
$id_cliente = $_POST['id_cliente'];
$id_personal = $_POST['id_personal'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_act = $_POST['id_act'];
$serie = $_POST['serie'];
$repeticion = $_POST['repeticion'];
$peso = $_POST['peso'];
$ejercicio = $_POST['ejercicio'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_rutinas ($id_rut,
                                                '$rut_fecha' ,
                                                $rut_edad,
                                                '$rut_observacion',
                                                $id_plan_servi,
                                                $id_cliente,
                                                $id_personal,
                                                $id_sucursal,
                                                $id_funcionario ,
                                                $id_act,
                                                $serie,
                                                $repeticion,
                                                $peso,
                                                '$ejercicio',
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
sp_rutinas(
id_rut integer, 
rut_fecha date, 
rut_edad int,
rut_observacion text, 
id_plan_servi int,
id_cliente integer,
id_personal int,
id_act integer, 
serie int, 
repeticion int,
peso numeric,

*/