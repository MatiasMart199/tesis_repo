<?php
include '../../Conexion.php';
include '../../session.php';
require_once '../../TCPDF_v2/tcpdf.php';

$id_corden = $_GET['id_corden'];

// === Obtener datos ===
$cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_ordenes WHERE id_corden = $id_corden;"));
$detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_orden_consolidacion WHERE id_corden = $id_corden ORDER BY id_item ASC;"));

// === Crear documento ===
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, 'LETTER', true, 'UTF-8', false);
$pdf->SetCreator('Sistema de Compras');
$pdf->SetAuthor('Sistema de Compras');
$pdf->SetTitle('Orden de Compra #' . $id_corden);
$pdf->SetMargins(15, 15, 15);
$pdf->setPrintHeader(false);
$pdf->setPrintFooter(false);

$pdf->setDefaultMonospacedFont(PDF_FONT_MONOSPACED);
$pdf->setAutoPageBreak(true, 15);
$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

// Configurar fuentes y estilos
$pdf->SetFont('helvetica', '', 10);
$pdf->AddPage();

// === Calcular impuestos para proteínas ===
$subtotal = 0;
$totalIva5 = 0;
$totalIva10 = 0;
$totalExenta = 0;

if (!empty($detalles)) {
    foreach ($detalles as $d) {
        $subtotalItem = $d['sum'] * $d['precio'];
        $subtotal += $subtotalItem;
        
        // Determinar tasa de IVA según tipo de producto (proteínas)
        // En Paraguay, las proteínas generalmente tienen IVA 10%
        // Pero algunos productos pueden tener IVA 5% o ser exentos
        $tipoProducto = strtolower($d['tip_item_descrip'] ?? '');
        $descripcion = strtolower($d['item_descrip'] ?? '');
        
        // Lógica para determinar el IVA (puedes ajustar según tus productos)
        if (esProductoExento($tipoProducto, $descripcion)) {
            $totalExenta += $subtotalItem;
        } elseif (esProductoIva5($tipoProducto, $descripcion)) {
            $ivaItem = $subtotalItem * 0.05;
            $totalIva5 += $ivaItem;
        } else {
            // IVA 10% por defecto para proteínas
            $ivaItem = $subtotalItem * 0.10;
            $totalIva10 += $ivaItem;
        }
    }
}

$totalIva = $totalIva5 + $totalIva10;
$totalGeneral = $subtotal + $totalIva;

// Usar monto total de la vista si está disponible
if (!empty($cabecera[0]['monto_total']) && $cabecera[0]['monto_total'] > 0) {
    $totalGeneral = $cabecera[0]['monto_total'];
    // Recalcular subtotal basado en el total general y los impuestos
    $subtotal = $totalGeneral - $totalIva;
}

// Funciones para determinar impuestos (ajusta según tus productos)
function esProductoExento($tipoProducto, $descripcion) {
    // Productos exentos de IVA (ejemplo: algunos medicamentos o productos básicos)
    $exentos = ['medicamento', 'vitamina', 'suplemento médico', 'producto básico'];
    foreach ($exentos as $exento) {
        if (strpos($tipoProducto, $exento) !== false || strpos($descripcion, $exento) !== false) {
            return true;
        }
    }
    return false;
}

