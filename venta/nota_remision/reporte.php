<?php
include '../../Conexion.php';
include '../../session.php';
require('../../tcpdf/tcpdf.php');
$id_cp = $_GET['id_cp'];

//CONSULTAS
$pedidos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra WHERE id_cp = $id_cp;"));
$pedidos_detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra_detalles WHERE id_cp = ".$pedidos[0]['id_cp']." ORDER BY item_descrip, mar_descrip;"));

// Crear una instancia de TCPDF
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);

// Establecer información del documento
$pdf->SetCreator('Tu Nombre');
$pdf->SetAuthor('Tu Nombre');
$pdf->SetTitle('Informe de Pedido de Compras');
$pdf->SetSubject('Informe de Pedido de Compras');
$pdf->SetKeywords('Pedido, Compras, PDF');

// Agregar una página
$pdf->AddPage();

// Agregar un encabezado con una imagen
$imageFile = 'ruta/a/tu/imagen/logo.png'; // Cambia la ruta a tu imagen de encabezado
$pdf->Image($imageFile, 10, 10, 50);

// Configurar fuentes y estilos
$pdf->SetFont('helvetica', '', 12);

// Establecer estilos CSS para la tabla de la cabecera
$styles = '
<style>
    .cabecera-table {
        width: 100%;
        border-collapse: collapse;
    }
    .cabecera-table th, .cabecera-table td {
        padding: 8px;
        border: 1px solid #000;
    }
    .cabecera-table th {
        background-color: #0073e6;
        color: #fff;
    }
</style>';

// Crear una tabla para la cabecera
$thead = '
<table class="cabecera-table">
<thead>
<tr>
    <th>#</th>
    <th>Empresa</th>
    <th>Sucursal</th>
    <th>Funcionario</th>
    <th>Fecha</th>
    <th>Fecha Aprobacion</th>
</tr>
</thead>
<tbody>';

if (!empty($pedidos)) {
    foreach ($pedidos as $p) {
        $thead .= '
        <tr>
            <td>' . $p['id_cp'] . '</td>
            <td>' . $p['emp_denominacion'] . '</td>
            <td>' . $p['suc_nombre'] . '</td>
            <td>' . $p['funcionario'] . '</td>
            <td>' . $p['fecha'] . '</td>
            <td>' . $p['fecha_aprob'] . '</td>
        </tr>';
    }
}

$thead .= '</tbody></table>';
$pdf->writeHTML($styles, true, false, false, false, '');
$pdf->writeHTML($thead, true, false, false, false, '');

// Agregar espacio en blanco
$pdf->Ln(20);

// Establecer estilos CSS para la tabla de detalles
$styles = '
<style>
    .detalles-table {
        width: 100%;
        border-collapse: collapse;
    }
    .detalles-table th, .detalles-table td {
        padding: 8px;
        border: 1px solid #000;
    }
    .center-content {
        text-align: center; /* Centra horizontalmente el contenido */
        display: block; /* Hace que el elemento sea bloque (ocupará toda la línea) */
        width: 100%; /* Ocupa todo el ancho disponible */
        line-height: 2; /* Centra verticalmente el contenido ajustando la altura de línea */
    }
</style>';

// Crear una tabla para los detalles
$tbody = '
<div class="center-content">
    <label>Detalle</label><br><br>
</div>
<table class="detalles-table">
<thead>
<tr>
    <th>Producto</th>
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
        $tbody .= '
        <tr>
            <td>' . $d['item_descrip'] . ' - ' . $d['mar_descrip'] . '</td>
            <td>' . $d['cantidad'] . '</td>
            <td>' . $d['precio'] . '</td>
            <td>' . $subtotal . '</td>
        </tr>';
        $total += $subtotal;
    }
}

$tbody .= '</tbody></table>';
$pdf->writeHTML($styles, true, false, false, false, '');
$pdf->writeHTML($tbody, true, false, false, false, '');

// Agregar el total al final del informe
$pdf->Ln(10);
$pdf->Cell(0, 10, 'Total: ' . number_format($total, 0, ",", "."), 0, 1);

// Generar el PDF y mostrarlo en el navegador
$pdf->Output('informe_pedido_compras.pdf', 'I');

