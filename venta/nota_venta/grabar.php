<?php
header('Content-type: application/json; charset=utf-8');
include '../../deshabilitar_error.php';
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_not = $_POST['id_not'];
$not_fecha_elab = $_POST['not_fecha_elab'];
$not_fecha_emis = $_POST['not_fecha_emis'];
$not_tipo_nota = $_POST['not_tipo_nota'];
$not_observacion = $_POST['not_observacion'];
$id_vc = $_POST['id_vc'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_cliente = $_POST['id_cliente'];
$id_item = $_POST['id_item'];
$cantidad = $_POST['cantidad'];
$monto = $_POST['monto'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_vent_nota($id_not, 
                                                    '$not_fecha_elab', 
                                                    '$not_fecha_emis', 
                                                    UPPER('$not_tipo_nota'), 
                                                    '$not_observacion',
                                                    $id_vc,
                                                    $id_sucursal, 
                                                    $id_funcionario,
                                                    $id_cliente, 
                                                    $id_item,
                                                    $cantidad, 
                                                    $monto,
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
    $response['message'] = pg_last_error();
}
echo json_encode($response);

/* 
sp_comp_nota(
id_not integer, 
not_fecha date, 
not_fecha_docu date,
not_tipo_nota varchar,
id_vc int,
id_sucursal integer, 
id_funcionario integer, 
id_cliente int,
id_item integer, 
cantidad numeric, 
monto numeric,
usuario character varying, 
operacion integer)
 */