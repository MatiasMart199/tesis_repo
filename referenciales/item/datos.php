<?php 
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/Conexion.php";
$conexion = new Conexion();
$conn = $conexion->getConexion();
$datos = pg_query($conn, "SELECT * FROM v_items ORDER BY id_item ASC");
$paises = pg_fetch_all($datos);

?>


<table class="table table-bordered" id="tabla_datos" style="font-size: 14px;">
    <thead>
        <tr>
            <th>#</th>
            <th>Descripción</th>
            <th>P. Compra</th>
            <th>P. Venta</th>
            <th>Stock</th>
            <th>Marca</th>
            <th>Categoría</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <?php if(!empty($paises)){ foreach($paises as $p){ ?>
            <tr>
                <td><?= $p['id_item']; ?></td>
                <td><?= $p['item_descrip']; ?></td>
                <td><?= $p['precio_compra']; ?></td>
                <td><?= $p['precio_venta']; ?></td>
                <td><?= $p['stock_cantidad']; ?></td>
                <td><?= $p['mar_descrip']; ?></td>
                <td><?= $p['tip_item_descrip']; ?></td>
                <td><?= $p['estado']; ?></td>
                <td>
                    <?php if($p['estado'] == 'ACTIVO') {?>
                    <button class="btn btn-danger" title="Inactivar" onclick="inactivar(<?= $p['id_item'];?>);"><i class="fa fa-minus-circle"></i></button>
                    <button class="btn btn-warning text-white" title="Editar" onclick="editar(<?= $p['id_item'];?>);"><i class="fa fa-edit"></i></button>
                    
                    <?php }else{ ?>
                    <button class="btn btn-success" title="Activar" onclick="activar(<?= $p['id_item'];?>);"> <i class="fa fa-check-circle"></i></button>
                        
                    <?php } ?>
                </td>
            </tr>
        <?php } }else{ ?>

        <?php } ?>
    </tbody>
</table>
