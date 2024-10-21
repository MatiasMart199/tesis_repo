<?php
require_once '../../tcpdf/tcpdf.php';
include '../../Conexion.php';
include '../../session.php';
$id_cp = $_GET['id_cp'];
$pedidos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra WHERE id_cp = $id_cp;"));
$pedidos_detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra_detalles WHERE id_cp = ".$pedidos[0]['id_cp']." ORDER BY item_descrip, mar_descrip;"));

// Crear instancia de TCPDF
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);

// Establecer la información del documento
$pdf->SetCreator(PDF_CREATOR);
$pdf->SetAuthor('Your Name');
$pdf->SetTitle('Pedido #'.$pedidos[0]['id_cp'].' ');
$pdf->SetSubject('Detalles del Pedido');
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
if (@file_exists(dirname(__FILE__).'/lang/eng.php')) {
    require_once(dirname(__FILE__).'/lang/eng.php');
    $pdf->setLanguageArray($l);
}

// Establecer el estilo de fuente
$pdf->SetFont('helvetica', '', 12);

$pdf->AddPage();

// Agregar el logotipo
//$logoPath = '../../iconos/1.jpg'; // Reemplaza con la ruta de tu logo
//$pdf->Image($logoPath, 10, 10, 30, '', 'JPG', '', 'T', false, 300, '', false, false, 0, false, false, false);


$html='
<div>
    <img src="../../iconos/1.jpg" alt="Logo" style="width: 50px; height: 50px; margin: 0; border-radius: 50%;">

    <p style="width: 50%; text-align: left">
        <b>'.$pedidos[0]['emp_denominacion'].'</b> <br>
         <br>
        <strong>SUCURSAL:</strong> '.$pedidos[0]['suc_nombre'].' <br>
        <strong>ZONA:</strong> '.$pedidos[0]['suc_direccion'].' <br>
        <strong>TELEFONO:</strong> '.$pedidos[0]['suc_telefono'].' <br>
        <strong>CORREO:</strong>: '.$pedidos[0]['suc_correo'].'<br>
        <br>
        <hr>
            <div style="text-align: center;">
                <b>PEDIDO Nro.</b> '.$pedidos[0]['id_cp'].'
            </div>
        <hr>
        
        <div style="text-align: left">
           
            <b></b> 
            
            -------------------------------------------------------------------------------- <br>
        <b>FECHA EMISION: </b> '.$pedidos[0]['fecha'].'<br>
        <b>FECHA APORBACION: </b> '.$pedidos[0]['fecha_aprob'].'<br>
         -------------------------------------------------------------------------------- <br><br>
         <table border="1" cellpadding="3" style="text-align: center;">
    <thead>
    <tr>
        <th class="desc">Producto</th>
        <th>Cantidad</th>
        <th>Precio Unitario</th>
        <th>Subtotal</th>
    </tr>
</thead>
<tbody>';

$total = 0;

if (!empty($pedidos_detalles)) {
    foreach ($pedidos_detalles as $d) {
        $subtotal = $d['precio'] * $d['cantidad'];
        $html .= '
            <tr>
                <td>' . $d['item_descrip'] . ' - ' . $d['mar_descrip'] . '</td>
                <td>' . $d['cantidad'] . '</td>
                <td>' . number_format($d['precio'] , 0, ",", "."). '</td>
                <td>' .number_format($subtotal , 0, ",", "."). '</td>
            </tr>';
        $total += $subtotal;
    }
}
$html .= '
<tr>
<td colspan="3"><b>TOTAL</b></td>
<td class="total">' . number_format($total, 0, ",", "."). '</td>
</tr>
</tbody>
</table>
</p>
<p style="text-align: center">
-------------------------------------------------------------------------------- <br>
<b>USUARIO:</b> '.$pedidos[0]['funcionario'].' <br><br>
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

