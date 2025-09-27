<?php
include '../../Conexion.php';
include '../../session.php';
require_once '../../TCPDF_v2/tcpdf.php';
$id_inscrip = $_GET['id_inscrip'];

//CONSULTAS
$cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_servicios_inscripciones WHERE id_inscrip = $id_inscrip;"));
$detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_servicios_inscripciones_detalle WHERE id_inscrip = ".$cabecera[0]['id_inscrip']." ORDER BY id_plan_servi;"));
$estado_salud = pg_fetch_all(pg_query($conn, "SELECT * FROM v_clientes_estados_salud WHERE estado = 'ACTIVO' AND id_cliente = " . $cabecera[0]['id_cliente'] . ""));

// Crear una instancia de TCPDF
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);

// Establecer información del documento
$pdf->SetCreator($_SESSION['per_nombre'].' '.$_SESSION['per_apellido']);
$pdf->SetAuthor($_SESSION['per_nombre'].' '.$_SESSION['per_apellido']);
$pdf->SetTitle('Contrato de Isncripción');
$pdf->SetSubject('Contrato de Isncripción');
$pdf->SetKeywords('Inscripción, Servicios, PDF');

// set default monospaced font
$pdf->setDefaultMonospacedFont(PDF_FONT_MONOSPACED);

// set margins
$pdf->setMargins(5, 5, 5);

// set auto page breaks
$pdf->setAutoPageBreak(true, 5);


// set image scale factor
$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

// Agregar una página
$pdf->AddPage();

// Agregar un encabezado con una imagen
$imageFile = 'ruta/a/tu/imagen/logo.png'; // Cambia la ruta a tu imagen de encabezado
$pdf->Image($imageFile, 10, 10, 50);

// Configurar fuentes y estilos
$pdf->SetFont('helvetica', '', 12);


// ====== CABECERA DEL CONTRATO ======
$header = '
<h2 style="text-align:center;">CONTRATO DE INSCRIPCIÓN<br>GIMNASIO ENERGYM FITNESS</h2>
<br>

<table border="1" cellpadding="5" font-size="12">
    <tr style="background-color:#f2f2f2;">
        <td colspan="2"><b>Nro de Inscripción:</b> '.$cabecera[0]['id_inscrip'].'</td>
        <td colspan="2"><b>Fecha Inscripción:</b> '.$cabecera[0]['fecha'].'</td>
    </tr>
    <tr>
        <td colspan="2"><b>Sucursal:</b> '.$_SESSION['suc_nombre'].'</td>
        <td colspan="2"><b>Funcionario:</b> '.$_SESSION['per_nombre'].' '.$_SESSION['per_apellido'].'</td>
    </tr>
    <tr>
        <td colspan="2"><b>Cliente:</b> '.$cabecera[0]['cliente'].'</td>
        <td colspan="2"><b>DNI del Cliente:</b> '.$cabecera[0]['per_ci'].'</td>
    </tr>
    <tr>
        <td><b>Edad:</b> '.$cabecera[0]['ins_edad'].'</td>
        <td><b>Peso:</b> '.$cabecera[0]['ins_peso'].' kg</td>
        <td><b>Altura:</b> '.$cabecera[0]['ins_altura'].' m</td>
        <td><b>Seguro Médico:</b> '.($cabecera[0]['ins_seguro_medico'] == 't' ? 'SI' : 'NO').'</td>
    </tr>
</table>

<br><br>
';

$pdf->writeHTML($header, true, false, true, false, '');

// ====== DETALLE DE PLANES DE SERVICIO ======
$detalle = '
<h3>Planes de Servicio Contratados</h3>
<table border="1" cellpadding="4">
    <tr style="background-color:#f2f2f2;">
        <th><b>Plan de Servicio</b></th>
        <th><b>Duración del Servicio</b></th>
        <th><b>Plan de Servicio</b></th>
    </tr>
';
if (!empty($detalles)) {
foreach ($detalles as $d) {
    $detalle .= '
    <tr>
        <td>'.$d['id_plan_servi'].'</td>
        <td>'.$d['dia'].'</td>
        <td>'.$d['ps_descrip'].'</td>
    </tr>
    ';
}
} else {
    $detalle .= '
    <tr>
        <td colspan="3" style="text-align:center;">No hay planes de servicio contratados.</td>
    </tr>
    ';
}
$detalle .= '
</table>
<br><br>
';
$pdf->writeHTML($detalle, true, false, true, false, '');

// ====== LISTA DE ESTADOS DE SALUD ======
$estados = '
<h3>Estados de Salud del Cliente</h3>
<ul>';
if (!empty($estado_salud)) {
foreach ($estado_salud as $e) {
    $estados .= '
    <li>'.$e['es_nombre'].'</li>
    ';
}
} else {
    $estados .= '
    <li>No hay estados de salud registrados.</li>
    ';
}
$estados .= '
</ul>
<br><br>
';
$pdf->writeHTML($estados, true, false, true, false, '');

// ====== PIE DEL CONTRATO ======
$footer = '
<p style="text-align:justify;">
El presente contrato certifica que el cliente se compromete a cumplir con las normas del gimnasio y
declara bajo su responsabilidad que los datos de salud consignados son verídicos. 
El gimnasio no se responsabiliza por accidentes o lesiones derivadas del incumplimiento de las recomendaciones médicas.
</p>
<br><br><br>
<table border="0" cellpadding="10">
    <tr>
        <td style="text-align:center;">
            _________________________ <br>
            Firma del Cliente
        </td>
        <td style="text-align:center;">
            _________________________ <br>
            Firma del Gimnasio
        </td>
    </tr>
</table>
';
$pdf->writeHTML($footer, true, false, true, false, '');

// Salida del PDF
$pdf->Output('contrato_inscripcion.pdf', 'I');
?>