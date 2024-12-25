<?php
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_sucursal = $_SESSION['id_sucursal'];
//$usu_login= $_SESSION['usu_login'];
$ordenes = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_ordenes WHERE id_sucursal = $id_sucursal ORDER BY id_corden;"));

//Muestra datosen formato JSON
// $json=json_encode($ordenes);
// echo "<script>console.log($json);</script>";
//$funcionarios= pg_fetch_all(pg_query($conn,"select funcionario from v_funcionarios where usu_login =$usu_login;"));
?>
<button class="btn btn-success" onclick="agregar();"><i class="fa fa-plus-circle"></i> Agregar</button>
<table width="100%" class="table table-bordered" id="tabla_panel_ordenes">
    <thead>
        <tr>
            <th>#</th>
            <!-- <th>Funcionario</th>
            <th>Empresa</th> -->
            <th>Sucursal</th>
            <th>Fecha</th>
            <th>Proveedor</th>
            <th>Intervalo</th>
            <th>Cuota</th>
            <th>Tip. Factura</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <?php if(!empty($ordenes)){ foreach($ordenes as $p){ ?>
        <tr>
            <td><?php echo $p['id_corden'];?></td>
            <!-- <td><?php //echo $p['funcionario'];?></td>
            <td><?php //echo $p['emp_denominacion'];?></td> -->
            <td><?php echo $p['suc_nombre'];?></td>
            <td><?php echo $p['fecha'];?></td>
            <td><?php echo $p['proveedor'];?></td>
            <td><?php echo $p['ord_intervalo'];?></td>
            <td><?php echo $p['ord_cuota'];?></td>
            <td><?php echo $p['ord_tipo_factura'];?></td>
            <td><?php echo $p['estado'];?></td>
            <td>
                <button class="btn btn-primary" onclick="datos(<?php echo $p['id_corden']; ?>);"><i class="fa fa-list-alt"></i></button>
                <?php if($p['estado'] == 'PENDIENTE'){ ?>
                <button class="btn btn-success" onclick="datos(<?php echo $p['id_corden']; ?>);"><i class="fa fa-check-circle"></i></button>
                <button class="btn btn-warning text-white" onclick="datos(<?php echo $p['id_corden']; ?>);"><i class="fa fa-edit"></i></button>
                <button class="btn btn-danger" onclick="datos(<?php echo $p['id_corden']; ?>);"><i class="fa fa-minus-circle"></i></button>
                <?php } ?>
            </td>
        </tr>
        <?php } pg_close($conn);} ?>
    </tbody>
</table>