<?php
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();

$id_deposito = $_POST['id_deposito'] ?? 0;

$sql = "SELECT id_item,stock_cantidad, item_descrip, precio_venta, dep_descrip
        FROM v_stocks s
        WHERE id_sucursal = $1";

$result = pg_query_params($conn, $sql, [$id_deposito]);

$data = [];
while ($row = pg_fetch_assoc($result)) {
    $data[] = $row;
}
//var_dump($data);
echo json_encode($data);
pg_close($conn);
?>
