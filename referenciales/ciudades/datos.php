<?php 
require "../../Conexion.php";
$conexion = new Conexion();
$conn = $conexion->getConexion();
$ciudades = pg_fetch_all(pg_query ($conn, "SELECT * FROM v_ciudades"));
?>

<table class="table table-bordered" id="tabla_datos">
    <thead>
        <tr>
            <th>#</th>
            <th>Descripción</th>
            <th>Pais</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <?php if(!empty($ciudades)){ foreach($ciudades as $c){ ?>
            <tr>
                <td><?= $c['id_ciudad']; ?></td>
                <td><?= $c['ciu_descrip']; ?></td>
                <td><?= $c['pais_descrip']; ?></td>
                <td><?= $c['estado']; ?></td>
                <td>
                    <?php if($c['estado'] == 'ACTIVO') {?>
                     <button class="btn btn-danger" title="Inactivar" onclick="inactivar(<?= $c['id_ciudad'];?>);"><i class="fa fa-minus-circle"></i></button>
                     <button class="btn btn-warning text-white" title="Editar" onclick="editar(<?= $c['id_ciudad'];?>);"><i class="fa fa-edit"></i></button>
                    <?php }else{ ?>
                    <button class="btn btn-success" title="Activar" onclick="activar(<?= $c['id_ciudad'];?>);"> <i class="fa fa-check-circle"></i></button>
                      
                    <?php } ?>
                </td>
            </tr>
        <?php } }else{ ?>

        <?php } ?>
    </tbody>
</table>
