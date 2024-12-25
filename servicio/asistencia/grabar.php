<?php
header('Content-type: application/json; charset=utf-8');

include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_asi = $_POST['id_asi'];
$asi_entrada = $_POST['asi_entrada'];
$asi_salida = $_POST['asi_salida'];
$id_cliente = $_POST['id_cliente'];
$nombre = $_POST['nombre'];
$id_mem = $_POST['id_mem'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_asistencias ($id_asi,
                                                '$asi_entrada' ,
                                                '$asi_salida',
                                                $id_cliente,
                                                '$nombre',
                                                $id_mem,
                                                $id_sucursal,
                                                $id_funcionario,
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
public.sp_asistencias(
id_asi integer, 
asi_entrada timestamp, 
asi_salida timestamp,
id_cliente integer,
nombre int,
id_mem int,
*/