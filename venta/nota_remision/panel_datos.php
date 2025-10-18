<?php
$id_not = $_POST['id_not'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();

//$ventas = pg_fetch_all(pg_query($conn, "SELECT * FROM v_ventas_cab WHERE estado = 'CONFIRMADO';"));
$ventas = pg_fetch_all(pg_query($conn, "SELECT * FROM v_ventas_cab WHERE estado = 'CONFIRMADO' AND id_tm = 4 ORDER BY vc_nro_factura ASC;"));
$vehiculo = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vehiculos WHERE estado = 'ACTIVO';"));
$timbrados = pg_fetch_all(pg_query($conn, "SELECT * FROM v_timbrados WHERE estado = 'ACTIVO' and id_tim = 8;"));

$funcionario = pg_fetch_all(pg_query($conn, "SELECT * FROM v_funcionarios_dni WHERE id_cargo = 5 AND estado = 'ACTIVO';"));

if ($id_not == '-1') { //CUANDO SE RESETEA
?>
    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> Seleccione un pedido</label>
<?php
} else if ($id_not == '0') { //CUANDO SE PRESIONA EL BOTON AGREGAR
?>
    <div class="card card-primary">
        <div class="card-header text-center elevation-3">
            Datos de la Nota
        </div>
        <div class="card-body">
            <input type="hidden" value="0" id="id_not">
            <input type="text" value="<?= $timbrados[0]['id_tim']; ?>" id="id_tim" hidden>
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label>Sucursal</label>
                        <input type="text" value="<?= $_SESSION['suc_nombre']; ?>" class="form-control" disabled>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group">
                        <label>Nro de Remisión</label>
                        <input type="text" value="<?= $timbrados[0]['numero_factura']; ?>" class="form-control" id="not_nro_documento" disabled>
                    </div>
                </div>
                <div class="form-group col-md-6">
                    <label>Fecha de Emision</label>
                    <input type="datetime" value="<?= date('Y-m-d H:i:s'); ?>" class="form-control" id="not_fecha_emis" disabled>
                </div>
                <div class="form-group col-md-6">
                    <label>Fecha de Salida</label>
                    <input type="date" min="<?= date('Y-m-d'); ?>" value="<?= date('Y-m-d'); ?>" class="form-control" id="not_fecha_elab">
                </div>

                <div class="form-group col-md-6">
                    <label>Tipo de Nota</label>
                    <select class="select2" id="not_tipo_nota" disabled>
                        <option selected="true" value="REMISION">REMISION</option>
                    </select>
                </div>

                <div class="form-group col-md-6">
                    <label>Nro. Factura</label>
                    <select class="select2" id="id_vc" onchange="autollenar()">
                        <option selected="true" disabled="disabled">Seleccione Factura</option>
                        <?php foreach ($ventas as $a) { ?>
                            <option value="<?php echo $a['id_vc']; ?>"><?= $a['vc_nro_factura']; ?></option>
                        <?php } ?>
                    </select>
                </div>

                <div class="form-group col">
                    <label>Cliente</label>
                    <select class="select2" id="id_cliente" disabled>
                        <option value="" disabled="disabled">Seleccione...</option>
                    </select>
                </div>

                <div class="form-group col">
                    <label>Vehiculo</label>
                    <select class="select2" id="id_vehiculo">
                        <option value="" disabled="disabled">Seleccione...</option>
                        <?php foreach ($vehiculo as $v) { ?>
                            <option value="<?php echo $v['id_vehiculo']; ?>"><?= $v['vehiculo']; ?></option>
                        <?php } ?>
                    </select>
                </div>

                <div class="form-group col">
                    <label>Chofer</label>
                    <select class="select2" id="id_chofer">
                        <option value="" disabled="disabled">Seleccione...</option>
                        <?php foreach ($funcionario as $f) { ?>
                            <option value="<?php echo $f['id_funcionario']; ?>"><?= $f['funcionario_ci']; ?></option>
                        <?php } ?>
                    </select>
                </div>

                <div class="form-group col-md-12">
                    <label>Observacion</label>
                    <textarea class="form-control" id="not_observacion"></textarea>
                </div>
            </div>
            <div class="form-group">
                <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
    <script>
        const timbradoFiltro = <?= json_encode($timbrados); ?>;
        autollenar();
    </script>
<?php
} else { //O SE TRATA DE UN PEDIDO DEFINIDO O SE TRATA DEL ULTIMO PEDIDO
    if ($id_not == '-2') { //SE TRATA DEL ULTIMO PEDIDO
        $cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_nota_cab WHERE id_not = (select max(id_not) from vent_nota_cab where id_sucursal = $id_sucursal);"));
    } else { //SE TRATA DE UN PEDIDO DEFINIDO
        $cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_nota_cab WHERE id_not = $id_not;"));
    }
    $detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_nota_det WHERE id_not = " . $cabecera[0]['id_not'] . " ORDER BY id_item, item_descrip, mar_descrip ASC;"));
    $disabled = 'disabled';
    if ($cabecera[0]['estado'] == 'PENDIENTE') {
        $disabled = '';
    }
?>
    <div class="row">
        <div class="card card-primary col-12">
            <div class="card-header text-center elevation-3">
                Datos de la Nota
            </div>
            <div class="card-body">
                <input type="hidden" value="<?= $cabecera[0]['id_not']; ?>" id="id_not">
                <input type="hidden" value="0" id="eliminar_id_item">
                <input type="hidden" value="<?= $cabecera[0]['id_tim']; ?>" id="id_tim">
                <div class="row">

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Sucursal</label>
                            <input type="text" value="<?= $cabecera[0]['suc_nombre']; ?>" class="form-control" disabled>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Nro de Documento</label>
                            <input type="text" value="<?= $cabecera[0]['not_nro_documento']; ?>" class="form-control" id="not_nro_documento" disabled>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Fecha de Emision</label>
                            <input type="date" value="<?= $cabecera[0]['vc_fecha']; ?>" class="form-control" id="not_fecha_emis" disabled>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Fecha de Salida</label>
                            <input type="date" min="<?= date('Y-m-d'); ?>" value="<?= $cabecera[0]['f_sin_hora']; ?>" class="form-control" id="not_fecha_elab">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Tipo de Nota</label>
                            <select class="select2" id="not_tipo_nota" disabled>
                                <option value="<?= $cabecera[0]['not_tipo_nota']; ?>" selected="true"><?= $cabecera[0]['not_tipo_nota']; ?></option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group col-md-6">
                        <label>Nro. Factura</label>
                        <select class="select2" id="id_vc" disabled>
                            <option selected="true" value="<?= $cabecera[0]['id_vc']; ?>"><?= $cabecera[0]['vc_nro_factura']; ?></option>
                        </select>
                    </div>

                    <div class="form-group col">
                        <label>Cliente</label>
                        <select class="select2" id="id_cliente" disabled>
                            <option value="<?= $cabecera[0]['id_cliente']; ?>"><?= $cabecera[0]['cliente']; ?></option>
                        </select>
                    </div>

                    <div class="form-group col">
                        <label>Vehiculo</label>
                        <select class="select2" id="id_vehiculo" disabled>
                            <option value="<?= $cabecera[0]['id_vehiculo']; ?>"><?= $cabecera[0]['vehiculo']; ?></option>
                        </select>
                    </div>

                    <div class="form-group col">
                        <label>Chofer</label>
                        <select class="select2" id="id_chofer" disabled>
                                <option value="<?= $cabecera[0]['id_chofer']; ?>"><?= $cabecera[0]['chofer']; ?></option>                        
                        </select>
                    </div>

                    <div class="form-group col-md-12">
                        <label>Observacion</label>
                        <textarea class="form-control" id="not_observacion"><?= $cabecera[0]['not_observacion']; ?></textarea>
                    </div>
                </div>
                <div class="form-group">
                    <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                    <?php if ($cabecera[0]['estado'] == 'PENDIENTE') { ?>
                        <button class="btn btn-danger" onclick="anular();"><i class="fa fa-minus-circle"></i> Anular</button>
                        <button class="btn btn-warning text-white" onclick="modificar();"><i class="fa fa-edit"></i> Modificar</button>
                        <button class="btn btn-success" onclick="confirmar();"><i class="fa fa-check-circle"></i> Confirmar</button>
                    <?php } ?>
                </div>
            </div>
        </div>
        <div class="card card-primary col-9">
            <div class="card-header text-center elevation-3">
                Detalles de la Nota
            </div>
            <div class="card-body">
                <?php if (!empty($detalles)) { ?>
                    <table class="table table-bordered" style="font-size: 12px;">
                        <thead>
                            <tr>
                                <th>Detalle</th>
                                <th>Cant</th>
                                <th>P.Unit</th>
                                <th>SubTotal</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            $total = 0;
                            $precioTotal = 0;

                            $sumaIva = 0;
                            foreach ($detalles as $d) {
                                $total = $total + ($d['precio'] * $d['cantidad']);
                            ?>
                                <tr>
                                    <td><?= $d['mar_descrip'] . ": " . $d['item_descrip']; ?></td>
                                    <td><?= $d['cantidad']; ?></td>
                                    <td><?= number_format($d['precio'], 0, ",", ".") ?></td>
                                    <td><?= number_format($d['cantidad'] * $d['precio'], 0, ",", ".") ?></td>
                                    <td>
                                        <?php if ($cabecera[0]['estado'] == 'PENDIENTE') { ?>
                                            <button class="btn btn-warning text-white" onclick="modificar_detalle(<?= $d['id_not'] ?>, <?= $d['id_item'] ?>);" id="btn-panel-modificar-cerrar"><i class="fa fa-edit"></i></button>
                                            <button class="btn btn-danger" onclick="eliminar_detalle(<?php echo $d['id_item']; ?>);"><i class="fa fa-minus-circle"></i></button>
                                        <?php } ?>
                                    </td>
                                </tr>
                            <?php

                                $sumaIva += $d['totaliva5'] + $d['totaliva10'];
                            }
                            ?>
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="3">Total Iva</th>
                                <th colspan="2"><?php echo number_format($sumaIva, 0, ",", "."); ?></th>
                                <!-- <th></th> -->
                            </tr>
                            <tr>
                                <th colspan="3">Total</th>
                                <th colspan="2"><?php echo number_format($total, 0, ",", "."); ?></th>
                                <!-- <th></th> -->
                            </tr>
                        </tfoot>
                    </table>
                <?php } else { ?>
                    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron detalles...</label>
                <?php } ?>
            </div>
        </div>
        <?php if ($cabecera[0]['estado'] == 'PENDIENTE') {
            $articulos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_items_conceptos WHERE estado = 'ACTIVO' AND id_item NOT IN (select id_item from vent_nota_det WHERE id_not = " . $cabecera[0]['id_not'] . ") AND id_tip_item NOT IN (7) ORDER BY item_descrip;"))
        ?>
            <div class="card card-primary col-3">
                <div class="card-header text-center elevation-3">
                    Agregar Concepto
                </div>
                <div class="card-body">
                    <?php if (!empty($articulos)) { ?>
                        <div class="form-group">
                            <label>Conceptos</label>
                            <select class="select2" id="agregar_id_item">
                                <?php foreach ($articulos as $a) { ?>
                                    <option value="<?php echo $a['id_item']; ?>"><?= $a['item_descrip']; ?></option>
                                <?php } ?>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Cantidad</label>
                            <input type="number" value="0" class="form-control" id="agregar_cantidad">
                        </div>

                        <div class="form-group" hidden>
                            <label>Monto</label>
                            <input type="number" value="0" class="form-control" id="agregar_monto">
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
} ?>
<script>
    const datosVentas = <?= json_encode($ventas); ?>;
</script>
<?php pg_close($conn); ?>