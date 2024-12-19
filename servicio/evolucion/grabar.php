<?php
header('Content-type: application/json; charset=utf-8');
// Deshabilitar la salida de errores y registrar en archivo
include '../../deshabilitar_error.php';
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_evo = $_POST['id_evo'];
$evo_fecha = $_POST['evo_fecha'];
$evo_edad = $_POST['evo_edad'];
$evo_observacion = $_POST['evo_observacion'];
$evo_imc = $_POST['evo_imc'];
$evo_pgc = $_POST['evo_pgc'];
$id_cliente = $_POST['id_cliente'];
$id_personal = $_POST['id_personal'];
$id_med = $_POST['id_med'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_act = $_POST['id_act'];
$valor = $_POST['valor'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_evoluciones ($id_evo,
                                                '$evo_fecha' ,
                                                $evo_edad,
                                                '$evo_observacion',
                                                $evo_imc,
                                                $evo_pgc,
                                                $id_cliente,
                                                $id_personal,
                                                $id_med,
                                                $id_sucursal,
                                                $id_funcionario ,
                                                $id_act,
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



/*
sp_evoluciones(
id_evo integer, 
evo_fecha date, 
evo_edad int,
evo_observacion text, 
evo_imc numeric,
evo_pgc numeric,
id_cliente integer,
id_personal int,
id_med int,
id_act integer, 
valor numeric, 
*/