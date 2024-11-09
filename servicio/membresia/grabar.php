<?php
header('Content-type: application/json; charset=utf-8');

include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();

$id_mem = $_POST['id_mem'];
$mem_fecha = $_POST['mem_fecha'];
$mem_vence = $_POST['mem_vence'];
$mem_observacion = $_POST['mem_observacion'];
$id_cliente = $_POST['id_cliente'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_plan_servi = $_POST['id_plan_servi'];
$dias = $_POST['dias'];
$precio = $_POST['precio'];
$id_inscrip = $_POST['id_inscrip'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_membresias ($id_mem,
                                                '$mem_fecha' ,
                                                '$mem_vence',
                                                '$mem_observacion',
                                                $id_sucursal,
                                                $id_funcionario ,
                                                $id_cliente,
                                                $id_plan_servi,
                                                $dias,
                                                $precio,
                                                $id_inscrip,
                                                '$usuario',
                                                $operacion);");
$response = array();
if ($grabar) {
    $response['success'] = true;
    $response['message'] =  pg_last_notice($conn);
} else {
    $response['success'] = false;
    $response['message'] = pg_last_error($conn);
}
echo json_encode($response);

/*SELECT public.sp_membresias(
cast(:xid_mem as int4), 
cast(:xmem_fecha as date), 
cast(:xmem_vence as date), 
cast(:xmem_observacion as text), 
cast(:xid_sucursal as int4), 
cast(:xid_funcionario as int4), 
cast(:xid_cliente as int4), 
cast(:xid_plan_servi as int4), 
cast(:xdias as int4), 
cast(:xprecio as int4), 
cast(:xid_inscrip as int4), 
cast(:usuario as varchar), 
cast(:operacion as int4));*/