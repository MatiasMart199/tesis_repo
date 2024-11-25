<?php
$id_tra = $_POST['id_tra'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();

$sucursal = pg_fetch_all(pg_query($conn, "SELECT suc_nombre FROM sucursales WHERE id_sucursal=$id_sucursal;"));
$deposito = pg_fetch_all(pg_query($conn, "SELECT * FROM v_deposito WHERE estado = 'ACTIVO';"));
$funcionario = pg_fetch_all(pg_query($conn, "SELECT id_funcionario, funcionario FROM v_funcionarios WHERE estado = 'ACTIVO';"));
$vehiculo = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vehiculos WHERE estado = 'ACTIVO';"));
if ($id_tra == '-1') { //CUANDO SE RESETEA
?>
    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> Seleccione un Transferencia</label>
<?php
} else if ($id_tra == '0') { //CUANDO SE PRESIONA EL BOTÓN AGREGAR
?>
    <div class="card card-primary">
        <div class="card-header text-center elevation-3">
            Datos de la Transferencia
        </div>
        <div class="card-body">
            <input type="hidden" value="<?= $id_tra; ?>" id="id_tra">

            <div class="col-md-2">
                <div class="form-group">
                    <label>Sucursal</label>
                    <input type="text" value="<?= $sucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                </div>
            </div>

            <div class="row">
                <div class="col-md-4">
                    <div class="form-group">
                        <label>Fecha de Elaboración</label>
                        <input type="date" value="<?= date('Y-m-d'); ?>" class="form-control" id="tra_fecha_elabo" disabled>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group">
                        <label>Fecha de Salida</label>
                        <input type="date" value="2000-02-02" class="form-control" id="tra_fecha_salida" disabled>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group">
                        <label>Fecha de Recepción</label>
                        <input type="date" value="2000-02-02" class="form-control" id="tra_fecha_recep" disabled>
                    </div>
                </div>
            </div>

            <!-- DEPOSITOS -->
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label>Deposito Origen</label>
                        <select class="select2" id="id_deposito_ori" onchange="autoSucursal1()" name="deposito_ori">
                            <option selected="true" disabled="disabled">Seleccione Deposito</option>
                            <?php foreach ($deposito as $a) { ?>
                                <option value="<?php echo $a['id_sucursal']; ?>"><?= $a['dep_descrip']; ?></option>
                            <?php } ?>
                        </select>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group">
                        <label>Deposito Destino</label>
                        <select class="select2" id="id_deposito_des" onchange="autoSucursal2()" name="deposito_des">
                            <option selected="true" disabled="disabled">Seleccione Deposito</option>
                            <?php foreach ($deposito as $a) { ?>
                                <option value="<?php echo $a['id_sucursal']; ?>"><?= $a['dep_descrip']; ?></option>
                            <?php } ?>
                        </select>
                    </div>
                </div>
            </div>

            <!-- SUCURSALES -->
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label>Sucursal Origen</label>
                        <select class="select2" id="id_sucursal_ori" name="sucursal_ori" disabled>
                            <option></option>
                        </select>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group">
                        <label>Sucursal Destino</label>
                        <select class="select2" id="id_sucursal_des" name="sucursal_des" disabled>
                            <option></option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- SUCURSALES -->
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label>Vehiculo</label>
                        <select class="select2" id="id_vehiculo">
                            <?php foreach ($vehiculo as $v) { ?>
                                <option value="<?= $v['id_vehiculo']; ?>"><?= $v['veh_descrip'] . " - " . $v['mar_descrip']; ?></option>
                            <?php } ?>
                        </select>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group">
                        <label>Chofer</label>
                        <select class="select2" id="id_chofer">
                            <?php foreach ($funcionario as $f) { ?>
                                <option value="<?= $f['id_funcionario']; ?>"><?= $f['funcionario']; ?></option>
                            <?php } ?>
                        </select>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label>Observacion</label>
                <textarea class="form-control" id="observacion" placeholder="Observaciones"></textarea>
            </div>

            <div class="form-group">
                <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
<?php
} else { //O SE TRATA DE UN PEDIDO DEFINIDO O SE TRATA DEL ULTIMO PEDIDO
    if ($id_tra == '-2') { //SE TRATA DEL ULTIMO PEDIDO
        $cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_comp_transfers_cab_f WHERE id_tra = (select max(id_tra) from comp_transfers_cab where id_sucursal = $id_sucursal);"));
    } else { //SE TRATA DE UN PEDIDO DEFINIDO
        $cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_comp_transfers_cab_f WHERE id_tra = $id_tra;"));
    }
    $detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_comp_transfers_det WHERE id_tra = " . $cabecera[0]['id_tra'] . " ORDER BY item_descrip, mar_descrip;"));
    $disabled = 'disabled';
    if ($cabecera[0]['estado'] == 'PENDIENTE' || $cabecera[0]['estado'] == 'ENVIADO') {
        $disabled = '';
    }
?>
    <div class="row">
        <div class="card card-primary col-12">
            <div class="card-header text-center elevation-3">
                Datos de la Transferencia
            </div>
            <div class="card-body">
                <input type="hidden" value="<?= $cabecera[0]['id_tra']; ?>" id="id_tra">
                <input type="hidden" value="0" id="eliminar_id_item">

                <div class="col-md-2">
                    <div class="form-group">
                        <label>Sucursal</label>
                        <input type="text" value="<?= $sucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-4">
                        <div class="form-group">
                            <label>Fecha de Elaboración</label>
                            <input type="date" value="<?= $cabecera[0]['tra_fecha_elabo']; ?>" class="form-control" id="tra_fecha_elabo" disabled>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="form-group">
                            <label>Fecha de Salida</label>
                            <input type="date" value="<?= date('Y-m-d'); ?>" class="form-control" id="tra_fecha_salida" disabled>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="form-group">
                            <label>Fecha de Recepción</label>
                            <input type="date" value="<?= date('Y-m-d'); ?>" class="form-control" id="tra_fecha_recep" disabled>
                        </div>
                    </div>
                </div>

                <!-- DEPOSITOS -->
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Deposito Origen</label>
                            <select class="select2" id="id_deposito_ori" disabled>
                                <option selected="true" value="<?= $cabecera[0]['id_deposito_ori']; ?>"><?= $cabecera[0]['deposito_origen']; ?></option>
                            </select>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Deposito Destino</label>
                            <select class="select2" id="id_deposito_des" disabled>
                                <option selected="true" value="<?= $cabecera[0]['id_deposito_des']; ?>"><?= $cabecera[0]['deposito_destino']; ?></option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- SUCURSALES -->
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Sucursal Origen</label>
                            <select class="select2" id="id_sucursal_ori" disabled>
                                <option selected="true" value="<?= $cabecera[0]['id_sucursal_ori']; ?>"><?= $cabecera[0]['sucursal_origen']; ?></option>
                            </select>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Sucursal Destino</label>
                            <select class="select2" id="id_sucursal_des" disabled>
                                <option selected="true" value="<?= $cabecera[0]['id_sucursal_des']; ?>"><?= $cabecera[0]['sucursal_destino']; ?></option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- SUCURSALES -->
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Vehiculo</label>
                            <select class="select2" id="id_vehiculo">
                                <option selected="true" value="<?= $cabecera[0]['id_vehiculo']; ?>"><?= $cabecera[0]['veh_descrip'] . " - " . $cabecera[0]['mar_descrip']; ?></option>
                                <?php foreach ($vehiculo as $v) { ?>
                                    <option value="<?= $v['id_vehiculo']; ?>"><?= $v['veh_descrip'] . " - " . $v['mar_descrip']; ?></option>
                                <?php } ?>
                            </select>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Chofer</label>
                            <select class="select2" id="id_chofer">
                                <option selected="true" value="<?= $cabecera[0]['id_chofer']; ?>"><?= $cabecera[0]['chofer']; ?></option>
                                <?php foreach ($funcionario as $f) { ?>
                                    <option value="<?= $f['id_funcionario']; ?>"><?= $f['funcionario']; ?></option>
                                <?php } ?>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <label>Observacion</label>
                    <textarea class="form-control" id="observacion" placeholder="Observaciones"><?= $cabecera[0]['observacion']; ?></textarea>
                </div>

                <div class="form-group">
                    <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                    <?php if ($cabecera[0]['estado'] == 'PENDIENTE' || $cabecera[0]['estado'] == 'ENVIADO') { ?>
                        <button class="btn btn-danger" onclick="anular();"><i class="fa fa-minus-circle"></i> Anular</button>
                        <button class="btn btn-warning text-white" onclick="modificar();"><i class="fa fa-edit"></i> Modificar</button>
                        <button class="btn btn-warning text-white" onclick="enviar();"><i class="fa fa-truck"></i> Enviar</button>
                        <button class="btn btn-success" onclick="confirmar();"><i class="fa fa-check-circle"></i> Confirmar</button>
                    <?php } ?>
                </div>

            </div>
        </div>
        <div class="card card-primary col-8">
            <div class="card-header text-center elevation-3">
                Detalles de la Transferencia
            </div>
            <div class="card-body">
                <?php if (!empty($detalles)) { ?>
                    <table class="table table-bordered" style="font-size: 12px;">
                        <thead>
                            <tr>
                                <th>Producto</th>
                                <th>Cantidad</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php $total = 0;
                            foreach ($detalles as $d) {
                                //$total = $total + ($d['precio'] * $d['cantidad']) 
                            ?>
                                <tr>
                                    <td><?= $d['item_descrip'] . " - " . $d['mar_descrip']; ?></td>
                                    <td><?= $d['cantidad'] ?></td>
                                    <td>
                                        <?php if ($cabecera[0]['estado'] == 'PENDIENTE') { ?>
                                            <button class="btn btn-warning text-white" onclick="modificar_detalle(<?= $d['id_item']; ?>);" id="btn-panel-modificar-cerrar"><i class="fa fa-edit"></i></button>
                                            <button class="btn btn-danger" onclick="eliminar_detalle(<?= $d['id_item']; ?>);"><i class="fa fa-minus-circle"></i></button>
                                        <?php } ?>
                                    </td>
                                </tr>
                            <?php } ?>
                        </tbody>
                        <tfoot>
                            <!-- <tr>
                                <th colspan="3">Total</th>
                                <th><? //= number_format($total, 0, ",", "."); 
                                    ?></th>
                                <th></th>
                            </tr> -->
                        </tfoot>
                    </table>
                <?php } else { ?>
                    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron detalles...</label>
                <?php } ?>
            </div>
        </div>
        <?php if ($cabecera[0]['estado'] == 'PENDIENTE' || $cabecera[0]['estado'] == 'ENVIADO') {
            $articulos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_stocks WHERE estado = 'ACTIVO' AND id_item NOT IN (select id_item from comp_transfers_det WHERE id_tra = " . $cabecera[0]['id_tra'] . ") ORDER BY item_descrip;"))
        ?>
            <div class="card card-primary col-4">
                <div class="card-header text-center elevation-3">
                    Agregar Producto
                </div>
                <div class="card-body">
                    <?php if (!empty($articulos)) { ?>
                        <div class="form-group">
                            <label>Producto</label>
                            <select class="select2" id="agregar_id_item" onchange="llenarStock();">
                                <option selected="true" disabled="disabled">Seleccione...</option>
                                <?php foreach ($articulos as $a) { ?>
                                    <option value="<?= $a['id_item']; ?>"><?= $a['dep_descrip'] . ": " . $a['item_descrip'] . " - " . $a['mar_descrip']; ?></option>
                                <?php } ?>
                            </select>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Stock</label>
                                    <input type="number" class="form-control" id="idStock" disabled>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Cantidad</label>
                                    <input type="number" value="" class="form-control" id="agregar_cantidad" placeholder="Ej: 1">
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <button class="btn btn-success" onclick="agregar_detalles();"><i class="fa fa-plus-circle"></i> Agregar</button>
                        </div>
                    <?php } else { ?>
                        <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se encuentran productos disponibles...</label>
                    <?php } ?>
                </div>
            </div>

        <?php } ?>
    </div>

<?php
}
pg_close($conn);
?>
<script>
    const datoDeposito = <?= json_encode($deposito); ?>;
    const datoStock = <?= json_encode($articulos); ?>;
</script>