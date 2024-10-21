<?php
require_once '../../tcpdf/tcpdf.php';
include '../../Conexion.php';
include '../../session.php';

$pedidos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra WHERE id_cp = 1;"));
$pedidos_detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra_detalles WHERE id_cp = ".$pedidos[0]['id_cp']." ORDER BY item_descrip, mar_descrip;"));

// Crear instancia de TCPDF
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);

// Establecer la información del documento
$pdf->SetCreator(PDF_CREATOR);
$pdf->SetAuthor('Your Name');
$pdf->SetTitle('Pedido #'.$pedidos[0]['id_cp'].' - Detalles');
$pdf->SetSubject('Detalles del Pedido');
$pdf->SetKeywords('TCPDF, PDF, example, test, guide');

// Agregar una página al PDF
$pdf->AddPage();
$pdf->SetAutoPageBreak(true, 20);
$pdf->SetTopMargin(15);
$pdf->SetLeftMargin(10);
$pdf->SetRightMargin(10);

$pdf->setY(60);
$pdf->setX(135);
$pdf->Ln();

// Establecer el estilo de fuente
$pdf->SetFont('helvetica', '', 12);

//cabecera
$pdf->Cell(20, 7, 'Cod', 1, 0, 'C', 0);
$pdf->Cell(95, 7, 'Descripción', 1, 0, 'C', 0);
$pdf->Cell(20, 7, 'Cant', 1, 0, 'C', 0);
$pdf->Cell(25, 7, 'Precio', 1, 0, 'C', 0);
$pdf->Cell(25, 7, 'Total', 1, 1, 'C', 0);

// Contenido del PDF
$html = '
    <h1>PEDIDO # '.$pedidos[0]['id_cp'].'</h1>
    <div id="company" class="clearfix">
        <div>'.$pedidos[0]['emp_denominacion'].'</div>
        <div>'.$_SESSION['suc_direccion'].',<br /> '.$_SESSION['suc_ubicacion'].', PY</div>
        <div>'.$_SESSION['suc_telefono'].'</div>
        <div><a href="mailto:'.$_SESSION['suc_correo'].'">'.$_SESSION['suc_correo'].'</a></div>
    </div>
    <div id="project">
        <div><span>FUNCIONARIO: </span>'.$pedidos[0]['funcionario'].'</div>
        <div><span>SUCURSAL: </span> '.$pedidos[0]['suc_nombre'].', PY</div>
        <div><span>FECHA EMISION: </span>'.$pedidos[0]['fecha'].'</div>
        <div><span>FECHA APORBACION: </span>'.$pedidos[0]['fecha_aprob'].'</div>
    </div>
    <table>
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
                <td>' . $d['precio'] . '</td>
                <td>' . $subtotal . '</td>
            </tr>';
        $total += $subtotal;
    }
}

$html .= '
            <tr>
                <td colspan="3">TOTAL</td>
                <td class="total">' . $total . '</td>
            </tr>
        </tbody>
    </table>
    <footer>Invoice was created on a computer and is valid without the signature and seal.</footer>
';

// Agregar el contenido HTML al PDF
$pdf->writeHTML($html, true, false, true, false, '');

// Cerrar y generar el archivo PDF
$pdf->Output('Pedido_'.$pedidos[0]['id_cp'].'_Detalles.pdf', 'I');


$html='
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Documento con Esquinas Redondeadas</title>
    <style>
        .container {
            border-radius: 15px; /* Ajusta el valor según sea necesario */
            overflow: hidden;
            border: 1px solid #ccc; /* Puedes ajustar el color del borde según sea necesario */
            display: inline-block; /* Evita que el contenedor ocupe todo el ancho disponible */
        }

        img {
            width: 100px; /* Ajusta el ancho de la imagen para que llene el contenedor */
            height: auto; /* Permite que la altura se ajuste automáticamente para mantener la proporción */
            border-bottom-left-radius: 15px; /* Ajusta el valor según sea necesario para redondear solo la esquina inferior izquierda */
            border-bottom-right-radius: 15px; /* Ajusta el valor según sea necesario para redondear solo la esquina inferior derecha */
        }

        .content {
            padding: 20px;
        }
    </style>
</head>
<body>

<div class="container">
    <img src="../../iconos/1.jpg" alt="LOGO">
    <div class="content">
<div>
    <p style="text-align: center">
        <b>'.$pedidos[0]['emp_denominacion'].'</b> <br>
        '.$actividad_empresa.' <br>
        SUCURSAL: '.$_SESSION['suc_nombre'].' <br>
        '.$_SESSION['suc_direccion'].' <br>
        ZONA: '.$_SESSION['suc_ubicacion'].' <br>
        TELÉFONO: '.$_SESSION['suc_telefono'].' <br>
        CORREO: '.$_SESSION['suc_correo'].'<br>
        --------------------------------------------------------------------------------<br>
         <b>PEDIDO Nro.</b> '.$pedidos[0]['id_cp'].' <br>
        --------------------------------------------------------------------------------
        <div style="text-align: left">
           
            <b></b> <br> <br> <br>
            
            -------------------------------------------------------------------------------- <br>
        <b>FECHA EMISION: </b> '.$pedidos[0]['fecha'].'<br>
        <b>FECHA APORBACION: </b> '.$pedidos[0]['fecha_aprob'].'<br>
         -------------------------------------------------------------------------------- <br>
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

-------------------------------------------------------------------------------- <br>
<b>USUARIO:</b> '.$pedidos[0]['funcionario'].' <br><br><br><br>
<p style="text-align: center">
</p>
<p style="text-align: center">
</p>
<p style="text-align: center"><b> </b></p>
</div>
</p>
</div>
</div>
</div>

</body>
</html>

'; // Agrega este bloque de comentarios para evitar la sobreescritura de $html
