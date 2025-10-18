<?php 
require "../../Conexion.php";
$conexion = new Conexion();
$conn = $conexion->getConexion();
$clientes = pg_fetch_all(pg_query ($conn, "SELECT * FROM v_clientes_r"));
?>

<table class="table table-bordered" id="tabla_datos" style="font-size: 14px; width: 100%;">
    <thead>
        <tr>
            <th>#</th>
            <th>Cliente</th>
            <th>RUC</th>
            <th>C.I</th>
            <th>Direccion</th>
            <th>Correo</th>
            <th>Telefono</th>
            <th>Ciudad</th>
            <th>Edo. Civil</th>
            <th>Genero</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <?php if(!empty($clientes)){ foreach($clientes as $c){ ?>
            <tr>
                <td><?= $c['id_cliente']; ?></td>
                <td><?= $c['cliente']; ?></td>
                <td><?= $c['per_ruc']; ?></td>
                <td><?= $c['per_ci']; ?></td>
                <td><?= $c['per_direccion']; ?></td>
                <td><?= $c['per_correo']; ?></td>
                <td><?= $c['per_telefono']; ?></td>
                <td><?= $c['ciu_descrip']; ?></td>
                <td><?= $c['ec_descrip']; ?></td>
                <td><?= $c['gen_descrip']; ?></td>
                <td><?= $c['estado']; ?></td>
                <td>
                    <?php if($c['estado'] == 'ACTIVO') {?>
                    <button class="btn btn-danger" title="Inactivar" onclick="inactivar(<?= $c['id_cliente'];?>);"><i class="fa fa-minus-circle"></i></button>
                    <button class="btn btn-warning text-white" title="Editar" onclick="editar(<?= $c['id_cliente'];?>);"><i class="fa fa-edit"></i></button>
                    <?php }else{ ?>
                    <button class="btn btn-success" title="Activar" onclick="activar(<?= $c['id_cliente'];?>);"> <i class="fa fa-check-circle"></i></button>
                
                    <?php } ?>
                </td>
            </tr>
        <?php } }else{ ?>

        <?php } ?>
    </tbody>
</table>
