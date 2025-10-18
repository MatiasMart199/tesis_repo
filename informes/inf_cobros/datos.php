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
    $filtro_fecha = "AND cob_fecha BETWEEN $1 AND $2";
    $parametros = array($fecha_inicio, $fecha_fin);
}

$sql = "SELECT id_cob, vc_nro_factura, fecha, total_efectivo,total_cheque,total_tarjeta,total_transfe,total_general
        FROM v_vent_cobros_montos WHERE estado = 'CONFIRMADO' " . $filtro_fecha . " 
        ORDER BY id_cob ASC";

if (!empty($parametros)) {
    $result = pg_query_params($conn, $sql, $parametros);
} else {
    $result = pg_query($conn, $sql);
}

$data = [];
while ($row = pg_fetch_assoc($result)) {
    // ✅ CORRECTO: Mantener claves asociativas
    $data[] = [
        'id_cob' => $row['id_cob'],
        'vc_nro_factura' => $row['vc_nro_factura'],
        'fecha' => $row['fecha'],
        'total_efectivo' => number_format($row['total_efectivo'], 0, ',', '.'),
        'total_cheque' => number_format($row['total_cheque'], 0, ',', '.'),
        'total_tarjeta' => number_format($row['total_tarjeta'], 0, ',', '.'),
        'total_transfe' => number_format($row['total_transfe'], 0, ',', '.'),
        'total_general' => number_format($row['total_general'], 0, ',', '.')
    ];
}

echo json_encode($data);
pg_close($conn);
?>
