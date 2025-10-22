<?php
include '../../Conexion.php';
include '../../session.php';
require_once '../../TCPDF_v2/tcpdf.php';

// Crear un formateador para español
$formatterES = new NumberFormatter("es", NumberFormatter::SPELLOUT);
$id_cob = $_GET['id_cob'];

// === Obtener datos ===
$cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_cobros_cab WHERE id_cob = $id_cob;"));
$detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_cobros_det WHERE id_cob = " . $cabecera[0]['id_cob'] . " ORDER BY fc_descrip;"));
$cabeceras_monto = pg_fetch_all(pg_query($conn, "SELECT total_efectivo,total_cheque,total_tarjeta,total_transfe,total_general FROM v_vent_cobros_montos WHERE id_cob = ".$cabecera[0]['id_cob'].";"));

// === Crear documento ===
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, 'LETTER', true, 'UTF-8', false);
$pdf->SetCreator('Energym Fitness PY');
$pdf->SetAuthor('Energym Fitness PY');
$pdf->SetTitle('Recibo de Cobranza #' . $cabecera[0]['id_cob']);
$pdf->SetMargins(15, 15, 15);
$pdf->setPrintHeader(false);
$pdf->setPrintFooter(false);

// set default monospaced font
$pdf->setDefaultMonospacedFont(PDF_FONT_MONOSPACED);
// set auto page breaks
$pdf->setAutoPageBreak(true, 15);
// set image scale factor
$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

// Configurar fuentes y estilos
$pdf->SetFont('helvetica', '', 10);
$pdf->AddPage();

