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
    $filtro_fecha = "AND mem_fecha BETWEEN $1 AND $2";
    $parametros = array($fecha_inicio, $fecha_fin);
}

$sql = "SELECT id_mem, cliente, fecha, monto_total
        FROM v_serv_membresias_cab WHERE estado = 'CONFIRMADO' " . $filtro_fecha . " 
        ORDER BY id_mem ASC";

if (!empty($parametros)) {
    $result = pg_query_params($conn, $sql, $parametros);
} else {
    $result = pg_query($conn, $sql);
}

$data = [];
while ($row = pg_fetch_assoc($result)) {
    // ✅ CORRECTO: Mantener claves asociativas
    $data[] = [
        'id_mem' => $row['id_mem'],
        'cliente' => $row['cliente'],
        'fecha' => $row['fecha'],
        'monto_total' => number_format($row['monto_total'], 0, ',', '.')
    ];
}

echo json_encode($data);
pg_close($conn);
?>
