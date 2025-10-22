<?php
include '../../Conexion.php';
include '../../session.php';
require_once '../../TCPDF_v2/tcpdf.php';

$id_cpre = $_GET['id_cpre'];

// === Obtener datos ===
$cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_presupuestos WHERE id_cpre = $id_cpre;"));
$detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_presupuestos_consolidacion WHERE id_cpre = $id_cpre ORDER BY id_item ASC;"));

// === Crear documento ===
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, 'LETTER', true, 'UTF-8', false);
$pdf->SetCreator('Sistema de Compras');
$pdf->SetAuthor('Sistema de Compras');
$pdf->SetTitle('Presupuesto #' . $cabecera[0]['cpre_numero']);
$pdf->SetMargins(15, 15, 15);
$pdf->setPrintHeader(false);
$pdf->setPrintFooter(false);

$pdf->setDefaultMonospacedFont(PDF_FONT_MONOSPACED);
$pdf->setAutoPageBreak(true, 15);
$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

// Configurar fuentes y estilos
$pdf->SetFont('helvetica', '', 10);
$pdf->AddPage();

// Calcular subtotal
$subtotal = 0;
if (!empty($detalles)) {
    foreach ($detalles as $d) {
        $subtotal += $d['cantidad'] * $d['precio'];
    }
}

