<?php
include '../../Conexion.php';
include '../../session.php';
require_once '../../TCPDF_v2/tcpdf.php';
$id_ali = $_GET['id_ali'];

// ==== Datos de cabecera ====
$cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_alimentaciones_cab WHERE id_ali = $id_ali;"));
$detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_alimentaciones_det WHERE id_ali = " . $cabecera[0]['id_ali'] . " ORDER BY id_ali;"));

// ==== Crear documento ====
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, 'LETTER', true, 'UTF-8', false);
$pdf->SetCreator('Energym Fitness PY');
$pdf->SetAuthor('Energym Fitness PY');
$pdf->SetTitle('Plan Alimentario - ' . $cabecera[0]['cliente']);
$pdf->SetMargins(15, 15, 15);
$pdf->setPrintHeader(false);
$pdf->setPrintFooter(false);

$pdf->setDefaultMonospacedFont(PDF_FONT_MONOSPACED);
$pdf->setAutoPageBreak(true, 15);
$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

// Configurar fuentes y estilos
$pdf->SetFont('helvetica', '', 10);
$pdf->AddPage();

// ==== Calcular totales ====
$total_cal = 0; $total_car = 0; $total_prot = 0; $total_grasas = 0;
$comidas_por_dia = [];

foreach ($detalles as $r) {
    $total_cal += $r['calorias'];
    $total_car += $r['carbohidratos'];
    $total_prot += $r['proteinas'];
    $total_grasas += $r['grasas'] ?? 0;
    
    // Agrupar por tipo de comida
    $tipo_comida = $r['tipo_comida'] ?? 'General';
    if (!isset($comidas_por_dia[$tipo_comida])) {
        $comidas_por_dia[$tipo_comida] = 0;
    }
    $comidas_por_dia[$tipo_comida]++;
}

