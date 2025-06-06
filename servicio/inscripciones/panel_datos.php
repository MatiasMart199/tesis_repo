<?php
$id_inscrip = $_POST['id_inscrip'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();
$cliente = pg_fetch_all(pg_query($conn, "SELECT * from  v_clientes where id_cliente not in (select id_cliente from v_servicios_inscripciones) and estado = 'ACTIVO' order by cliente, per_ruc;"));

function getFechaDays($fechaIni, $fechaFi)
{
    $fechaInicio = new DateTime($fechaIni);
    $fechaFin = new DateTime($fechaFi);

    $diferencia = $fechaInicio->diff($fechaFin);

    return $diferencia->days;
}

if ($id_inscrip == '-1') { //CUANDO SE RESETEA
?>
    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> Seleccione una inscripcion</label>
<?php
} else if ($id_inscrip == '0') { //CUANDO SE PRESIONA EL BOTON AGREGAR
?>
    <div class="card card-primary">
        <div class="card-header text-center elevation-3">
            Datos de la inscripción
        </div>
        <div class="card-body">
            <input type="hidden" value="0" id="id_inscrip">
            <div>
                <label>Cliente</label>
                <select class="select2" id="id_cliente">
                    <option selected="true" disabled>Seleccione...</option>
                    <?php foreach ($cliente as $cl) { ?>
                        <option value="<?php echo $cl['id_cliente']; ?>"><?php echo $cl['cliente'] . " " . $cl['per_ruc']; ?></option>
                    <?php }; ?>
                </select>
            </div>

            <div class="form-group">
                <label>Fecha</label>
                <input type="date" value="<?php echo date('Y-m-d'); ?>" class="form-control" disabled>
            </div>

            <div class="form-group">
                <label>Vencimiento</label>
                <input type="date" value="<?php echo date('Y-m-d'); ?>" class="form-control" id="ins_aprobacion">
            </div>
            <div class="form-group">
                <label>Estado de Salud</label>
                <textarea class="form-control" id="ins_estad_salud"></textarea>
            </div>
            <div class="form-group">
                <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
<?php
} else { //O SE TRATA DE UN PEDIDO DEFINIDO O SE TRATA DEL ULTIMO PEDIDO
    if ($id_inscrip == '-2') { //SE TRATA DEL ULTIMO PEDIDO
        $movimientos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_servicios_inscripciones WHERE id_inscrip = (select max(id_inscrip) from servicios_inscripciones_cabecera where id_sucursal = $id_sucursal);"));
    } else { //SE TRATA DE UN PEDIDO DEFINIDO
        $movimientos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_servicios_inscripciones WHERE id_inscrip = $id_inscrip;"));
    }
    $detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_servicios_inscripciones_detalle WHERE id_inscrip = " . $movimientos[0]['id_inscrip'] . " ORDER BY ps_descrip;"));
    $disabled = 'disabled';
    if ($movimientos[0]['estado'] == 'PENDIENTE') {
        $disabled = '';
    }
?>
    <div class="row">
        <div class="card card-primary col-12">
            <div class="card-header text-center elevation-3">
                Datos de la Inscripción
            </div>
            
            <div class="card-body">
                <input type="hidden" value="<?php echo $movimientos[0]['id_inscrip']; ?>" id="id_inscrip">
                <input type="hidden" value="0" id="eliminar_id_plan_servi">
                <div>
                    <label>Cliente</label>
                    <select class="select2" id="id_cliente" disabled>
                        <option selected="true" value="<?= $movimientos[0]['id_cliente']; ?>"><?= $movimientos[0]['cliente'] . " " . $movimientos[0]['per_ci']; ?></option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Fecha</label>
                    <input type="date" value="<?= $movimientos[0]['ins_fecha']; ?>" class="form-control" disabled>
                </div>

                <div class="form-group">
                    <label>Vencimiento</label>
                    <input type="date" value="<?= $movimientos[0]['ins_aprobacion']; ?>" class="form-control" id="ins_aprobacion">
                </div>
                <div class="form-group">
                    <label>Estado de Salud</label>
                    <textarea class="form-control" id="ins_estad_salud"><?= $movimientos[0]['ins_estad_salud'] ?></textarea>
                </div>
                <div class="form-group">
                    <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                    <?php if ($movimientos[0]['estado'] == 'PENDIENTE') { ?>
                        <button class="btn btn-danger" onclick="anular();"><i class="fa fa-minus-circle"></i> Anular</button>
                        <button class="btn btn-warning text-white" onclick="modificar();"><i class="fa fa-edit"></i> Modificar</button>
                        <button class="btn btn-success" onclick="confirmar();"><i class="fa fa-check-circle"></i> Confirmar</button>
                    <?php } ?>
                </div>
            </div>
        </div>
        <div class="card card-primary col-8">
            <div class="card-header text-center elevation-3">
                Detalles de la Inscripción
            </div>
            <div class="card-body">
                <?php if (!empty($detalles)) { ?>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Producto</th>
                                <th>Dia</th>
                                <th>Precio Unitario</th>
                                <th>Subtotal</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php $total = 0;
                            foreach ($detalles as $d) {
                                $total = $total + ($d['precio'] * $d['dia']) ?>
                                <tr>
                                    <td><?php echo $d['ps_descrip']; ?></td>
                                    <td><?php echo $d['dia']; ?></td>
                                    <td><?php echo $d['precio']; ?></td>
                                    <td><?php echo $d['precio'] * $d['dia']; ?></td>
                                    <td>
                                        <?php if ($movimientos[0]['estado'] == 'PENDIENTE') { ?>
                                            <button class="btn btn-warning text-white" onclick="modificar_detalle(<?php echo $d['id_plan_servi']; ?>);" id="btn-panel-modificar-cerrar"><i class="fa fa-edit"></i></button>
                                            <button class="btn btn-danger" onclick="eliminar_detalle(<?php echo $d['id_plan_servi']; ?>);"><i class="fa fa-minus-circle"></i></button>
                                        <?php } ?>
                                    </td>
                                </tr>
                            <?php } ?>
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="3">Total</th>
                                <th><?php echo number_format($total, 0, ",", "."); ?></th>
                                <th></th>
                            </tr>
                        </tfoot>
                    </table>
                <?php } else { ?>
                    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron detalles...</label>
                <?php } ?>
            </div>
        </div>
        <?php if ($movimientos[0]['estado'] == 'PENDIENTE') {
            $articulos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_planes_servicios WHERE estado = 'ACTIVO' AND id_plan_servi NOT IN (select id_plan_servi from servicios_inscripciones_detalle WHERE id_inscrip = " . $movimientos[0]['id_inscrip'] . ") ORDER BY ps_descrip;"))
        ?>
            <div class="card card-primary col-4">
                <div class="card-header text-center elevation-3">
                    Agregar Plan
                </div>
                <div class="card-body">
                    <?php if (!empty($articulos)) { ?>
                        <div class="form-group">
                            <label>Plan de Servicio</label>
                            <select class="select2" id="agregar_id_plan_servi">
                                <?php foreach ($articulos as $a) { ?>
                                    <option value="<?php echo $a['id_plan_servi']; ?>"><?php echo $a['ps_descrip']; ?></option>
                                <?php } ?>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Dias</label>
                            <input type="number" value="<?= getFechaDays($movimientos[0]['ins_fecha'], $movimientos[0]['ins_aprobacion']) ?>" class="form-control" id="agregar_dia">
                        </div>
                        <div class="form-group">
                            <button class="btn btn-success" onclick="agregar_detalles();"><i class="fa fa-plus-circle"></i> Agregar</button>
                        </div>
                    <?php } else { ?>
                        <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se encuentran plan disponibles...</label>
                    <?php } ?>
                </div>
            </div>
        <?php } ?>
    </div>
<?php
}
