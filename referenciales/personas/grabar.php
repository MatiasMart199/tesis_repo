<?php 
require '../../Conexion.php';
require '../../session.php';

$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_persona = $_POST['id_persona'];
$per_nombre = $_POST['per_nombre'];
$per_apellido = $_POST['per_apellido'];
$per_ruc = $_POST['per_ruc'];
$per_ci = $_POST['per_ci'];
$per_direccion = $_POST['per_direccion'];
$per_correo = $_POST['per_correo'];
$per_fenaci = $_POST['per_fenaci'];
$per_telefono = $_POST['per_telefono'];
$persona_fisica = $_POST['persona_fisica'];
$id_ciudad = $_POST['id_ciudad'];
$id_ecivil = $_POST['id_ecivil'];
$id_genero = $_POST['id_genero'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];

$grabar = pg_query($conn,"SELECT sp_personas($id_persona,'$per_nombre','$per_apellido','$per_ruc','$per_ci','$per_direccion','$per_correo','$per_fenaci','$per_telefono','$persona_fisica',$id_ciudad,$id_ecivil,$id_genero,'$usuario',$operacion);");

// if ($grabar) {
//     echo pg_last_notice($conn);
// } else {
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
