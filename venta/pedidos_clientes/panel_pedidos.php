<?php
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_sucursal = $_SESSION['id_sucursal'];
$pedidos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_ventas_pedidos WHERE id_sucursal = $id_sucursal ORDER BY id_vped;"));
?>
<button class="btn btn-success" onclick="agregar();"><i class="fa fa-plus-circle"></i> Agregar</button>
<table width="100%" class="table table-bordered" id="tabla_panel_pedidos">
    <thead>
        <tr>
            <th>#</th>
            <th>Funcionario</th>
            <th>Empresa</th>
            <th>Sucursal</th>
            <th>Cliente</th>
            <th>Observación</th>
            <th>Fecha</th>
            <th>Fecha Confirmacion</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <?php if(!empty($pedidos)){ foreach($pedidos as $p){ ?>
        <tr>
            <td><?php echo $p['id_vped'];?></td>
            <td><?php echo $p['funcionario'];?></td>
            <td><?php echo $p['emp_denominacion'];?></td>
            <td><?php echo $p['suc_nombre'];?></td>
            <td><?php echo $p['cliente'];?></td>
            <td><?php echo $p['vped_observacion'];?></td>
            <td><?php echo $p['fecha'];?></td>
            <td><?php echo $p['fecha_aprob'];?></td>
            <td><?php echo $p['estado'];?></td>
            <td>
                <button class="btn btn-primary" onclick="datos(<?php echo $p['id_vped']; ?>);"><i class="fa fa-list-alt"></i></button>
                <?php if($p['estado'] == 'PENDIENTE'){ ?>
                <button class="btn btn-success" onclick="datos(<?php echo $p['id_vped']; ?>);"><i class="fa fa-check-circle"></i></button>
                <button class="btn btn-warning text-white" onclick="datos(<?php echo $p['id_vped']; ?>);"><i class="fa fa-edit"></i></button>
                <button class="btn btn-danger" onclick="datos(<?php echo $p['id_vped']; ?>);"><i class="fa fa-minus-circle"></i></button>
                <?php } ?>
            </td>
        </tr>
        <?php } } ?>
    </tbody>
</table>