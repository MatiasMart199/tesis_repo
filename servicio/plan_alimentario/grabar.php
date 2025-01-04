<?php
header('Content-type: application/json; charset=utf-8');
include '../../deshabilitar_error.php';
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_ali = $_POST['id_ali'];
$ali_fecha = $_POST['ali_fecha'];
$ali_fecha_fin = $_POST['ali_fecha_fin'];
$ali_objetivo = $_POST['ali_objetivo'];
$ali_dias = $_POST['ali_dias'];
$ali_observacion = $_POST['ali_observacion'];
$id_plan_servi = $_POST['id_plan_servi'];
$id_cliente = $_POST['id_cliente'];
$id_nutriologo = $_POST['id_nutriologo'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_act = $_POST['id_act'];
$alimento = $_POST['alimento'];
$cantidad = $_POST['cantidad'];
$calorias = $_POST['calorias'];
$carbohidratos = $_POST['carbohidratos'];
$proteinas = $_POST['proteinas'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_alimentaciones ($id_ali,
                                                '$ali_fecha',
                                                '$ali_fecha_fin',
                                                '$ali_objetivo',
                                                '$ali_dias',
                                                '$ali_observacion',
                                                $id_plan_servi,
                                                $id_cliente,
                                                $id_nutriologo,
                                                $id_sucursal,
                                                $id_funcionario ,
                                                $id_act,
                                                '$alimento',
                                                $cantidad,
                                                $calorias,
                                                $carbohidratos,
                                                $proteinas,
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
id_ali integer, 
ali_fecha date,
ali_fecha_fin date,
ali_objetivo varchar,
ali_dias text,
ali_observacion text, 
id_plan_servi int,
id_cliente integer,
id_nutriologo int,
id_act integer, 
alimento varchar,
cantidad numeric, 
calorias numeric,
carbohidratos numeric,
proteinas numeric,

*/