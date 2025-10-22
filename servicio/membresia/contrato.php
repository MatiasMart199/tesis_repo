<?php
include '../../Conexion.php';
include '../../session.php';
require_once '../../TCPDF_v2/tcpdf.php';

$id_mem = $_GET['id_mem'];

// === Obtener datos ===
$cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_membresias_cab WHERE id_mem = $id_mem;"));
$detalles_membresia = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_membresias_det WHERE id_mem = $id_mem ORDER BY id_plan_servi ASC;"));
$detalles_inscripcion = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_inscripciones_membresias WHERE id_mem = $id_mem ORDER BY id_plan_servi ASC;"));

// === Crear documento ===
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, 'LETTER', true, 'UTF-8', false);
$pdf->SetCreator('Energym Fitness PY');
$pdf->SetAuthor('Energym Fitness PY');
$pdf->SetTitle('Membresía #' . $cabecera[0]['id_mem']);
$pdf->SetMargins(15, 15, 15);
$pdf->setPrintHeader(false);
$pdf->setPrintFooter(false);

$pdf->setDefaultMonospacedFont(PDF_FONT_MONOSPACED);
$pdf->setAutoPageBreak(true, 15);
$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

// Configurar fuentes y estilos
$pdf->SetFont('helvetica', '', 10);
$pdf->AddPage();

// Calcular totales
$totalMembresia = $cabecera[0]['monto_detalles'] ?? 0;
$totalInscripcion = $cabecera[0]['monto_inscripcion'] ?? 0;
$totalGeneral = $cabecera[0]['monto_total'] ?? ($totalMembresia + $totalInscripcion);