function esProductoIva5($tipoProducto, $descripcion) {
    // Productos con IVA 5% (ejemplo: algunos alimentos básicos)
    $iva5 = ['leche', 'huevo', 'lácteo', 'alimento básico', 'cereal'];
    foreach ($iva5 as $producto) {
        if (strpos($tipoProducto, $producto) !== false || strpos($descripcion, $producto) !== false) {
            return true;
        }
    }
    return false;
}

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
    .order-bg { background-color: #fff8dc; }
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
        <td width="20%" class="text-center bordered" style="background-color: #fff8dc;">
            <div class="medium bold">ORDEN DE COMPRA</div>
            <div class="small">N° ' . $cabecera[0]['id_corden'] . '</div>
            <div class="small">Estado: ' . strtoupper($cabecera[0]['estado'] ?? 'PENDIENTE') . '</div>
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
        <td width="25%" class="bordered"><strong>PROVEEDOR:</strong></td>
        <td width="25%" class="bordered">' . $cabecera[0]['proveedor'] . '</td>
        <td width="25%" class="bordered"><strong>ORDEN N°:</strong></td>
        <td width="25%" class="bordered">' . $cabecera[0]['id_corden'] . '</td>
    </tr>
    <tr>
        <td class="bordered"><strong>SOLICITANTE:</strong></td>
        <td class="bordered">' . $cabecera[0]['funcionario'] . '</td>
        <td class="bordered"><strong>SUCURSAL:</strong></td>
        <td class="bordered">' . $cabecera[0]['suc_nombre'] . '</td>
    </tr>
</table>

<!-- Información de la orden -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr>
        <td width="50%" class="bordered">
            <strong>FECHA EMISIÓN:</strong> ' . $cabecera[0]['fecha'] . '<br>
            <strong>TIPO FACTURA:</strong> ' . ($cabecera[0]['ord_tipo_factura'] ?? 'CONTADO') . '<br>
            <strong>CONDICIÓN PAGO:</strong> ' . (($cabecera[0]['ord_cuota'] > 1) ? $cabecera[0]['ord_cuota'] . ' CUOTAS' : 'CONTADO') . '
        </td>
        <td width="50%" class="bordered">
            <strong>MONTO DETALLES:</strong> ' . number_format($cabecera[0]['monto_detalles'], 0, ",", ".") . ' Gs.<br>
            <strong>MONTO PEDIDOS:</strong> ' . number_format($cabecera[0]['monto_pedido'], 0, ",", ".") . ' Gs.<br>
            <strong>MONEDA:</strong> GUARANÍES
        </td>
    </tr>
</table>

<!-- Instrucciones de entrega -->
<table width="100%" cellpadding="4" style="font-size: 9px; margin-bottom: 10px;">
    <tr class="header-bg">
        <td class="bold bordered">INSTRUCCIONES DE ENTREGA</td>
    </tr>
    <tr>
        <td class="bordered">
            • Lugar de entrega: ' . $cabecera[0]['suc_direccion'] . '<br>
            • Contacto: ' . $cabecera[0]['funcionario'] . ' - Tel: ' . $cabecera[0]['suc_telefono'] . '<br>
            • Horario de recepción: Lunes a Viernes 08:00 - 17:00
        </td>
    </tr>
</table>

<!-- Tabla de detalles de productos -->
<table width="100%" cellpadding="4" style="font-size: 8px; border: 1px solid #000; margin-bottom: 10px;">
    <thead>
        <tr class="header-bg">
            <th width="5%" class="bordered text-center">ITEM</th>
            <th width="8%" class="bordered text-center">CANT.</th>
            <th width="37%" class="bordered text-center">DESCRIPCIÓN DEL PRODUCTO</th>
            <th width="15%" class="bordered text-center">PRECIO UNIT.</th>
            <th width="15%" class="bordered text-center">SUBTOTAL</th>
            <th width="10%" class="bordered text-center">IVA 5%</th>
            <th width="10%" class="bordered text-center">IVA 10%</th>
        </tr>
    </thead>
    <tbody>';

if (!empty($detalles)) {
    $contador = 1;
    foreach ($detalles as $d) {
        $subtotalItem = $d['sum'] * $d['precio'];
        
        // Determinar IVA para este item
        $tipoProducto = strtolower($d['tip_item_descrip'] ?? '');
        $descripcion = strtolower($d['item_descrip'] ?? '');
        
        $iva5 = 0;
        $iva10 = 0;
        
        if (esProductoExento($tipoProducto, $descripcion)) {
            // Exento - no suma IVA
        } elseif (esProductoIva5($tipoProducto, $descripcion)) {
            $iva5 = $subtotalItem * 0.05;
        } else {
            $iva10 = $subtotalItem * 0.10;
        }
        
        $html .= '
        <tr>
            <td width="5%" class="bordered text-center">' . $contador . '</td>
            <td width="8%" class="bordered text-center">' . $d['sum'] . '</td>
            <td width="37%" class="bordered text-left">' . $d['item_descrip'] . ' - ' . $d['mar_descrip'] . '<br><small>' . $d['tip_item_descrip'] . '</small></td>
            <td width="15%" class="bordered text-right">' . number_format($d['precio'], 0, ",", ".") . '</td>
            <td width="15%" class="bordered text-right">' . number_format($subtotalItem, 0, ",", ".") . '</td>
            <td width="10%" class="bordered text-right">' . number_format($iva5, 0, ",", ".") . '</td>
            <td width="10%" class="bordered text-right">' . number_format($iva10, 0, ",", ".") . '</td>
        </tr>';
        $contador++;
    }
} else {
    $html .= '
        <tr>
            <td colspan="7" class="bordered text-center">No hay items en esta orden de compra</td>
        </tr>';
}

$html .= '
    </tbody>
</table>

<!-- Totales con impuestos -->
<table width="100%" cellpadding="4" style="font-size: 10px; margin-bottom: 10px;">
    <tr>
        <td width="60%">
            <table width="100%" cellpadding="3">
                <tr>
                    <td class="text-left"><strong>CONDICIONES Y OBSERVACIONES:</strong></td>
                </tr>
                <tr>
                    <td class="small" style="height: 50px;">
                        • Todos los productos deben cumplir con las normas de calidad vigentes<br>
                        • Factura debe incluir RUC: ' . $cabecera[0]['emp_ruc'] . '<br>
                        • Entregar en ' . $cabecera[0]['suc_direccion'] . '<br>
                        • ' . ($cabecera[0]['auditoria'] ?? 'Orden sujeta a verificación de calidad').'
                    </td>
                </tr>
            </table>
        </td>
        <td width="40%">
            <table width="100%" cellpadding="3">
                <tr>
                    <td class="border-bottom text-right"><strong>SUBTOTAL:</strong></td>
                    <td class="border-bottom text-right">' . number_format($subtotal, 0, ",", ".") . '</td>
                </tr>
                <tr>
                    <td class="border-bottom text-right"><strong>IVA 5%:</strong></td>
                    <td class="border-bottom text-right">' . number_format($totalIva5, 0, ",", ".") . '</td>
                </tr>
                <tr>
                    <td class="border-bottom text-right"><strong>IVA 10%:</strong></td>
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
                    <td class="border-top text-right bold large"><strong>TOTAL GENERAL:</strong></td>
                    <td class="border-top text-right bold large">' . number_format($totalGeneral, 0, ",", ".") . ' Gs.</td>
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
        <td width="33%" class="text-center">
            <div style="border-bottom: 1px dashed #666; height: 40px; margin-bottom: 5px;"></div>
            <strong>SOLICITANTE</strong><br>
            <span class="small">' . $cabecera[0]['funcionario'] . '</span>
        </td>
        <td width="33%" class="text-center">
            <div style="border-bottom: 1px dashed #666; height: 40px; margin-bottom: 5px;"></div>
            <strong>AUTORIZADO POR</strong><br>
            <span class="small">Gerencia / Administración</span>
        </td>
        <td width="34%" class="text-center">
            <div style="border-bottom: 1px dashed #666; height: 40px; margin-bottom: 5px;"></div>
            <strong>PROVEEDOR</strong><br>
            <span class="small">Firma y Sello</span>
        </td>
    </tr>
</table>

<!-- Pie de página -->
<table width="100%" cellpadding="3" style="font-size: 8px;">
    <tr>
        <td class="text-center border-top">
            <strong>ORIGINAL: PROVEEDOR - COPIA: COMPRAS - COPIA: CONTABILIDAD</strong><br>
            <em>Documento interno - No válido como factura</em>
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
$pdf->Output('orden_compra_' . $cabecera[0]['id_corden'] . '.pdf', 'I');

pg_close($conn);
?>