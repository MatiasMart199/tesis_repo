<?php 
require "../../Conexion.php";
$conexion = new Conexion();
$conn = $conexion->getConexion();
$ciudades = pg_fetch_all(pg_query ($conn, "SELECT * FROM v_personas"));
?>

<table class="table table-bordered" id="tabla_datos">
    <thead>
        <tr>
            <th>#</th>
            <th>Personas</th>
            <th>RUC</th>
            <th>C.I</th>
            <th>Direccion</th>
            <th>Correo</th>
            <th>Fec. Nac</th>
            <th>Telefono</th>
            <th>Ciudad</th>
            <th>Edo. Civil</th>
            <th>Genero</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <?php if(!empty($ciudades)){ foreach($ciudades as $c){ ?>
            <tr>
                <td><?= $c['id_persona']; ?></td>
                <td><?= $c['persona']; ?></td>
                <td><?= $c['per_ruc']; ?></td>
                <td><?= $c['per_ci']; ?></td>
                <td><?= $c['per_direccion']; ?></td>
                <td><?= $c['per_correo']; ?></td>
                <td><?= $c['fecha_nacimiento']; ?></td>
                <td><?= $c['per_telefono']; ?></td>
                <td><?= $c['ciu_descrip']; ?></td>
                <td><?= $c['ec_descrip']; ?></td>
                <td><?= $c['gen_descrip']; ?></td>
                <td><?= $c['estado']; ?></td>
                <td>
                    <?php if($c['estado'] == 'ACTIVO') {?>
                    <button class="btn btn-danger" title="Inactivar" onclick="inactivar(<?= $c['id_persona'];?>);"><i class="fa fa-minus-circle"></i></button>
                    <button class="btn btn-warning text-white" title="Editar" onclick="editar(<?= $c['id_persona'];?>);"><i class="fa fa-edit"></i></button>
                    <?php }else{ ?>
                    <button class="btn btn-success" title="Activar" onclick="activar(<?= $c['id_persona'];?>);"> <i class="fa fa-check-circle"></i></button>
                
                    <?php } ?>
                </td>
            </tr>
        <?php } }else{ ?>

        <?php } ?>
    </tbody>
</table>
