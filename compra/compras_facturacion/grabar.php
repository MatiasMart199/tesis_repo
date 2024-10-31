<?php
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_cc = $_POST['id_cc'];
$cc_fecha = $_POST['cc_fecha'];
$cc_intervalo = $_POST['cc_intervalo'];
$cc_nro_factura = $_POST['cc_nro_factura'];
$cc_timbrado = $_POST['cc_timbrado'];
$cc_tipo_factura = $_POST['cc_tipo_factura'];
$cc_cuota = $_POST['cc_cuota'];
$iva5 = $_POST['iva5'];
$iva10 = $_POST['iva10'];
$exenta = $_POST['exenta'];
$monto = $_POST['monto'];
$saldo = $_POST['saldo'];
$id_sucursal = $_SESSION['id_sucursal'];
$id_deposito = $_POST['id_deposito'];
$id_funcionario = $_SESSION['id_funcionario'];
$id_proveedor = $_POST['id_proveedor'];
$id_item = $_POST['id_item'];
$cantidad = $_POST['cantidad'];
$precio = $_POST['precio'];
$id_corden = $_POST['id_corden'];
$usuario = $_SESSION['usu_login'];
$operacion = $_POST['operacion'];
$grabar = pg_query($conn, "SELECT sp_compras(
                                    $id_cc,
                                    '$cc_fecha',
                                    $cc_intervalo,
                                    '$cc_nro_factura',
                                    '$cc_timbrado',
                                    '$cc_tipo_factura',
                                    $cc_cuota,
                                    $iva5,
                                    $iva10,
                                    $exenta,
                                    $monto,
                                    $saldo,
                                    $id_sucursal,
                                    $id_deposito,
                                    $id_funcionario ,
                                    $id_proveedor,
                                    $id_item,
                                    $cantidad,
                                    $precio,
                                    $id_corden,
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
SELECT public.sp_compras(
    cast(1 as int4),                             -- id_cc
    cast('2024-10-21' as date),                  -- cc_fecha
    cast(1 as int4),                             -- cc_intervalo
    cast('001-001-0000001' as varchar),          -- cc_nro_factura
    cast('12345678' as varchar),                 -- cc_timbrado
    cast('CONTADO' as varchar),                  -- cc_tipo_factura
    cast(1 as int4),                             -- cc_cuota
    cast(5000.0 as numeric),                     -- iva5
    cast(10000.0 as numeric),                    -- iva10
    cast(2000.0 as numeric),                     -- exenta
    cast(150000.0 as numeric),                   -- monto
    cast(50000.0 as numeric),                    -- saldo
    cast(1 as int4),                             -- id_sucursal
    cast(1 as int4),                             -- id_deposito
    cast(1 as int4),                             -- id_funcionario
    cast(1 as int4),                             -- id_proveedor
    cast(3 as int4),                             -- id_item
    cast(10 as int4),                            -- cantidad
    cast(15000 as int4),                         -- precio
    cast(1 as int4),                             -- id_corden
    cast('usuario_prueba' as varchar),           -- usuario
    cast(5 as int4)                              -- operacion
);
*/

