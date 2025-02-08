<?php
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_sucursal = $_SESSION['id_sucursal'];
$pedidos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_aperturas_cierres WHERE id_sucursal = $id_sucursal ORDER BY id_vac;"));
?>
<button class="btn btn-success" onclick="agregar();"><i class="fa fa-plus-circle"></i> Agregar</button>
<table width="100%" class="table table-bordered" id="tabla_panel_aperturas">
    <thead>
        <tr>
            <th>#</th>
            <th>Funcionario</th>
            <th>Empresa</th>
            <th>Sucursal</th>
            <th>Apertura</th>
            <th>Cierre</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <?php if(!empty($pedidos)){ foreach($pedidos as $p){ ?>
        <tr>
            <td><?= $p['id_vac'];?></td>
            <td><?= $p['funcionario'];?></td>
            <td><?= $p['emp_denominacion'];?></td>
            <td><?= $p['suc_nombre'];?></td>
            <td><?= $p['apertura'];?></td>
            <td><?= $p['cierre'];?></td>
            <td><?= $p['estado'];?></td>
            <td>
                <button class="btn btn-primary" onclick="datos(<?php echo $p['id_vac']; ?>);"><i class="fa fa-list-alt"></i></button>
                <button class="btn btn-success" onclick="generarInforme(<?php echo $p['id_vac']; ?>);"><i class="fas fa-file-pdf" id="btn-reporte"></i></button>
                <?php if($p['estado'] == 'ABIERTO' || $p['estado'] == 'CERRADO'){ ?>
                <button class="btn btn-success" onclick="datos(<?php echo $p['id_vac']; ?>);"><i class="fa fa-check-circle"></i></button>
                <button class="btn btn-warning text-white" onclick="datos(<?php echo $p['id_vac']; ?>);"><i class="fa fa-edit"></i></button>
                <button class="btn btn-danger" onclick="datos(<?php echo $p['id_vac']; ?>);"><i class="fa fa-minus-circle"></i></button>
                <?php } ?>
            </td>
        </tr>
        <?php } } ?>
    </tbody>
</table>