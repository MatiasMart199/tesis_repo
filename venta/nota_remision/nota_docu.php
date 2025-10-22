<?php
//require_once '../../tcpdf/tcpdf.php';
require_once '../../TCPDF_v2/tcpdf.php';
include '../../Conexion.php';
include '../../session.php';
$id_not = $_GET['id_not'];

$cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_nota_cab WHERE id_not = $id_not;"));
$detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_nota_det WHERE id_not = $id_not ORDER BY id_item ASC;"));

// Crear instancia de TCPDF
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, 'LETTER', true, 'UTF-8', false);

// Establecer la información del documento
$pdf->SetCreator(PDF_CREATOR);
$pdf->SetAuthor('Your Name');
$pdf->SetTitle('NOTA DE REMISIÓN - ' . $cabecera[0]['not_nro_documento']);
$pdf->SetSubject('Nota de Remisión');
$pdf->SetKeywords('REMISIÓN, TCPDF, PDF');

$pdf->setPrintHeader(false);
$pdf->setPrintFooter(false);
$pdf->setDefaultMonospacedFont(PDF_FONT_MONOSPACED);
$pdf->setMargins(10, 10, 10);
$pdf->setAutoPageBreak(true, 15);
$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

if (@file_exists(dirname(__FILE__) . '/lang/eng.php')) {
    require_once(dirname(__FILE__) . '/lang/eng.php');
    $pdf->setLanguageArray($l);
}

// Establecer el estilo de fuente
$pdf->SetFont('helvetica', '', 10);
$pdf->AddPage();

// Calcular total general
$totalGeneral = 0;
if (!empty($detalles)) {
    foreach ($detalles as $d) {
        $subtotal = $d['precio'] * $d['cantidad'];
        $totalGeneral += $subtotal;
    }
}

