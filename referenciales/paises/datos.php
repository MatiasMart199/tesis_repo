<?php 
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/Conexion.php";
$conexion = new Conexion();
$conn = $conexion->getConexion();
$datos = pg_query($conn, "SELECT * FROM paises");
$paises = pg_fetch_all($datos);

?>


<table class="table table-bordered" id="tabla_datos">
    <thead>
        <tr>
            <th>#</th>
            <th>Descripción</th>
            <th>Gentilicio</th>
            <th>Codigo</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <?php if(!empty($paises)){ foreach($paises as $p){ ?>
            <tr>
                <td><?= $p['id_pais']; ?></td>
                <td><?= $p['pais_descrip']; ?></td>
                <td><?= $p['pais_gentilicio']; ?></td>
                <td><?= $p['pais_codigo']; ?></td>
                <td><?= $p['estado']; ?></td>
                <td>
                    <?php if($p['estado'] == 'ACTIVO') {?>
                    <button class="btn btn-danger" title="Inactivar" onclick="inactivar(<?= $p['id_pais'];?>);"><i class="fa fa-minus-circle"></i></button>
                    <button class="btn btn-warning text-white" title="Editar" onclick="editar(<?= $p['id_pais'];?>);"><i class="fa fa-edit"></i></button>
                    
                    <?php }else{ ?>
                    <button class="btn btn-success" title="Activar" onclick="activar(<?= $p['id_pais'];?>);"> <i class="fa fa-check-circle"></i></button>
                        
                    <?php } ?>
                </td>
            </tr>
        <?php } }else{ ?>

        <?php } ?>
    </tbody>
</table>
