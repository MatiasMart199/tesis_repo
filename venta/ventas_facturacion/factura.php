<?php
//require_once '../../tcpdf/tcpdf.php';
require_once '../../TCPDF_v2/tcpdf.php';
include '../../Conexion.php';
include '../../session.php';
$id_vc = $_GET['id_vc'];

$cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_ventas_cab WHERE id_vc = $id_vc;"));

$detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_cal_impuesto_ventas WHERE id_vc = $id_vc ORDER BY id_vc asc;"));

// Crear instancia de TCPDF
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, 'LETTER', true, 'UTF-8', false);

// Establecer la información del documento
$pdf->SetCreator(PDF_CREATOR);
$pdf->SetAuthor('Your Name');
$pdf->SetTitle('FACTURA - ' . $cabecera[0]['vc_nro_factura']);
$pdf->SetSubject('Factura de Venta');
$pdf->SetKeywords('FACTURA, TCPDF, PDF');

$pdf->setPrintHeader(false);
$pdf->setPrintFooter(false);

// set default monospaced font
$pdf->setDefaultMonospacedFont(PDF_FONT_MONOSPACED);

// set margins
$pdf->setMargins(10, 10, 10);

// set auto page breaks
$pdf->setAutoPageBreak(true, 15);

// set image scale factor
$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

// set some language-dependent strings (optional)
if (@file_exists(dirname(__FILE__) . '/lang/eng.php')) {
    require_once(dirname(__FILE__) . '/lang/eng.php');
    $pdf->setLanguageArray($l);
}

// Establecer el estilo de fuente
$pdf->SetFont('helvetica', '', 10);
$pdf->AddPage();

// Calcular totales
$totalIva5 = 0;
$totalIva10 = 0;
$totalExenta = 0;
$totalGeneral = 0;

if (!empty($detalles)) {
    foreach ($detalles as $d) {
        $subtotal = $d['precio'] * $d['cantidad'];
        $totalGeneral += $subtotal;
        $totalIva5 += $d['totaliva5'];
        $totalIva10 += $d['totaliva10'];
        $totalExenta += $d['totalexenta'];
    }
}

$totalIva = $totalIva5 + $totalIva10 + $totalExenta;

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
        <td width="30%" class="text-center bordered">
            <div class="large bold">FACTURA</div>
            <div class="medium">N° ' . $cabecera[0]['vc_nro_factura'] . '</div>
        </td>
    </tr>
</table>

<br>

<!-- Información del timbrado y fechas -->
<table width="100%" cellpadding="3" style="font-size: 9px;">
    <tr>
        <td width="50%" class="bordered">
            <strong>TIMBRADO N°:</strong> ' . $cabecera[0]['tim_num_timbrado'] . '<br>
            <strong>VÁLIDO HASTA:</strong> ' . ($cabecera[0]['fechatimvigen'] ?? 'DD/MM/AAAA') . '
        </td>
        <td width="50%" class="bordered">
            <strong>FECHA EMISIÓN:</strong> ' . $cabecera[0]['fecha'] . '<br>
            <strong>CONDICIÓN VENTA:</strong> CONTADO
        </td>
    </tr>
</table>

<br>

<!-- Información del cliente -->
<table width="100%" cellpadding="3" style="font-size: 9px;">
    <tr class="header-bg">
        <td colspan="4" class="bold bordered">DATOS DEL CLIENTE</td>
    </tr>
    <tr>
        <td width="25%" class="bordered"><strong>RAZÓN SOCIAL:</strong></td>
        <td width="25%" class="bordered">' . ($cabecera[0]['cliente'] ?? 'CONSUMIDOR FINAL') . '</td>
        <td width="25%" class="bordered"><strong>RUC/CI:</strong></td>
        <td width="25%" class="bordered">' . ($cabecera[0]['per_ruc'] ?? 'XXXXXXXXX') . '</td>
    </tr>
    <tr>
        <td class="bordered"><strong>DIRECCIÓN:</strong></td>
        <td class="bordered" colspan="3">' . ($cabecera[0]['per_direccion'] ?? 'NO ESPECIFICADA') . '</td>
    </tr>
</table>

<br>

<!-- Tabla de detalles de productos -->
<table width="100%" cellpadding="3" style="font-size: 8px; border: 1px solid #000;">
    <thead>
        <tr class="header-bg">
            <th width="5%" class="bordered text-center">CANT.</th>
            <th width="45%" class="bordered text-center">DESCRIPCIÓN DEL PRODUCTO</th>
            <th width="15%" class="bordered text-center">PRECIO UNIT.</th>
            <th width="15%" class="bordered text-center">IVA 5%</th>
            <th width="10%" class="bordered text-center">IVA 10%</th>
            <th width="10%" class="bordered text-center">EXENTA</th>
        </tr>
    </thead>
    <tbody>';

