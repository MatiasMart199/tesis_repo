<?php 
require "../../Conexion.php";
$conexion = new Conexion();
$conn = $conexion->getConexion();
$planes = pg_fetch_all(pg_query ($conn, "SELECT * FROM v_planes_servicios"));
?>

<table class="table table-bordered" id="tabla_datos">
    <thead>
        <tr>
            <th>#</th>
            <th>Descripción</th>
            <th>Precio</th>
            <th>Promoción</th>
            <th>Duración</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <?php if(!empty($planes)){ foreach($planes as $c){ ?>
            <tr>
                <td><?= $c['id_plan_servi']; ?></td>
                <td><?= $c['ps_descrip']; ?></td>
                <td><?= $c['precio_servicio']; ?></td>
                <td><?= $c['pro_nombre']; ?></td>
                <td><?= $c['td_descrip']; ?></td>
                <td><?= $c['estado']; ?></td>
                <td>
                    <?php if($c['estado'] == 'ACTIVO') {?>
                     <button class="btn btn-danger" title="Inactivar" onclick="inactivar(<?= $c['id_plan_servi'];?>);"><i class="fa fa-minus-circle"></i></button>
                     <button class="btn btn-warning text-white" title="Editar" onclick="editar(<?= $c['id_plan_servi'];?>);"><i class="fa fa-edit"></i></button>
                    <?php }else{ ?>
                    <button class="btn btn-success" title="Activar" onclick="activar(<?= $c['id_plan_servi'];?>);"> <i class="fa fa-check-circle"></i></button>
                      
                    <?php } ?>
                </td>
            </tr>
        <?php } }else{ ?>

        <?php } ?>
    </tbody>
</table>
