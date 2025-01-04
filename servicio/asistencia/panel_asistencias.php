<?php
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_sucursal = $_SESSION['id_sucursal'];
//$usu_login= $_SESSION['usu_login'];
$query = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_asistencias_cab WHERE id_sucursal = $id_sucursal ORDER BY id_asi desc;"));
//$funcionarios= pg_fetch_all(pg_query($conn,"select funcionario from v_funcionarios where usu_login =$usu_login;"));
?>
<!-- <button class="btn btn-success" onclick="agregar();"><i class="fa fa-plus-circle"></i> Agregar</button> -->
<table width="100%" class="table table-bordered mt-3" id="tabla_panel_asistencias">
    <!-- <input type="text" id="id_asi" hidden value=""> -->
    <thead>
        <tr>
            <th>#</th>
            <th>Sucursal</th>
            <th>Entrada</th>
            <th>Salida</th>
            <th>Cliente</th>
            <th>DNI</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <?php if(!empty($query)){ foreach($query as $p){ 
            if($p['estado'] != 'ANULADO'){?>
        <tr>
            <td><?= $p['id_asi'];?></td>
            <td><?= $p['suc_nombre'];?></td>
            <td><?= $p['entrada'];?></td>
            <td><?= $p['salida'];?></td>
            <td><?= $p['cliente'];?></td>
            <td><?= $p['per_ci'];?></td>
            <td><?= $p['estado'];?></td>
            <td>
                <!-- <button class="btn btn-warning text-white" onclick="modificar(<?php //echo $p['id_asi']; ?>);"><i class="fa fa-edit"></i></button> -->
                <button class="btn btn-danger" onclick="anular(<?= $p['id_asi'] ?>)"><i class="fa fa-minus-circle"></i></button>
               
            </td>
        </tr>
        <?php } } } pg_close($conn)?>
    </tbody>
</table>