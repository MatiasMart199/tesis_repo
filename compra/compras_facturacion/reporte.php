<?php
//require_once '../../tcpdf/tcpdf.php';
require_once '../../TCPDF_v2/tcpdf.php';
include '../../Conexion.php';
include '../../session.php';
$id_cc = $_GET['id_cc'];
$cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_cab WHERE id_cc = $id_cc;"));
$detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_cal_impuesto_compra WHERE id_cc = $id_cc ORDER BY id_cc asc;"));

// Crear instancia de TCPDF
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);

// Establecer la información del documento
$pdf->SetCreator(PDF_CREATOR);
$pdf->SetAuthor('Your Name');
$pdf->SetTitle('Compra #' . $cabecera[0]['id_cc'] . ' ');
$pdf->SetSubject('Detalles de la compra');
$pdf->SetKeywords('TCPDF, PDF, example, test, guide');

$pdf->setPrintHeader(false);
$pdf->setPrintFooter(false);

// set default monospaced font
$pdf->setDefaultMonospacedFont(PDF_FONT_MONOSPACED);

// set margins
$pdf->setMargins(5, 5, 5);

// set auto page breaks
$pdf->setAutoPageBreak(true, 5);


// set image scale factor
$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

// set some language-dependent strings (optional)
if (@file_exists(dirname(__FILE__) . '/lang/eng.php')) {
    require_once(dirname(__FILE__) . '/lang/eng.php');
    $pdf->setLanguageArray($l);
}

// Establecer el estilo de fuente
$pdf->SetFont('helvetica', '', 12);

$pdf->AddPage();

// Agregar el logotipo
//$logoPath = '../../iconos/1.jpg'; // Reemplaza con la ruta de tu logo
//$pdf->Image($logoPath, 10, 10, 30, '', 'JPG', '', 'T', false, 300, '', false, false, 0, false, false, false);


$html = '
<div>
    <img src="../../iconos/1.jpg" alt="Logo" style="width: 50px; height: 50px; margin: 0; border-radius: 50%;">
    <div style="margin-top: 3px;">
    <hr>
        <div style="text-align: center;">
            <b>FACTURA</b>
         </div>
    <hr>
    </div>
    

    <p style="width: 50%; text-align: left">
        <b>' . $cabecera[0]['emp_denominacion'] . '</b> <br>
         <br>
        <strong>SUCURSAL:</strong> ' . $cabecera[0]['suc_nombre'] . ' <br>
        <strong>ZONA:</strong> ' . $cabecera[0]['suc_direccion'] . ' <br>
        <strong>TELÉFONO:</strong> ' . $cabecera[0]['suc_telefono'] . ' <br>
        <strong>CORREO:</strong>: ' . $cabecera[0]['suc_correo'] . '<br>
        
        <br>
        
        
        <div style="text-align: left">
           
            <b></b> 
            
            -------------------------------------------------------------------------------- <br>
        <b>FECHA EMISION: </b> ' . $cabecera[0]['fecha'] . '<br>
        <strong>Nro FACTURA</strong>: ' . $cabecera[0]['cc_nro_factura'] . '<br>
        <strong>Nro TIMBRADO</strong>: ' . $cabecera[0]['cc_timbrado'] . '<br>
         -------------------------------------------------------------------------------- <br><br>
         <table border="1" cellpadding="3" style="text-align: center; font-size: 12px">
    <thead>
    <tr>
    <th colspan="3">Detalles</th>
    <th colspan="3">IVA</th>
    </tr>
        
    <tr>
        <th class="desc">Producto</th>
        <th>Cant</th>
        <th>Precio Unitario</th>
        <th>Iva 5</th>
        <th>Iva 10</th>
        <th>Exenta</th>
    </tr>
</thead>
<tbody>';

$total = 0;
$totalIva = 0;

if (!empty($detalles)) {
    foreach ($detalles as $d) {
        $subtotal = $d['precio'] * $d['cantidad'];
        $total += $subtotal;
        $totalIva += $d['totaliva5'] + $d['totaliva10'] + $d['totalexenta'];
        $html .= '
            <tr>
                <td>' . $d['item_descrip'] . ' - ' . $d['mar_descrip'] . '</td>
                <td>' . $d['cantidad'] . '</td>
                <td>' . number_format($d['precio'], 0, ",", ".") . '</td>
                <td>' . number_format($d['totaliva5'], 0, ",", ".") . '</td>
                <td>' . number_format($d['totaliva10'], 0, ",", ".") . '</td>
                <td>' . number_format($d['totalexenta'], 0, ",", ".") . '</td>
            </tr>';
    }
}
$html .= '
<tr>
<td colspan="3"><b>TOTAL IVA</b></td>
<td colspan="3" class="total">' . number_format($totalIva, 0, ",", ".") . '</td>
</tr>
<tr>
<td colspan="3"><b>TOTAL A PAGAR</b></td>
<td colspan="3" class="total">' . number_format($total, 0, ",", ".") . '</td>
</tr>
</tbody>
</table>
</p>
<p style="text-align: center">
-------------------------------------------------------------------------------- <br>
<b>USUARIO:</b> ' . $cabecera[0]['funcionario'] . ' <br><br>
<p style="text-align: center">
</p>
<p style="text-align: center">
</p>
<p style="text-align: center"><b> </b></p>
</div>
</p>
</div>
/*'; // Agrega este bloque de comentarios para evitar la sobreescritura de $html


// Contenido del PDF




// Agregar el contenido HTML al PDF
$pdf->writeHTML($html, true, false, true, false, '');

//Close and output PDF document
$pdf->Output('example_002.pdf', 'I');