$html = '
<style>
    .bordered { border: 1px solid #333; padding: 5px; }
    .text-center { text-align: center; }
    .text-right { text-align: right; }
    .text-left { text-align: left; }
    .bold { font-weight: bold; }
    .border-bottom { border-bottom: 1px solid #333; }
    .border-top { border-top: 1px solid #333; }
    .small { font-size: 9px; }
    .medium { font-size: 10px; }
    .large { font-size: 12px; }
    .xlarge { font-size: 14px; }
    .header-bg { background-color: #2c3e50; color: white; }
    .nutrition-bg { background-color: #e8f5e8; }
    .client-bg { background-color: #f0f8ff; }
    .total-bg { background-color: #34495e; color: white; }
    .meal-time { background-color: #ecf0f1; }
</style>

<!-- Encabezado de la empresa -->
<table width="100%" cellpadding="4" style="margin-bottom: 10px;">
    <tr>
        <td width="20%" class="text-left">
            <img src="../../iconos/1.jpg" alt="Logo" style="width: 70px; height: 70px;">
        </td>
        <td width="60%" class="text-center">
            <div class="xlarge bold">ENERGYM FITNESS PY</div>
            <div class="small">' . $cabecera[0]['suc_nombre'] . '</div>
            <div class="small">' . $cabecera[0]['suc_direccion'] . '</div>
            <div class="small">Tel: ' . $cabecera[0]['suc_telefono'] . ' - Email: ' . $cabecera[0]['suc_correo'] . '</div>
        </td>
        <td width="20%" class="text-center bordered" style="background-color: #e8f5e8;">
            <div class="medium bold">PLAN ALIMENTARIO</div>
            <div class="small">Personalizado</div>
        </td>
    </tr>
</table>

<hr style="border: 1px solid #2c3e50; margin: 5px 0;">

<!-- Información del cliente -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr class="client-bg">
        <td colspan="6" class="bold bordered">INFORMACIÓN DEL CLIENTE</td>
    </tr>
    <tr>
        <td width="20%" class="bordered"><strong>CLIENTE:</strong></td>
        <td width="20%" class="bordered">' . $cabecera[0]['cliente'] . '</td>
        <td width="15%" class="bordered"><strong>EDAD:</strong></td>
        <td width="15%" class="bordered">' . $cabecera[0]['per_edad'] . ' años</td>
        <td width="15%" class="bordered"><strong>GÉNERO:</strong></td>
        <td width="15%" class="bordered">' . $cabecera[0]['gen_descrip'] . '</td>
    </tr>
    <tr>
        <td class="bordered"><strong>DOCUMENTO:</strong></td>
        <td class="bordered">' . $cabecera[0]['cli_ci'] . '</td>
        <td class="bordered"><strong>OBJETIVO:</strong></td>
        <td class="bordered" colspan="3">' . $cabecera[0]['ali_objetivo'] . '</td>
    </tr>
</table>

<!-- Período y profesional -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr>
        <td width="50%" class="bordered">
            <strong>FECHA INICIO:</strong> ' . $cabecera[0]['fecha'] . '<br>
            <strong>DURACIÓN:</strong> ' . $cabecera[0]['ali_dias'] . ' días<br>
            <strong>FECHA FIN:</strong> ' . $cabecera[0]['fecha_fin'] . '
        </td>
        <td width="50%" class="bordered">
            <strong>NUTRICIONISTA:</strong> ' . $cabecera[0]['funcionario'] . '<br>
            <strong>SUCURSAL:</strong> ' . $cabecera[0]['suc_nombre'] . '<br>
            <strong>CONTACTO:</strong> ' . $cabecera[0]['suc_telefono'] . '
        </td>
    </tr>
</table>

<!-- Resumen nutricional -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr class="nutrition-bg">
        <td colspan="6" class="bold bordered">RESUMEN NUTRICIONAL DIARIO</td>
    </tr>
    <tr>
        <td width="20%" class="bordered text-center">
            <div class="medium bold">' . number_format($total_cal, 0) . '</div>
            <div class="small">CALORÍAS</div>
        </td>
        <td width="20%" class="bordered text-center">
            <div class="medium bold">' . number_format($total_prot, 0) . 'g</div>
            <div class="small">PROTEÍNAS</div>
        </td>
        <td width="20%" class="bordered text-center">
            <div class="medium bold">' . number_format($total_car, 0) . 'g</div>
            <div class="small">CARBOHIDRATOS</div>
        </td>
        <td width="20%" class="bordered text-center">
            <div class="medium bold">' . number_format($total_grasas, 0) . 'g</div>
            <div class="small">GRASAS</div>
        </td>
        <td width="20%" class="bordered text-center">
            <div class="medium bold">' . count($detalles) . '</div>
            <div class="small">COMIDAS/DÍA</div>
        </td>
    </tr>
</table>

<!-- Distribución de comidas -->
<table width="100%" cellpadding="4" style="font-size: 8px; margin-bottom: 10px;">
    <tr class="meal-time">
        <td class="bordered text-center">
            <strong>DESAYUNO:</strong> ' . ($comidas_por_dia['Desayuno'] ?? '0') . ' recetas
        </td>
        <td class="bordered text-center">
            <strong>MEDIA MAÑANA:</strong> ' . ($comidas_por_dia['Media Mañana'] ?? '0') . ' recetas
        </td>
        <td class="bordered text-center">
            <strong>ALMUERZO:</strong> ' . ($comidas_por_dia['Almuerzo'] ?? '0') . ' recetas
        </td>
        <td class="bordered text-center">
            <strong>MEDIA TARDE:</strong> ' . ($comidas_por_dia['Media Tarde'] ?? '0') . ' recetas
        </td>
        <td class="bordered text-center">
            <strong>CENA:</strong> ' . ($comidas_por_dia['Cena'] ?? '0') . ' recetas
        </td>
    </tr>
</table>

<!-- Detalle de recetas -->
<table width="100%" cellpadding="4" style="font-size: 8px; border: 1px solid #333; margin-bottom: 10px;">
    <thead>
        <tr class="header-bg">
            <th width="5%" class="bordered text-center">#</th>
            <th width="25%" class="bordered text-center">RECETA</th>
            <th width="35%" class="bordered text-center">INGREDIENTES</th>
            <th width="10%" class="bordered text-center">CALORÍAS</th>
            <th width="10%" class="bordered text-center">PROTEÍNAS (g)</th>
            <th width="10%" class="bordered text-center">CARBOS (g)</th>
            <th width="5%" class="bordered text-center">GRASAS (g)</th>
        </tr>
    </thead>
    <tbody>';

if (!empty($detalles)) {
    $contador = 1;
    foreach ($detalles as $r) {
        $tipo_comida = $r['tipo_comida'] ?? 'General';
        $html .= '
        <tr>
            <td width="5%" class="bordered text-center">' . $contador . '</td>
            <td width="25%" class="bordered text-left">
                <strong>' . $r['res_descrip'] . '</strong><br>
                <small><em>' . $tipo_comida . '</em></small>
            </td>
            <td width="35%" class="bordered text-left small">' . $r['res_ingrediente'] . '</td>
            <td width="10%" class="bordered text-center">' . $r['calorias'] . '</td>
            <td width="10%" class="bordered text-center">' . $r['proteinas'] . '</td>
            <td width="10%" class="bordered text-center">' . $r['carbohidratos'] . '</td>
            <td width="5%" class="bordered text-center">' . ($r['grasas'] ?? '0') . '</td>
        </tr>';
        $contador++;
    }
} else {
    $html .= '
        <tr>
            <td colspan="7" class="bordered text-center">No hay recetas asignadas en este plan</td>
        </tr>';
}

$html .= '
    </tbody>
    <tfoot>
        <tr class="total-bg">
            <td colspan="3" class="bordered text-right bold">TOTALES DIARIOS:</td>
            <td class="bordered text-center bold">' . $total_cal . '</td>
            <td class="bordered text-center bold">' . $total_prot . '</td>
            <td class="bordered text-center bold">' . $total_car . '</td>
            <td class="bordered text-center bold">' . $total_grasas . '</td>
        </tr>
    </tfoot>
</table>

<!-- Recomendaciones generales -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr class="nutrition-bg">
        <td class="bold bordered">RECOMENDACIONES GENERALES</td>
    </tr>
    <tr>
        <td class="bordered">
            • Mantener hidratación adecuada (2-3 litros de agua diarios)<br>
            • Respetar horarios de las comidas<br>
            • Combinar con actividad física regular<br>
            • Evitar alimentos procesados y azúcares refinados<br>
            • ' . ($cabecera[0]['ali_observacion'] ?? 'Consultar ante cualquier duda con su nutricionista').'
        </td>
    </tr>
</table>

<!-- Firmas -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr>
        <td width="50%" class="text-center">
            <div style="border-bottom: 1px dashed #666; height: 40px; margin-bottom: 5px;"></div>
            <strong>FIRMA DEL CLIENTE</strong><br>
            <span class="small">Aclaración y C.I.</span>
        </td>
        <td width="50%" class="text-center">
            <div style="border-bottom: 1px dashed #666; height: 40px; margin-bottom: 5px;"></div>
            <strong>FIRMA DEL NUTRICIONISTA</strong><br>
            <span class="small">' . $cabecera[0]['funcionario'] . '</span>
        </td>
    </tr>
</table>

<!-- Pie de página -->
<table width="100%" cellpadding="3" style="font-size: 8px;">
    <tr>
        <td class="text-center border-top">
            <strong>ORIGINAL: CLIENTE - COPIA: NUTRICIÓN</strong><br>
            <em>¡Su salud es nuestra prioridad! Siga las indicaciones para obtener los mejores resultados.</em>
        </td>
    </tr>
</table>';

// Agregar el contenido HTML al PDF
$pdf->writeHTML($html, true, false, true, false, '');

// ==== Salida ====
$pdf->Output('plan_alimentario_' . $cabecera[0]['cliente'] . '.pdf', 'I');

pg_close($conn);
?>