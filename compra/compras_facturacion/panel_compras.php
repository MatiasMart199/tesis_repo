<?php
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_sucursal = $_SESSION['id_sucursal'];
//$usu_login= $_SESSION['usu_login'];
$query= pg_query($conn, "SELECT * FROM v_compras_cab WHERE id_sucursal = $id_sucursal ORDER BY id_cc;");
$compras = pg_fetch_all($query);
//$funcionarios= pg_fetch_all(pg_query($conn,"select funcionario from v_funcionarios where usu_login =$usu_login;"));
?>
<button class="btn btn-success" onclick="agregar();"><i class="fa fa-plus-circle"></i> Agregar</button>
<table width="100%" class="table table-bordered" id="tabla_panel_compras">
    <thead>
        <tr>
            <th>#</th>
            <!-- <th>Funcionario</th>
            <th>Empresa</th> -->
            <th>Sucursal</th>
            <th>Fecha</th>
            <th>Intervalo</th>
            <th>Proveedor</th>
            <th>Cuota</th>
            <th>Tip. Factura</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <?php if(!empty($compras)){ foreach($compras as $p){ ?>
        <tr>
            <td><?php echo $p['id_cc'];?></td>
            <!-- <td><?php //echo $p['funcionario'];?></td>
            <td><?php //echo $p['emp_denominacion'];?></td> -->
            <td><?php echo $p['suc_nombre'];?></td>
            <td><?php echo $p['fecha'];?></td>
            <td><?php echo $p['cc_intervalo'];?></td>
            <td><?php echo $p['proveedor'];?></td>
            <td><?php echo $p['cc_cuota'];?></td>
            <td><?php echo $p['cc_tipo_factura'];?></td>
            <td><?php echo $p['estado'];?></td>
            <td>
                <button class="btn btn-primary" onclick="datos(<?php echo $p['id_cc']; ?>);"><i class="fa fa-list-alt"></i></button>
                <?php if($p['estado'] == 'PENDIENTE'){ ?>
                <button class="btn btn-success" onclick="datos(<?php echo $p['id_cc']; ?>);"><i class="fa fa-check-circle"></i></button>
                <button class="btn btn-warning text-white" onclick="datos(<?php echo $p['id_cc']; ?>);"><i class="fa fa-edit"></i></button>
                <button class="btn btn-danger" onclick="datos(<?php echo $p['id_cc']; ?>);"><i class="fa fa-minus-circle"></i></button>
                <?php } ?>
            </td>
        </tr>
        <?php } } pg_close($conn)?>
    </tbody>
</table>