$html = '
<style>
    .bordered { border: 1px solid #000; padding: 3px; }
    .text-center { text-align: center; }
    .text-right { text-align: right; }
    .text-left { text-align: left; }
    .bold { font-weight: bold; }
    .border-bottom { border-bottom: 1px solid #000; }
    .border-top { border-top: 1px solid #000; }
    .small { font-size: 9px; }
    .medium { font-size: 10px; }
    .large { font-size: 12px; }
    .header-bg { background-color: #f0f0f0; }
    .dashed { border: 1px dashed #666; }
</style>

<table width="100%" cellpadding="3" style="font-size: 10px;">
    <!-- Encabezado con datos de la empresa -->
    <tr>
        <td width="30%" class="text-left">
            <img src="../../iconos/1.jpg" alt="Logo" style="width: 80px; height: 80px; margin: 0;">
        </td>
        <td width="40%" class="text-center">
            <div class="large bold">' . strtoupper($cabecera[0]['emp_denominacion']) . '</div>
            <div class="small">RUC: ' . ($cabecera[0]['emp_ruc'] ?? 'XXXXXXXXX') . '</div>
            <div class="small">' . $cabecera[0]['suc_direccion'] . '</div>
            <div class="small">Tel: ' . $cabecera[0]['suc_telefono'] . ' - Email: ' . $cabecera[0]['suc_correo'] . '</div>
        </td>
        <td width="30%" class="text-center bordered" style="background-color: #f8f8f8;">
            <div class="large bold">NOTA DE REMISIÓN</div>
            <div class="medium">N° ' . $cabecera[0]['not_nro_documento'] . '</div>
        </td>
    </tr>
</table>

<br>

<!-- Información de fechas y tipo de movimiento -->
<table width="100%" cellpadding="3" style="font-size: 9px;">
    <tr>
        <td width="50%" class="bordered">
            <strong>FECHA SALIDA:</strong> ' . $cabecera[0]['fecha'] . '<br>
            <strong>FECHA EMISIÓN:</strong> ' . ($cabecera[0]['fecha_emision'] ?? $cabecera[0]['fecha']) . '
        </td>
        <td width="50%" class="bordered">
            <strong>TIPO MOVIMIENTO:</strong> ' . ($cabecera[0]['tm_descrip'] ?? 'REMISIÓN') . '<br>
            <strong>CÓDIGO:</strong> ' . ($cabecera[0]['tm_codigo'] ?? 'NR') . '
        </td>
    </tr>
</table>

<br>

<!-- Información del cliente/remitente -->
<table width="100%" cellpadding="3" style="font-size: 9px;">
    <tr class="header-bg">
        <td colspan="4" class="bold bordered">DATOS DEL CLIENTE/DESTINATARIO</td>
    </tr>
    <tr>
        <td width="25%" class="bordered"><strong>RAZÓN SOCIAL:</strong></td>
        <td width="25%" class="bordered">' . ($cabecera[0]['cliente'] ?? 'NO ESPECIFICADO') . '</td>
        <td width="25%" class="bordered"><strong>RUC/CI:</strong></td>
        <td width="25%" class="bordered">' . ($cabecera[0]['per_ruc'] ?? $cabecera[0]['per_ci'] ?? 'XXXXXXXXX') . '</td>
    </tr>
    <tr>
        <td class="bordered"><strong>DIRECCIÓN:</strong></td>
        <td class="bordered" colspan="3">' . ($cabecera[0]['per_direccion'] ?? 'NO ESPECIFICADA') . '</td>
    </tr>
</table>

<br>

<!-- Información de transporte y entrega -->
<table width="100%" cellpadding="3" style="font-size: 9px;">
    <tr class="header-bg">
        <td colspan="4" class="bold bordered">INFORMACIÓN DE TRANSPORTE Y ENTREGA</td>
    </tr>
    <tr>
        <td width="25%" class="bordered"><strong>Vehículo:</strong></td>
        <td width="25%" class="bordered">' . ($cabecera[0]['vehiculo'] ?? 'NO ESPECIFICADO') . '</td>
        <td width="25%" class="bordered"><strong>Chofer:</strong></td>
        <td width="25%" class="bordered">' . ($cabecera[0]['chofer'] ?? 'NO ESPECIFICADO') . '</td>
    </tr>
    <tr>
        <td class="bordered"><strong>Dirección de Entrega:</strong></td>
        <td class="bordered" colspan="3">' . ($cabecera[0]['per_direccion'] ?? 'MISMO QUE CLIENTE') . '</td>
    </tr>
</table>

<br>

<!-- Tabla de detalles de productos (sin impuestos) -->
<table width="100%" cellpadding="3" style="font-size: 8px; border: 1px solid #000;">
    <thead>
        <tr class="header-bg">
            <th width="8%" class="bordered text-center">CANT.</th>
            <th width="52%" class="bordered text-center">DESCRIPCIÓN DEL PRODUCTO</th>
            <th width="20%" class="bordered text-center">PRECIO UNIT.</th>
            <th width="20%" class="bordered text-center">SUBTOTAL</th>
        </tr>
    </thead>
    <tbody>';

if (!empty($detalles)) {
    foreach ($detalles as $d) {
        $subtotal = $d['precio'] * $d['cantidad'];
        $html .= '
        <tr>
            <td width="8%" class="bordered text-center">' . $d['cantidad'] . '</td>
            <td width="52%" class="bordered text-left">' . $d['item_descrip'] . ' - ' . $d['mar_descrip'] . '</td>
            <td width="20%" class="bordered text-right">' . number_format($d['precio'], 0, ",", ".") . '</td>
            <td width="20%" class="bordered text-right">' . number_format($subtotal, 0, ",", ".") . '</td>
        </tr>';
    }
} else {
    $html .= '
        <tr>
            <td colspan="4" class="bordered text-center">No hay productos en esta remisión</td>
        </tr>';
}

$html .= '
    </tbody>
</table>

<br>

<!-- Totales simplificados -->
<table width="100%" cellpadding="3" style="font-size: 10px;">
    <tr>
        <td width="70%">
            <table width="100%" cellpadding="3">
                <tr>
                    <td class="dashed text-left"><strong>OBSERVACIONES:</strong></td>
                </tr>
                <tr>
                    <td class="dashed" style="height: 40px;">' . ($cabecera[0]['not_observacion'] ?? '') . '</td>
                </tr>
            </table>
        </td>
        <td width="30%">
            <table width="100%" cellpadding="3">
                <tr>
                    <td class="border-top border-bottom text-right bold large"><strong>TOTAL REMISIÓN:</strong></td>
                    <td class="border-top border-bottom text-right bold large">' . number_format($totalGeneral, 0, ",", ".") . '</td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<br>

<!-- Información en letras -->
<table width="100%" cellpadding="3" style="font-size: 9px;">
    <tr>
        <td class="bordered">
            <strong>TOTAL EN LETRAS:</strong> ' . convertirNumeroLetras($totalGeneral) . '
        </td>
    </tr>
</table>

<br>

<!-- Firmas y autorizaciones -->
<table width="100%" cellpadding="3" style="font-size: 8px;">
    <tr>
        <td width="33%" class="text-center dashed" style="height: 60px;">
            <strong>ENTREGADO POR:</strong><br>
            ' . $cabecera[0]['funcionario'] . '
        </td>
        <td width="33%" class="text-center dashed" style="height: 60px;">
            <strong>TRANSPORTADO POR:</strong><br>
            ' . ($cabecera[0]['chofer'] ?? 'NO ESPECIFICADO') . '
        </td>
        <td width="34%" class="text-center dashed" style="height: 60px;">
            <strong>RECIBIDO POR:</strong><br>
            _________________________
        </td>
    </tr>
    <tr>
        <td class="text-center small">Firma y Sello</td>
        <td class="text-center small">Firma del Chofer</td>
        <td class="text-center small">Firma del Cliente</td>
    </tr>
</table>

<br>

<!-- Pie de página específico para remisión -->
<table width="100%" cellpadding="3" style="font-size: 8px;">
    <tr>
        <td class="text-center border-top">
            <strong>USUARIO:</strong> ' . $cabecera[0]['funcionario'] . ' | 
            <strong>SUCURSAL:</strong> ' . $cabecera[0]['suc_nombre'] . '<br>
            <em>Original: Cliente - Copia: Archivo - Copia: Transporte</em><br>
            <strong>"Documento de traslado de mercaderías - No válido como factura"</strong>
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

// Nombre del archivo
$nombreArchivo = 'nota_remision_' . $cabecera[0]['not_nro_documento'] . '.pdf';

//Close and output PDF document
$pdf->Output($nombreArchivo, 'I');

pg_close($conn);
?>