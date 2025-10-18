<?php 
include '../../deshabilitar_error.php';
require '../../Conexion.php';
require '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_cliente = $_POST['id_cliente'];
$per_nombre = $_POST['per_nombre'];
$per_apellido = $_POST['per_apellido'];
$per_ruc = $_POST['per_ruc'];
$per_ci = $_POST['per_ci'];
$per_direccion = $_POST['per_direccion'];
$per_correo = $_POST['per_correo'];
$per_fenaci = $_POST['per_fenaci'];
$per_telefono = $_POST['per_telefono'];
$id_ciudad = $_POST['id_ciudad'];
$id_ecivil = $_POST['id_ecivil'];
$id_genero = $_POST['id_genero'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];

$grabar = pg_query($conn,"SELECT sp_clientes($id_cliente,
                                            '$per_nombre',
                                            '$per_apellido',
                                            '$per_ruc',
                                            '$per_ci',
                                            '$per_direccion',
                                            '$per_correo',
                                            '$per_fenaci',
                                            '$per_telefono',
                                            $id_ciudad,
                                            $id_ecivil,
                                            $id_genero,
                                            '$usuario',
                                            $operacion);");


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
idcliente integer, 
pernombre character varying, 
perapellido character varying, 
perruc character varying, 
perci character varying, 
perdireccion character varying, 
percorreo character varying, 
perfenaci date, 
pertelefono character varying, 
idciudad integer, 
idecivil integer, 
idgenero integer, 
usuario character varying, 
operacion integer)

*/