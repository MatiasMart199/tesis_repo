<?php
$id_cob = $_POST['id_cob'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();
$apertura = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_aperturas_cierres WHERE id_funcionario = " . $_SESSION['id_funcionario'] . " AND estado = 'ABIERTO';"));
$ventas = pg_fetch_all(pg_query($conn, "SELECT * FROM v_ventas_cab WHERE estado = 'CONFIRMADO' ORDER BY vc_nro_factura ASC;"));


if ($id_cob == '-1') { //CUANDO SE RESETEA
?>
    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> Seleccione un pedido</label>
<?php
} else if ($id_cob == '0') { //CUANDO SE PRESIONA EL BOTON AGREGAR
?>
    <div class="card card-primary">
        <div class="card-header text-center elevation-3">
            Datos del Cobro
        </div>
        <div class="card-body">
            <input type="hidden" value="0" id="id_cob">
            <div class="row">
                <div class="col-md-4">
                    <div class="form-group">
                        <label>Fecha</label>
                        <input type="datetime" value="<?= date('Y-m-d H:i:s'); ?>" class="form-control" id="cob_fecha" disabled>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group">
                        <label>Apertura y Cierre</label>
                        <select class="form-control" id="id_vac" disabled>
                            <?php foreach ($apertura as $e) { ?>
                                <option
                                    data-id_funcionario="<?= $e['id_funcionario'] ?>"
                                    data-funcionario="<?= $e['funcionario'] ?>"
                                    data-id_caja="<?= $e['id_caja'] ?>"
                                    data-caj_descrip="<?= $e['caj_descrip'] ?>"
                                    value="<?= $e['id_vac'] ?>">
                                    <?= $e['id_vac'] ?>
                                </option>
                            <?php } ?>
                        </select>
                    </div>
                </div>


                <div class="col-md-4">
                    <div class="form-group">
                        <label>Caja</label>
                        <select class="form-control" id="id_caja" disabled>
                            <option value=""></option>
                        </select>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group">
                        <label>Cajero</label>
                        <select class="select2" id="id_funcionario" disabled>
                            <option value="<?= $_SESSION['id_funcionario'] ?>"></option>
                        </select>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group">
                        <label>Nro Factura</label>
                        <select class="select2" id="id_vc">
                            <option value="" selected>Seleccione...</option>
                            <?php foreach ($ventas as $e) { ?>
                                <option value="<?= $e['id_vc'] ?>"><?= $e['vc_nro_factura'] ?></option>
                            <?php } ?>
                        </select>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
    <script>
        let apertura = <?= json_encode($apertura) ?>
    </script>
<?php
} else { //O SE TRATA DE UN PEDIDO DEFINIDO O SE TRATA DEL ULTIMO PEDIDO
    if ($id_cob == '-2') { //SE TRATA DEL ULTIMO PEDIDO
        $cabeceras = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_cobros_cab WHERE id_cob = (select max(id_cob) from vent_cobros_cab where id_sucursal = $id_sucursal);"));
    } else { //SE TRATA DE UN PEDIDO DEFINIDO
        $cabeceras = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_cobros_cab WHERE id_cob = $id_cob;"));
    }
    $cabeceras_monto = pg_fetch_all(pg_query($conn, "SELECT total_efectivo,total_cheque,total_tarjeta,total_transfe,total_general FROM v_vent_cobros_montos WHERE id_cob = ".$cabeceras[0]['id_cob'].";"));

    $detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_cobros_det WHERE id_cob = " . $cabeceras[0]['id_cob'] . " ORDER BY fc_descrip;"));
    //$cuenta_cobrar = pg_fetch_all(pg_query($conn, "SELECT * FROM vent_cuentas_cobrar WHERE id_vc =" . $cabeceras[0]['id_vc'] . "AND id_cue NOT IN (SELECT id_cue FROM v_vent_cobros_det WHERE id_cob =" . $cabeceras[0]['id_cob'] . " );"));
    // $cuenta_cobrar = [];
    // $result = pg_query($conn, "SELECT * FROM vent_cuentas_cobrar WHERE id_vc = {$cabeceras[0]['id_vc']} AND id_cue NOT IN (SELECT id_cue FROM v_vent_cobros_det WHERE id_cob = {$cabeceras[0]['id_cob']});");

    // if ($result) {
    //     $cuenta_cobrar = pg_fetch_all($result) ?: []; // Si no hay resultados, devuelve array vacío
    // }

    function ocultar_tarjeta($tarjeta)
    {
        $numero = $tarjeta;
        $enmascarado = substr($numero, -4) . '**** **** ****';
        return $enmascarado;
    }

    $cobros_tarjetas = pg_fetch_all(pg_query($conn, "SELECT * FROM v_cobros_tarjetas WHERE estado = 'ACTIVO' AND id_cob = " . $cabeceras[0]['id_cob'] . " ORDER BY id_ctar ASC;"));
    $cobros_cheques = pg_fetch_all(pg_query($conn, "SELECT * FROM v_cobros_cheques WHERE estado = 'ACTIVO' AND id_cob = " . $cabeceras[0]['id_cob'] . " ORDER BY id_che ASC;"));
    $cobros_transferencia = pg_fetch_all(pg_query($conn, "SELECT * FROM v_cobros_transferencia WHERE estado = 'ACTIVO' AND id_cob = " . $cabeceras[0]['id_cob'] . " ORDER BY id_ctra ASC;"));
    $disabled = 'disabled';
    if ($cabeceras[0]['estado'] == 'PENDIENTE') {
        $disabled = '';
    }
?>

    <div class="row">
        <div class="card card-primary col-12">
            <div class="card-header text-center elevation-3">
                Datos del Cobro
            </div>
            <div class="card-body">
                <input type="hidden" value="<?php echo $cabeceras[0]['id_cob']; ?>" id="id_cob">
                <input type="hidden" value="0" id="eliminar_id_cue">

                <div class="row">
                    <div class="col-md-4">
                        <div class="form-group">
                            <label>Fecha</label>
                            <input type="datetime" value="<?= $cabeceras[0]['cob_fecha']; ?>" class="form-control" id="cob_fecha" disabled>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="form-group">
                            <label>Apertura y Cierre de Caja</label>
                            <input type="text" value="<?php echo $cabeceras[0]['id_vac']; ?>" class="form-control" id="id_vac" disabled>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="form-group">
                            <label>Caja</label>
                            <select class="form-control" id="id_caja" disabled>
                                <option value="<?= $cabeceras[0]['id_caja'] ?>"><?= $cabeceras[0]['caj_descrip'] ?></option>
                            </select>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Cajero</label>
                            <select class="select2" id="id_funcionario" disabled>
                                <option value="<?= $cabeceras[0]['id_funcionario'] ?>"><?= $cabeceras[0]['funcionario'] ?></option>
                            </select>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Nro Factura</label>
                            <select class="select2" id="id_vc" <?= $disabled ?>>
                                <option value="<?= $cabeceras[0]['id_vc'] ?>"><?= $cabeceras[0]['vc_nro_factura'] ?></option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group col">
                        <label>Total Efectivo</label>
                        <input type="text" value="<?= number_format($cabeceras_monto[0]['total_efectivo'], 0, ",", ".") ?>" class="form-control" id="total_efectivo" disabled>
                    </div>
                    <div class="form-group col">
                        <label>Total Cheque</label>
                        <input type="text" value="<?= number_format($cabeceras_monto[0]['total_cheque'], 0, ",", ".") ?>" class="form-control" id="total_cheque" disabled>
                    </div>
                    <div class="form-group col">
                        <label>Total Tarjeta</label>
                        <input type="text" value="<?= number_format($cabeceras_monto[0]['total_tarjeta'], 0, ",", ".") ?>" class="form-control" id="total_tarjeta" disabled>
                    </div>
                    <div class="form-group col">
                        <label>Total Transferencia</label>
                        <input type="text" value="<?= number_format($cabeceras_monto[0]['total_transfe'], 0, ",", ".") ?>" class="form-control" id="total_transfe" disabled>
                    </div>
                    <div class="form-group col">
                        <label>Monto Total</label>
                        <input type="text" value="<?= number_format($cabeceras_monto[0]['total_general'], 0, ",", ".") ?>" class="form-control" id="total_general" disabled>
                    </div>

                </div>

                <div class="form-group">
                    <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                    <?php if ($cabeceras[0]['estado'] == 'PENDIENTE') { ?>
                        <button class="btn btn-danger" onclick="anular();"><i class="fa fa-minus-circle"></i> Anular</button>
                        <button class="btn btn-warning text-white" onclick="modificar();"><i class="fa fa-edit"></i> Modificar</button>
                        <button class="btn btn-success" onclick="confirmar();"><i class="fa fa-check-circle"></i> Confirmar</button>
                    <?php } ?>
                </div>
            </div>
        </div>

        <div class="card col-12 card-info">
            <div class="card-body">
                <?php if ($cabeceras[0]['estado'] == 'PENDIENTE') { ?>              
                <button class="btn btn-success" onclick="cuentas(<?= $cabeceras[0]['id_vc'] ?>, <?= $cabeceras[0]['id_cob'] ?>)" id="btn-panel-cuenta-cerrar"><i
                        class="fas fa-regular fa fa-book"></i> Agregar Cuentas</button>
                <?php }else if ($cabeceras[0]['estado'] == 'CONFIRMADO'){ ?>
                    <button class="btn btn-success" onclick="generarInforme(<?= $cabeceras[0]['id_cob'] ?>)" id="btn-panel-cuenta-cerrar"><i
                        class="fas fa-regular fa fa-book"></i> Recibo</button>
                <?php } ?>

            </div>
        </div>

        <div class="card card-primary col-12">
            <div class="card-header text-center elevation-3">
                Detalles de Cobro
            </div>
            <div class="card-body">

                <?php if (!empty($detalles)) { ?>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>#</th>
                                <!-- <th>Form. Cobro</th> -->
                                <th>Concecto</th>
                                <th>Monto</th>
                                <th>Mont. Efectivo</th>
                                <th>Saldo</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            $total = 0;
                            $total_monto = 0;
                            $total_saldo = 0;
                            foreach ($detalles as $d) {
                                $total_monto += $d['cue_monto'];
                                $total_saldo += $d['cob_monto_efe'] ?>
                                <input type="hidden" value="<?php echo $d['id_cue']; ?>" id="id_cue_f">
                                <tr>
                                    <td><?php echo $d['id_cob']; ?></td>
                                    <!-- <td><?php //echo $d['fc_descrip']; 
                                                ?></td> -->
                                    <td><?php echo $d['cue_concepto']; 
                                                ?></td>
                                    <td><?php echo number_format($d['cue_monto'], 0, ",", "."); ?></td>
                                    <td><?php echo number_format($d['cob_monto_efe'], 0, ",", "."); ?></td>
                                    <td><?php echo number_format($d['cue_saldo'], 0, ",", "."); ?></td>
                                    <td>
                                        <?php if ($cabeceras[0]['estado'] == 'PENDIENTE') { ?>
                                            <button class="btn btn-warning" title="Agregar forma de cobro" onclick="panel_modificar(<?= $d['id_cob'] ?>,<?= $d['id_cue'] ?>);"><i class="fa fa-credit-card"></i></button>
                                            <?php
                                            if ($d['id_fc'] == 1) { ?>
                                                <button class="btn btn-success text-white" onclick="agregar_cobro(<?= $d['id_cob'] ?>, <?= $d['id_fc'] ?>);" id="btn-panel-cheque"><i class="fa fa-plus"></i></button>
                                            <?php } else if ($d['id_fc'] == 2) { ?>
                                                <button class="btn btn-success text-white" onclick="agregar_cobro(<?= $d['id_cob'] ?>, <?= $d['id_fc'] ?>);" id="btn-panel-tarjeta"><i class="fa fa-plus"></i></button>
                                            <?php } else if ($d['id_fc'] == 3) { ?>
                                                <button class="btn btn-success text-white" onclick="agregar_cobro(<?= $d['id_cob'] ?>, <?= $d['id_fc'] ?>);" id="btn-panel-transferencia"><i class="fa fa-plus"></i></button>
                                            <?php } ?>
                                        <?php } ?>
                                    </td>
                                </tr>
                            <?php } ?>
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="2">Total</th>
                                <th><?php echo number_format($total_monto, 0, ",", "."); ?></th>
                                <th><?php echo number_format($total_saldo, 0, ",", "."); ?></th>

                            </tr>
                        </tfoot>
                    </table>
                <?php } else { ?>
                    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron detalles...</label>
                <?php } ?>
            </div>
        </div>


        <!-- CARD DE FORMA DE COBRO TARJETA -->
        <div class="card card-secondary col-4">
            <div class="card-header text-center elevation-3">
                Cobro con Tarjeta
            </div>
            <div class="card-body">
                <?php if (!empty($cobros_tarjetas)) { ?>
                    <!-- GRILLA -->
                    <div class="table-responsive">
                        <table class="table table-bordered" style="font-size: 12px;">
                            <thead>
                                <tr>
                                    <th>Nro Vaucher</th>
                                    <th>Cod. Autorizacion</th>
                                    <th>Vencimiento</th>
                                    <th>Monto</th>
                                    <th>Entidad</th>
                                    <th>Tip. Entidad</th>
                                    <!-- <th>Acciones</th> -->
                                </tr>
                            </thead>
                            <tbody>
                                <?php $total = 0;
                                foreach ($cobros_tarjetas as $d) {
                                    $total = $total + $d['tar_monto'] ?>
                                    <tr>
                                        <td><?php echo $d['tar_nro_tarjeta']; ?></td>
                                        <td><?php echo $d['tar_autorizacion']; ?></td>
                                        <td><?php echo $d['fecha_vencimiento']; ?></td>
                                        <td><?php echo number_format($d['tar_monto'], 0, ",", "."); ?></td>
                                        <td><?php echo $d['ee_razon_social'] . " - " . $d['mt_descrip']; ?></td>
                                        <td><?php echo $d['ee_tipo_entidad']; ?></td>

                                    </tr>
                                <?php } ?>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <th colspan="2">Total</th>
                                    <th><?php echo number_format($total, 0, ",", "."); ?></th>
                                    <th></th>
                                    <th></th>

                                </tr>
                            </tfoot>
                        </table>
                    </div>
                <?php } else { ?>
                    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron cobros...</label>
                <?php } ?>
            </div>
        </div>

        <!-- CARD DE FORMA DE COBRO CHEQUE -->
        <div class="card card-secondary col-4">
            <div class="card-header text-center elevation-3">
                Cobro con Cheque
            </div>
            <div class="card-body">
                <?php if (!empty($cobros_cheques)) { ?>
                    <div class="table-responsive">
                        <table class="table table-bordered" style="font-size: 12px;">
                            <thead>
                                <tr>
                                    <th>Nro. Cheque</th>
                                    <th>Vencimiento</th>
                                    <th>Monto</th>
                                    <th>Tip. Cheque</th>
                                    <th>Entidad</th>
                                    <th>Tip. Entidad</th>
                                    <!-- <th>Acciones</th> -->
                                </tr>
                            </thead>
                            <tbody>
                                <?php $total = 0;
                                foreach ($cobros_cheques as $d) {
                                    $total = $total + $d['che_monto'] ?>
                                    <tr>
                                        <td><?php echo $d['che_nro_cheque']; ?></td>
                                        <td><?php echo $d['fecha_vencimiento']; ?></td>
                                        <td><?php echo number_format($d['che_monto'], 0, ",", "."); ?></td>
                                        <td><?php echo $d['che_tipo_cheque']; ?></td>
                                        <td><?php echo $d['ee_razon_social']; ?></td>
                                        <td><?php echo $d['ee_tipo_entidad']; ?></td>
                                    </tr>
                                <?php } ?>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <th colspan="2">Total</th>
                                    <th><?php echo number_format($total, 0, ",", "."); ?></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                <?php } else { ?>
                    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron cobros...</label>
                <?php } ?>
            </div>
        </div>


        <!-- CARD DE FORMA DE COBRO Transferencia -->
        <div class="card card-secondary col-4">
            <div class="card-header text-center elevation-3">
                Cobro con Transferencia
            </div>
            <div class="card-body">
                <?php if (!empty($cobros_transferencia)) { ?>
                    <div class="table-responsive">
                        <table class="table table-bordered" style="font-size: 12px;">
                            <thead>
                                <tr>
                                    <th>Nro. Cuenta</th>
                                    <th>Fecha</th>
                                    <th>Monto</th>
                                    <th>Motivo</th>
                                    <th>Entidad</th>
                                    <th>Tip. Entidad</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php $total = 0;
                                foreach ($cobros_transferencia as $d) {
                                    $total = $total + $d['tra_monto'] ?>
                                    <tr>
                                        <td><?php echo $d['tra_nro_cuenta']; ?></td>
                                        <td><?php echo $d['fecha']; ?></td>
                                        <td><?php echo number_format($d['tra_monto'], 0, ",", "."); ?></td>
                                        <td><?php echo $d['tra_motivo']; ?></td>
                                        <td><?php echo $d['rason_social_ori']; ?></td>
                                        <td><?php echo $d['tipo_entidad_ori']; ?></td>
                                    </tr>
                                <?php } ?>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <th colspan="2">Total</th>
                                    <th><?php echo number_format($total, 0, ",", "."); ?></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                <?php } else { ?>
                    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron cobros...</label>
                <?php } ?>
            </div>
        </div>
    </div>
<?php
}
pg_close($conn);
