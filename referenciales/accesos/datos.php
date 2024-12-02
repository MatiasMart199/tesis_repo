<?php 
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/Conexion.php";
$conexion = new Conexion();
$conn = $conexion->getConexion();
$datos = pg_query($conn, "SELECT * FROM v_accesos");
$paises = pg_fetch_all($datos);

?>


<table class="table table-bordered" id="tabla_datos">
    <thead>
        <tr>
            <th>#</th>
            <th>usuario</th>
            <th>Contraseña</th>
            <th>Funcionario</th>
            <th>CI</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <?php if(!empty($paises)){ foreach($paises as $p){ ?>
            <tr>
                <td><?= $p['id_acceso']; ?></td>
                <td><?= $p['usu_login']; ?></td>
                <td><?= str_repeat('*', strlen($p['usu_contrasena'])); ?></td>
                <td><?= $p['funcionario']; ?></td>
                <td><?= $p['per_ci']; ?></td>
                <td><?= $p['estado']; ?></td>
                <td>
                    <?php if($p['estado'] == 'ACTIVO') {?>
                    <button class="btn btn-danger" title="Inactivar" onclick="inactivar(<?= $p['id_acceso'];?>);"><i class="fa fa-minus-circle"></i></button>
                    <button class="btn btn-warning text-white" title="Editar" onclick="editar(<?= $p['id_acceso'];?>);"><i class="fa fa-edit"></i></button>
                    
                    <?php }else{ ?>
                    <button class="btn btn-success" title="Activar" onclick="activar(<?= $p['id_acceso'];?>);"> <i class="fa fa-check-circle"></i></button>
                        
                    <?php } ?>
                </td>
            </tr>
        <?php } }else{ ?>

        <?php } ?>
    </tbody>
</table>