$html = '
<style>
    .bordered { border: 1px solid #000; padding: 4px; }
    .text-center { text-align: center; }
    .text-right { text-align: right; }
    .text-left { text-align: left; }
    .bold { font-weight: bold; }
    .border-bottom { border-bottom: 1px solid #000; }
    .border-top { border-top: 1px solid #000; }
    .small { font-size: 9px; }
    .medium { font-size: 10px; }
    .large { font-size: 12px; }
    .header-bg { background-color: #f5f5f5; }
    .total-bg { background-color: #e8f4fd; }
    .client-bg { background-color: #f0f8ff; }
    .warning { background-color: #fff0f0; color: #d8000c; }
    .success { background-color: #f0fff0; color: #2d5016; }
</style>

<!-- Encabezado de la empresa -->
<table width="100%" cellpadding="4" style="margin-bottom: 10px;">
    <tr>
        <td width="20%" class="text-left">
            <img src="../../iconos/1.jpg" alt="Logo" style="width: 70px; height: 70px;">
        </td>
        <td width="60%" class="text-center">
            <div class="large bold">ENERGYM FITNESS PY</div>
            <div class="small">RUC: ' . $cabecera[0]['emp_ruc'] . '</div>
            <div class="small">' . $cabecera[0]['suc_direccion'] . '</div>
            <div class="small">Tel: ' . $cabecera[0]['suc_telefono'] . ' - Email: ' . $cabecera[0]['suc_correo'] . '</div>
        </td>
        <td width="20%" class="text-center bordered" style="background-color: #f0f8ff;">
            <div class="medium bold">CONTRATO DE MEMBRESÍA</div>
            <div class="small">N° ' . $cabecera[0]['id_mem'] . '</div>
        </td>
    </tr>
</table>

<hr style="border: 1px solid #000; margin: 5px 0;">

<!-- Información del cliente -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr class="client-bg">
        <td colspan="4" class="bold bordered">DATOS DEL CLIENTE</td>
    </tr>
    <tr>
        <td width="25%" class="bordered"><strong>CLIENTE:</strong></td>
        <td width="25%" class="bordered">' . $cabecera[0]['cliente'] . '</td>
        <td width="25%" class="bordered"><strong>DOCUMENTO:</strong></td>
        <td width="25%" class="bordered">' . $cabecera[0]['per_ci'] . '</td>
    </tr>
    <tr>
        <td class="bordered"><strong>FECHA INICIO:</strong></td>
        <td class="bordered">' . $cabecera[0]['fecha'] . '</td>
        <td class="bordered"><strong>FECHA VENCIMIENTO:</strong></td>
        <td class="bordered">' . $cabecera[0]['fecha_venci'] . '</td>
    </tr>
    <tr>
        <td class="bordered"><strong>ASESOR:</strong></td>
        <td class="bordered">' . $cabecera[0]['funcionario'] . '</td>
        <td class="bordered"><strong>SUCURSAL:</strong></td>
        <td class="bordered">' . $cabecera[0]['suc_nombre'] . '</td>
    </tr>
</table>

<!-- Vigencia de la membresía -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr class="success">
        <td class="bordered text-center">
            <strong>VIGENCIA DE LA MEMBRESÍA: </strong> Del ' . $cabecera[0]['fecha'] . ' al ' . $cabecera[0]['fecha_venci'] . '
        </td>
    </tr>
</table>';

// Mostrar detalles de membresía si existen
if (!empty($detalles_membresia)) {
    $html .= '
    <!-- Detalles de Membresía -->
    <table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
        <tr class="header-bg">
            <td colspan="6" class="bold bordered">DETALLES DE LA MEMBRESÍA</td>
        </tr>
        <tr class="header-bg">
            <th width="40%" class="bordered text-center">PLAN DE SERVICIO</th>
            <th width="15%" class="bordered text-center">DURACIÓN</th>
            <th width="15%" class="bordered text-center">DÍAS</th>
            <th width="15%" class="bordered text-center">PRECIO UNIT.</th>
            <th width="15%" class="bordered text-center">SUBTOTAL</th>
        </tr>';

    foreach ($detalles_membresia as $dm) {
        $subtotal = $dm['dias'] * $dm['precio'];
        $html .= '
        <tr>
            <td class="bordered text-left">
                <strong>' . $dm['ps_descrip'] . '</strong><br>
                <small>' . ($dm['pro_nombre'] ?? 'Sin promoción') . '</small>
            </td>
            <td class="bordered text-center">' . ($dm['td_descrip'] ?? 'No especificado') . '</td>
            <td class="bordered text-center">' . $dm['dias'] . '</td>
            <td class="bordered text-right">' . number_format($dm['precio'], 0, ",", ".") . '</td>
            <td class="bordered text-right">' . number_format($subtotal, 0, ",", ".") . '</td>
        </tr>';
    }

    $html .= '
    </table>';
}

// Mostrar detalles de inscripción si existen
if (!empty($detalles_inscripcion)) {
    $html .= '
    <!-- Detalles de Inscripción -->
    <table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
        <tr class="header-bg">
            <td colspan="6" class="bold bordered">SERVICIOS ADICIONALES DE INSCRIPCIÓN</td>
        </tr>
        <tr class="header-bg">
            <th width="40%" class="bordered text-center">SERVICIO ADICIONAL</th>
            <th width="15%" class="bordered text-center">DURACIÓN</th>
            <th width="15%" class="bordered text-center">DÍAS</th>
            <th width="15%" class="bordered text-center">PRECIO UNIT.</th>
            <th width="15%" class="bordered text-center">SUBTOTAL</th>
        </tr>';

    foreach ($detalles_inscripcion as $di) {
        $subtotal = $di['dias'] * $di['precio'];
        $html .= '
        <tr>
            <td class="bordered text-left">
                <strong>' . $di['ps_descrip'] . '</strong><br>
                <small>' . ($di['pro_nombre'] ?? 'Sin promoción') . '</small>
            </td>
            <td class="bordered text-center">' . ($di['td_descrip'] ?? 'No especificado') . '</td>
            <td class="bordered text-center">' . $di['dias'] . '</td>
            <td class="bordered text-right">' . number_format($di['precio'], 0, ",", ".") . '</td>
            <td class="bordered text-right">' . number_format($subtotal, 0, ",", ".") . '</td>
        </tr>';
    }

    $html .= '
    </table>';
}

// Advertencia sobre planes de servicio si hay detalles
if (!empty($detalles_membresia) || !empty($detalles_inscripcion)) {
    $html .= '
    <!-- Advertencia importante -->
    <table width="100%" cellpadding="4" style="font-size: 8px; margin-bottom: 10px;">
        <tr class="warning">
            <td class="bordered">
                <strong>IMPORTANTE:</strong> Los planes de servicio contratados en esta membresía son responsabilidad exclusiva del cliente. 
                El gimnasio no se responsabiliza por la disponibilidad, modificación o discontinuación de los planes de servicio específicos. 
                En caso de cambios en la oferta de servicios, el gimnasio ofrecerá alternativas equivalentes, pero no garantiza la permanencia 
                de planes específicos durante toda la vigencia de la membresía.
            </td>
        </tr>
    </table>';
}

$html .= '

<!-- Totales -->
<table width="100%" cellpadding="4" style="font-size: 10px; margin-bottom: 10px;">
    <tr>
        <td width="60%">
            <table width="100%" cellpadding="3">
                <tr>
                    <td class="text-left"><strong>TERMINOS Y CONDICIONES:</strong></td>
                </tr>
                <tr>
                    <td class="small" style="height: 60px;">
                        • La membresía es personal e intransferible<br>
                        • Presentar documento de identidad para ingreso<br>
                        • Respetar el reglamento interno del gimnasio<br>
                        • Horarios sujetos a disponibilidad de la sucursal<br>
                        • ' . ($cabecera[0]['mem_observacion'] ?? 'Sin observaciones adicionales') . '
                    </td>
                </tr>
            </table>
        </td>
        <td width="40%">
            <table width="100%" cellpadding="3">
                <tr>
                    <td class="border-bottom text-right"><strong>SUBTOTAL MEMBRESÍA:</strong></td>
                    <td class="border-bottom text-right">' . number_format($totalMembresia, 0, ",", ".") . ' Gs.</td>
                </tr>
                <tr>
                    <td class="border-bottom text-right"><strong>SUBTOTAL INSCRIPCIÓN:</strong></td>
                    <td class="border-bottom text-right">' . number_format($totalInscripcion, 0, ",", ".") . ' Gs.</td>
                </tr>
                <tr>
                    <td class="border-top border-bottom text-right bold large"><strong>TOTAL GENERAL:</strong></td>
                    <td class="border-top border-bottom text-right bold large">' . number_format($totalGeneral, 0, ",", ".") . ' Gs.</td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<!-- Total en letras -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 15px;">
    <tr>
        <td class="bordered">
            <strong>TOTAL EN LETRAS:</strong> ' . convertirNumeroLetras($totalGeneral) . '
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
            <strong>FIRMA Y SELLO DEL GIMNASIO</strong><br>
            <span class="small">' . $cabecera[0]['funcionario'] . '</span>
        </td>
    </tr>
</table>

<!-- Pie de página -->
<table width="100%" cellpadding="3" style="font-size: 8px;">
    <tr>
        <td class="text-center border-top">
            <strong>ORIGINAL: CLIENTE - COPIA: GIMNASIO</strong><br>
            <em>¡Gracias por elegir Energym Fitness PY! Su salud es nuestra prioridad.</em>
        </td>
    </tr>
</table>';

// Función para convertir número a letras
function convertirNumeroLetras($numero) {
    if (!class_exists('NumberFormatter')) {
        return '*** IMPLEMENTAR CONVERSIÓN A LETRAS *** GUARANÍES';
    }
    
    $formatterES = new NumberFormatter("es", NumberFormatter::SPELLOUT);
    $parteEntera = intval(floor($numero));
    $parteDecimal = intval(($numero - floor($numero)) * 100);
    
    $total_letras = ucfirst($formatterES->format($parteEntera));
    if ($parteDecimal > 0) {
        $total_letras .= ' con ' . $parteDecimal . '/100';
    }
    
    return strtoupper($total_letras) . ' GUARANÍES';
}

// Agregar el contenido HTML al PDF
$pdf->writeHTML($html, true, false, true, false, '');

// === Salida del PDF ===
$pdf->Output('membresia_' . $cabecera[0]['id_mem'] . '.pdf', 'I');

pg_close($conn);
?>