// Usar monto total de la vista
$totalGeneral = $cabecera[0]['monto_total'] ?? $subtotal;

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
    .provider-bg { background-color: #f0f8ff; }
    .company-bg { background-color: #fff0f0; }
</style>

<!-- Encabezado de la empresa -->
<table width="100%" cellpadding="4" style="margin-bottom: 10px;">
    <tr>
        <td width="20%" class="text-left">
            <img src="../../iconos/1.jpg" alt="Logo" style="width: 70px; height: 70px;">
        </td>
        <td width="60%" class="text-center">
            <div class="large bold">' . strtoupper($cabecera[0]['emp_denominacion']) . '</div>
            <div class="small">RUC: ' . $cabecera[0]['emp_ruc'] . '</div>
            <div class="small">' . $cabecera[0]['suc_direccion'] . '</div>
            <div class="small">Tel: ' . $cabecera[0]['suc_telefono'] . ' - Email: ' . $cabecera[0]['suc_correo'] . '</div>
        </td>
        <td width="20%" class="text-center bordered" style="background-color: #fff0f0;">
            <div class="medium bold">PRESUPUESTO</div>
            <div class="small">N° ' . $cabecera[0]['cpre_numero'] . '</div>
        </td>
    </tr>
</table>

<hr style="border: 1px solid #000; margin: 5px 0;">

<!-- Información del proveedor -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr class="provider-bg">
        <td colspan="4" class="bold bordered">DATOS DEL PROVEEDOR</td>
    </tr>
    <tr>
        <td width="25%" class="bordered"><strong>RAZÓN SOCIAL:</strong></td>
        <td width="25%" class="bordered">' . $cabecera[0]['proveedor'] . '</td>
        <td width="25%" class="bordered"><strong>PRESUPUESTO N°:</strong></td>
        <td width="25%" class="bordered">' . $cabecera[0]['cpre_numero'] . '</td>
    </tr>
    <tr>
        <td class="bordered"><strong>FUNCIONARIO:</strong></td>
        <td class="bordered">' . $cabecera[0]['funcionario'] . '</td>
        <td class="bordered"><strong>SUCURSAL:</strong></td>
        <td class="bordered">' . $cabecera[0]['suc_nombre'] . '</td>
    </tr>
</table>

<!-- Información del presupuesto -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr>
        <td width="50%" class="bordered">
            <strong>FECHA EMISIÓN:</strong> ' . $cabecera[0]['fecha'] . '<br>
            <strong>FECHA VENCIMIENTO:</strong> ' . $cabecera[0]['fecha_validez'] . '<br>
            <strong>VÁLIDO POR:</strong> ' . (($cabecera[0]['cpre_validez']) ? 'HASTA ' . $cabecera[0]['fecha_validez'] : 'NO ESPECIFICADO') . '
        </td>
        <td width="50%" class="bordered">
            <strong>MONTO DETALLES:</strong> ' . number_format($cabecera[0]['monto_detalles'], 0, ",", ".") . ' Gs.<br>
            <strong>MONTO PEDIDOS:</strong> ' . number_format($cabecera[0]['monto_pedido'], 0, ",", ".") . ' Gs.<br>
            <strong>MONEDA:</strong> GUARANÍES
        </td>
    </tr>
</table>

<!-- Observaciones -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr class="header-bg">
        <td class="bold bordered">OBSERVACIONES / CONDICIONES</td>
    </tr>
    <tr>
        <td class="bordered" style="height: 40px;">' . ($cabecera[0]['cpre_observacion'] ?? 'Presupuesto sujeto a disponibilidad de stock. Precios no incluyen flete.') . '</td>
    </tr>
</table>

<!-- Tabla de detalles de productos -->
<table width="100%" cellpadding="4" style="font-size: 8px; border: 1px solid #000; margin-bottom: 10px;">
    <thead>
        <tr class="header-bg">
            <th width="5%" class="bordered text-center">ITEM</th>
            <th width="8%" class="bordered text-center">CANT.</th>
            <th width="47%" class="bordered text-center">DESCRIPCIÓN DEL PRODUCTO</th>
            <th width="20%" class="bordered text-center">PRECIO UNIT.</th>
            <th width="20%" class="bordered text-center">SUBTOTAL</th>
        </tr>
    </thead>
    <tbody>';

if (!empty($detalles)) {
    $contador = 1;
    foreach ($detalles as $d) {
        $subtotalItem = $d['cantidad'] * $d['precio'];
        $html .= '
        <tr>
            <td width="5%" class="bordered text-center">' . $contador . '</td>
            <td width="8%" class="bordered text-center">' . $d['cantidad'] . '</td>
            <td width="47%" class="bordered text-left">' . $d['item_descrip'] . ' - ' . $d['mar_descrip'] . ' (' . $d['tip_item_descrip'] . ')</td>
            <td width="20%" class="bordered text-right">' . number_format($d['precio'], 0, ",", ".") . '</td>
            <td width="20%" class="bordered text-right">' . number_format($subtotalItem, 0, ",", ".") . '</td>
        </tr>';
        $contador++;
    }
} else {
    $html .= '
        <tr>
            <td colspan="5" class="bordered text-center">No hay items en este presupuesto</td>
        </tr>';
}

$html .= '
    </tbody>
</table>

<!-- Totales -->
<table width="100%" cellpadding="4" style="font-size: 10px; margin-bottom: 10px;">
    <tr>
        <td width="70%">
            <table width="100%" cellpadding="3">
                <tr>
                    <td class="text-left"><strong>INFORMACIÓN ADICIONAL:</strong></td>
                </tr>
                <tr>
                    <td class="small" style="height: 30px;">
                        • Presupuesto válido hasta: ' . $cabecera[0]['fecha_validez'] . '<br>
                        • Forma de pago: A convenir<br>
                        • Tiempo de entrega: A convenir
                    </td>
                </tr>
            </table>
        </td>
        <td width="30%">
            <table width="100%" cellpadding="3">
                <tr>
                    <td class="border-bottom text-right"><strong>SUBTOTAL:</strong></td>
                    <td class="border-bottom text-right">' . number_format($cabecera[0]['monto_detalles'], 0, ",", ".") . '</td>
                </tr>
                <tr>
                    <td class="border-bottom text-right"><strong>PEDIDOS:</strong></td>
                    <td class="border-bottom text-right">' . number_format($cabecera[0]['monto_pedido'], 0, ",", ".") . '</td>
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
            <strong>FIRMA DEL PROVEEDOR</strong><br>
            <span class="small">Aclaración y RUC</span>
        </td>
        <td width="50%" class="text-center">
            <div style="border-bottom: 1px dashed #666; height: 40px; margin-bottom: 5px;"></div>
            <strong>FIRMA Y SELLO DE LA EMPRESA</strong><br>
            <span class="small">' . $cabecera[0]['funcionario'] . '</span>
        </td>
    </tr>
</table>

<!-- Pie de página -->
<table width="100%" cellpadding="3" style="font-size: 8px;">
    <tr>
        <td class="text-center border-top">
            <strong>ORIGINAL: PROVEEDOR - COPIA: EMPRESA</strong><br>
            <em>Documento de cotización - No válido como factura</em>
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
$pdf->Output('presupuesto_' . $cabecera[0]['cpre_numero'] . '.pdf', 'I');

pg_close($conn);
?>