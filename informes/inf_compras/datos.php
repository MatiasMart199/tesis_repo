<?php
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();

$fecha_inicio = $_POST['fecha_inicio'] ?? null;
$fecha_fin = $_POST['fecha_fin'] ?? null;

// Verificar si las fechas están vacías o son nulas
$filtro_fecha = "";
$parametros = [];

if (!empty($fecha_inicio) && !empty($fecha_fin)) {
    $filtro_fecha = "AND cc_fecha BETWEEN $1 AND $2";
    $parametros = array($fecha_inicio, $fecha_fin);
}

$sql = "SELECT id_cc, proveedor, fecha, monto_total, cc_tipo_factura,cc_nro_factura
        FROM v_compras_cab WHERE estado = 'CONFIRMADO' " . $filtro_fecha . " 
        ORDER BY id_cc ASC";

if (!empty($parametros)) {
    $result = pg_query_params($conn, $sql, $parametros);
} else {
    $result = pg_query($conn, $sql);
}

$data = [];
while ($row = pg_fetch_assoc($result)) {
    // ✅ CORRECTO: Mantener claves asociativas
    $data[] = [
        'id_cc' => $row['id_cc'],
        'cc_nro_factura' => $row['cc_nro_factura'],
        'cc_tipo_factura' => $row['cc_tipo_factura'],
        'proveedor' => $row['proveedor'],
        'fecha' => $row['fecha'],
        'monto_total' => number_format($row['monto_total'], 0, ',', '.')
    ];
}

echo json_encode($data);
pg_close($conn);
?>
