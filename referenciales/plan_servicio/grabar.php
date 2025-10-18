<?php 
include '../../deshabilitar_error.php';
require '../../Conexion.php';
require '../../session.php';

$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_ciudad= $_POST['id_ciudad'];
$ciu_descrip= $_POST['ciu_descrip'];
$id_pais= $_POST['id_pais'];
$operacion= $_POST['operacion'];

$grabar = pg_query($conn,"select sp_ciudades ($id_ciudad, '$ciu_descrip', $id_pais, $operacion);");

$response = array();
if ($grabar) {
    $response['success'] = true;
    $response['message'] =  pg_last_notice($conn);
} else {
    $response['success'] = false;
    $response['message'] = pg_last_error();
}
echo json_encode($response);

