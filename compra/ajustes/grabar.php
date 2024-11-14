<?php
header('Content-type: application/json; charset=utf-8');

include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_caju = $_POST['id_caju'];
$aju_fecha = $_POST['aju_fecha'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_deposito = $_POST['id_deposito'];
$id_motivo = $_POST['id_motivo'];
$mot_tipo_ajuste = $_POST['mot_tipo_ajuste'];
$mot_descrip = $_POST['mot_descrip'];
$id_item = $_POST['id_item'];
$cantidad = $_POST['cantidad'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_comp_ajustes(
                                            $id_caju, 
                                            '$aju_fecha', 
                                            $id_sucursal, 
                                            $id_funcionario,
                                            $id_deposito,
                                            $id_motivo,
                                            UPPER('$mot_tipo_ajuste'),
                                            '$mot_descrip', 
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
    $response['message'] = pg_last_error();
}
echo json_encode($response);

/*
sp_comp_ajustes(
id_caju integer, 
aju_fecha date, 
id_deposito int,
id_motivo INT,
mot_tipo_ajuste varchar,
mot_descrip varchar,
id_item integer, 
cantidad integer, 

 */