// === Contenido del recibo ===
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
    .dashed { border-bottom: 1px dashed #666; }
</style>

<!-- Encabezado de la empresa -->
<table width="100%" cellpadding="4" style="margin-bottom: 10px;">
    <tr>
        <td width="20%" class="text-left">
            <img src="../../iconos/1.jpg" alt="Logo" style="width: 70px; height: 70px;">
        </td>
        <td width="60%" class="text-center">
            <div class="large bold">ENERGYM FITNESS PY</div>
            <div class="small">RUC: ' . ($cabecera[0]['emp_ruc'] ?? 'XXXXXXXXX') . '</div>
            <div class="small">' . ($cabecera[0]['suc_direccion'] ?? 'Encarnación, Paraguay') . '</div>
            <div class="small">Tel: ' . ($cabecera[0]['suc_telefono'] ?? '(071) 200-000') . ' - Email: ' . ($cabecera[0]['suc_correo'] ?? 'info@gimnasio.com') . '</div>
        </td>
        <td width="20%" class="text-center bordered" style="background-color: #f0f8ff;">
            <div class="medium bold">RECIBO</div>
            <div class="small">N° ' . $cabecera[0]['id_cob'] . '</div>
        </td>
    </tr>
</table>

<hr style="border: 1px solid #000; margin: 5px 0;">

<!-- Información principal -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr>
        <td width="50%" class="bordered">
            <strong>FECHA:</strong> ' . $cabecera[0]['fecha'] . '<br>
            <strong>CAJA:</strong> ' . $cabecera[0]['caj_descrip'] . '<br>
            <strong>FACTURA:</strong> ' . $cabecera[0]['vc_nro_factura'] . '
        </td>
        <td width="50%" class="bordered">
            <strong>FUNCIONARIO:</strong> ' . $cabecera[0]['funcionario'] . '<br>
            <strong>SUCURSAL:</strong> ' . $cabecera[0]['suc_nombre'] . '
        </td>
    </tr>
</table>

<!-- Información del cliente -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr class="header-bg">
        <td colspan="2" class="bold bordered">DATOS DEL CLIENTE</td>
    </tr>
    <tr>
        <td width="25%" class="bordered"><strong>CLIENTE:</strong></td>
        <td width="75%" class="bordered">' . ($cabecera[0]['cliente'] ?? 'CONSUMIDOR FINAL') . '</td>
    </tr>
    <tr>
        <td class="bordered"><strong>DOCUMENTO:</strong></td>
        <td class="bordered">' . $cabecera[0]['per_ci'] . '</td>
    </tr>
    <tr>
        <td class="bordered"><strong>DIRECCIÓN:</strong></td>
        <td class="bordered">' . ($cabecera[0]['per_direccion'] ?? 'NO ESPECIFICADA') . '</td>
    </tr>
</table>

<!-- Concepto del pago -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr class="header-bg">
        <td class="bold bordered">CONCEPTO DEL PAGO</td>
    </tr>
    <tr>
        <td class="bordered">' . ($cabecera[0]['concepto'] ?? 'Cobranza por servicios del gimnasio') . '</td>
    </tr>
</table>

<!-- Detalles de formas de pago -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr class="header-bg">
        <td colspan="2" class="bold bordered">DETALLE DE FORMAS DE PAGO</td>
    </tr>';

// Mostrar solo las formas de pago con monto > 0
$formasPago = [
    'EFECTIVO' => $cabeceras_monto[0]['total_efectivo'],
    'CHEQUE' => $cabeceras_monto[0]['total_cheque'],
    'TARJETA' => $cabeceras_monto[0]['total_tarjeta'],
    'TRANSFERENCIA' => $cabeceras_monto[0]['total_transfe']
];

foreach ($formasPago as $forma => $monto) {
    if ($monto > 0) {
        $html .= '
    <tr>
        <td width="80%" class="bordered"><strong>' . $forma . ':</strong></td>
        <td width="20%" class="bordered text-right">' . number_format($monto, 0, ",", ".") . ' Gs.</td>
    </tr>';
    }
}

$html .= '
</table>

<!-- Total general -->
<table width="100%" cellpadding="4" style="font-size: 10px; margin-bottom: 10px;">
    <tr class="total-bg">
        <td width="80%" class="bordered border-top bold large text-right"><strong>TOTAL COBRADO:</strong></td>
        <td width="20%" class="bordered border-top bold large text-right">' . number_format($cabeceras_monto[0]['total_general'], 0, ",", ".") . ' Gs.</td>
    </tr>
</table>

<!-- Total en letras -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 15px;">
    <tr>
        <td class="bordered">
            <strong>TOTAL EN LETRAS:</strong> ' . convertirNumeroLetras($cabeceras_monto[0]['total_general']) . '
        </td>
    </tr>
</table>

<!-- Firmas -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr>
        <td width="50%" class="text-center">
            <div class="dashed" style="height: 40px; margin-bottom: 5px;"></div>
            <strong>FIRMA DEL CLIENTE</strong><br>
            <span class="small">Aclaración y C.I.</span>
        </td>
        <td width="50%" class="text-center">
            <div class="dashed" style="height: 40px; margin-bottom: 5px;"></div>
            <strong>FIRMA Y SELLO DEL GIMNASIO</strong><br>
            <span class="small">' . $cabecera[0]['funcionario'] . '</span>
        </td>
    </tr>
</table>

<!-- Observaciones -->
<table width="100%" cellpadding="4" style="font-size: 8px; margin-bottom: 5px;">
    <tr>
        <td class="bordered">
            <strong>OBSERVACIONES:</strong><br>
            ' . ($cabecera[0]['observaciones'] ?? 'Recibo válido como comprobante de pago.') . '
        </td>
    </tr>
</table>

<!-- Pie de página -->
<table width="100%" cellpadding="3" style="font-size: 8px;">
    <tr>
        <td class="text-center border-top">
            <strong>ORIGINAL: CLIENTE - COPIA: GIMNASIO</strong><br>
            <em>¡Gracias por confiar en nosotros! Siga entrenando con Energym Fitness PY</em>
        </td>
    </tr>
</table>';

// Función para convertir número a letras
function convertirNumeroLetras($numero) {
    if (!class_exists('NumberFormatter')) {
        return '*** IMPLEMENTAR CONVERSIÓN A LETRAS *** GUARANÍES';
    }
    
    global $formatterES;
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
$pdf->Output('recibo_' . $cabecera[0]['id_cob'] . '.pdf', 'I');

pg_close($conn);
?>