if (!empty($detalles)) {
    foreach ($detalles as $d) {
        $subtotal = $d['precio'] * $d['cantidad'];
        $html .= '
        <tr>
            <td width="5%" class="bordered text-center">' . $d['cantidad'] . '</td>
            <td width="45%" class="bordered text-left">' . $d['item_descrip'] . ' - ' . $d['mar_descrip'] . '</td>
            <td width="15%" class="bordered text-right">' . number_format($d['precio'], 0, ",", ".") . '</td>
            <td width="15%" class="bordered text-right">' . number_format($d['totaliva5'], 0, ",", ".") . '</td>
            <td width="10%" class="bordered text-right">' . number_format($d['totaliva10'], 0, ",", ".") . '</td>
            <td width="10%" class="bordered text-right">' . number_format($d['totalexenta'], 0, ",", ".") . '</td>
        </tr>';
    }
} else {
    $html .= '
        <tr>
            <td colspan="6" class="bordered text-center">No hay detalles de venta</td>
        </tr>';
}

$html .= '
    </tbody>
</table>

<br>

<!-- Totales -->
<table width="100%" cellpadding="3" style="font-size: 10px;">
    <tr>
        <td width="70%"></td>
        <td width="30%">
            <table width="100%" cellpadding="3">
                <tr>
                    <td class="border-bottom text-right"><strong>TOTAL IVA 5%:</strong></td>
                    <td class="border-bottom text-right">' . number_format($totalIva5, 0, ",", ".") . '</td>
                </tr>
                <tr>
                    <td class="border-bottom text-right"><strong>TOTAL IVA 10%:</strong></td>
                    <td class="border-bottom text-right">' . number_format($totalIva10, 0, ",", ".") . '</td>
                </tr>
                <tr>
                    <td class="border-bottom text-right"><strong>TOTAL EXENTA:</strong></td>
                    <td class="border-bottom text-right">' . number_format($totalExenta, 0, ",", ".") . '</td>
                </tr>
                <tr>
                    <td class="border-top border-bottom text-right bold"><strong>TOTAL IVA:</strong></td>
                    <td class="border-top border-bottom text-right bold">' . number_format($totalIva, 0, ",", ".") . '</td>
                </tr>
                <tr>
                    <td class="border-top text-right bold large"><strong>TOTAL A PAGAR:</strong></td>
                    <td class="border-top text-right bold large">' . number_format($totalGeneral, 0, ",", ".") . '</td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<br>

<!-- Información en letras y datos adicionales -->
<table width="100%" cellpadding="3" style="font-size: 9px;">
    <tr>
        <td class="bordered">
            <strong>TOTAL EN LETRAS:</strong> ' . convertirNumeroLetras($totalGeneral) . '
        </td>
    </tr>
</table>

<br>

<!-- Pie de página -->
<table width="100%" cellpadding="3" style="font-size: 8px;">
    <tr>
        <td class="text-center border-top">
            <strong>USUARIO:</strong> ' . $cabecera[0]['funcionario'] . ' | 
            <strong>SUCURSAL:</strong> ' . $cabecera[0]['suc_nombre'] . '<br>
            <em>Original: Cliente - Copia: Emisor</em><br>
            <strong>"Este documento es válido como factura y comprobante de crédito fiscal"</strong>
        </td>
    </tr>
</table>';

// Función para convertir número a letras (necesitarías implementarla o incluirla)
function convertirNumeroLetras($numero) {
    $formatterES = new NumberFormatter("es", NumberFormatter::SPELLOUT);
    // Aquí deberías implementar la conversión de número a letras
    // Por ahora devolvemos un texto genérico
    // === Total en letras ===
$parteEntera = intval(floor($numero));
$parteDecimal = intval(($numero - floor($numero)) * 100);
//$total_letras = convertirNumeroALetras($cabecera[0]['monto_total']);
$total_letras = ucfirst($formatterES->format($parteEntera));;
if ($parteDecimal > 0) {
    $total_letras .= ' con ' . $parteDecimal . '/100';
}
    return strtoupper($total_letras) . ' GUARANÍES'; // $total_letras;
}

// Agregar el contenido HTML al PDF
$pdf->writeHTML($html, true, false, true, false, '');

//Close and output PDF document
$pdf->Output('factura_' . $cabecera[0]['vc_nro_factura'] . '.pdf', 'I');

pg_close($conn);
?>
