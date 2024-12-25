<?php
$id_pre = $_POST['id_pre'];
//$id_cp = $_POST['id_cp'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();

$querySucursal = pg_fetch_all(pg_query($conn, "SELECT id_sucursal, suc_nombre FROM sucursales WHERE id_sucursal = $id_sucursal;"));

$cliente = pg_fetch_all(pg_query($conn, "SELECT DISTINCT ON (id_cliente) id_cliente, cliente, per_ci,
                                            per_edad, id_genero, gen_descrip
                                        FROM v_serv_mediciones_cab
                                        WHERE estado = 'CONFIRMADO'
                                        ORDER BY id_cliente, cliente, per_ci;
                                        "));

$personal_trainer = pg_fetch_all(pg_query($conn, "SELECT * from  v_personal_trainers where estado = 'ACTIVO' order by personal_trainer;"));

if ($id_pre == '-1') { //CUANDO SE RESETEA
?>
    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> Seleccione un presupuesto</label>
<?php
} else if ($id_pre == '0') { //CUANDO SE PRESIONA EL BOTON AGREGAR

?>
    <div class="card card-primary">
        <div class="card-header text-center elevation-3">
            Datos del Presupuesto
        </div>
        <div class="card-body">
            <input type="hidden" value="0" id="id_pre">

            <div class="col-md-2">
                <div class="form-group">
                    <label>Sucursal</label>
                    <input type="text" value="<?= $querySucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                </div>
            </div>

            <div class="form-group">
                <label>Fecha</label>
                <input type="date" value="<?php echo date('Y-m-d'); ?>" class="form-control" id="pre_fecha">
            </div>

            <div class="form-group">
                <label>Clientes</label>
                <select class="select2" id="id_cliente">
                    <option selected="true" disabled="disabled">Seleccione...</option>
                    <?php foreach ($cliente as $cl) { ?>
                        <option value="<?= $cl['id_cliente']; ?>"><?= $cl['cliente'] . " " . $cl['per_ci']; ?></option>
                    <?php }; ?>
                </select>
            </div>

            <div class="form-group">
                <label>Personal Trainer</label>
                <select class="select2" id="id_personal">
                    <?php foreach ($personal_trainer as $cl) { ?>
                        <option value="<?php echo $cl['id_funcionario']; ?>"><?php echo $cl['personal_trainer'] . " " . $cl['per_ci']; ?></option>
                    <?php }; ?>
                </select>
            </div>

            <div class="form-group">
                <label>Observación</label>
                <textarea class="form-control" id="pre_observacion"></textarea>
            </div>

            <div class="form-group">
                <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
<?php
} else { //O SE TRATA DE UN PEDIDO DEFINIDO O SE TRATA DEL ULTIMO PEDIDO
    if ($id_pre == '-2') { //SE TRATA DEL ULTIMO PEDIDO
        $cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_presupuestos_cab WHERE id_pre = (select max(id_pre) from serv_presupuestos_cab where  id_sucursal = $id_sucursal);"));
        //$pedidos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra WHERE id_cp = (select max(id_cp) from compras_pedidos_cabecera where id_sucursal = $id_sucursal);"));
    } else { //SE TRATA DE UN PEDIDO DEFINIDO
        $cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_presupuestos_cab WHERE id_pre = $id_pre;"));
    }
    $detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_presupuestos_det WHERE id_pre = $id_pre ORDER BY id_pre;"));
    $disabled = 'disabled';
    if ($cabecera[0]['estado'] == 'PENDIENTE') {
        $disabled = '';
    }
?>
    <div class="card">
        <div class="card-body">
            <button class="btn btn-primary text-white" onclick="modalSecund();" id="btn-modal-secund-cerrar"><i class="fas fa-plus-circle"></i> Pedidos</button>
            <button class="btn btn-primary text-white" onclick="modalConsolidacion(<?php echo $cabecera[0]['id_pre']; ?>);" id="btn-modal-secund-cerrar"><i class="fas fa-table-tree"></i> Consolidacion</button>
            <button class="btn btn-danger text-white" onclick="" id="btn-modal-secund-cerrar"><i class="fas fa-regular fa-file-pdf"></i> Reportes</button>

        </div>
    </div>


    <div class="row">
        <div class="card card-primary col-12">
            <div class="card-header text-center elevation-3">
                Datos del Presupuesto
            </div>
            <div class="card-body">
                <input type="hidden" value="<?php echo $cabecera[0]['id_pre']; ?>" id="id_pre">
                <input type="hidden" value="0" id="eliminar_id_act">


                <div class="col-md-2">
                    <div class="form-group">
                        <label>Sucursal</label>
                        <input type="text" value="<?= $querySucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                    </div>
                </div>

                <div class="form-group">
                    <label>Fecha</label>
                    <input type="date" value="<?= $cabecera[0]['pre_fecha']; ?>" class="form-control" id="pre_fecha">
                </div>


                <div class="form-group">
                    <label>Clientes</label>
                    <select class="select2" id="id_cliente">
                        <option selected="true" value="<?= $cabecera[0]['id_cliente']; ?>"><?= $cabecera[0]['cliente'] ?></option>
                        <?php foreach ($cliente as $cl) { ?>
                            <option value="<?php echo $cl['id_cliente']; ?>"><?php echo $cl['cliente'] . " " . $cl['per_ci']; ?></option>
                        <?php }; ?>
                    </select>
                </div>

                <div class="form-group">
                    <label>Personal Trainer</label>
                    <select class="select2" id="id_personal">
                        <option selected="true" value="<?= $cabecera[0]['id_personal']; ?>"><?= $cabecera[0]['personal'] ?></option>
                        <?php foreach ($personal_trainer as $cl) { ?>
                            <option value="<?php echo $cl['id_funcionario']; ?>"><?php echo $cl['personal_trainer'] . " " . $cl['per_ci']; ?></option>
                        <?php }; ?>
                    </select>
                </div>

                <div class="form-group">
                    <label>Observación</label>
                    <textarea class="form-control" id="pre_observacion"><?= $cabecera[0]['pre_observacion']; ?></textarea>
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
        <!-- TABLA DE PRESUPUESTO -->
        <div class="card card-primary col-8">
            <div class="card-header text-center elevation-3">
                Detalles del Presupuesto
            </div>
            <div class="card-body">
                <?php if (!empty($detalles)) { ?>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Medición</th>
                                <th>Descripción</th>
                                <th>Costo</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php 
                            $total = 0;
                            foreach ($detalles as $d) { 
                                $total += $d['costo'];
                                ?>
                                <tr>
                                    <td><?= $d['act_descrip']; ?></td>
                                    <td><?= $d['descrip']; ?></td>
                                    <td><?= number_format($d['costo'], 0, ',', '.'); ?></td>
                                    <td>
                                        <?php if ($cabecera[0]['estado'] == 'PENDIENTE') { ?>
                                            <button class="btn btn-warning text-white" onclick="modificar_detalle(<?php echo $d['id_act']; ?>);" id="btn-panel-modificar-cerrar"><i class="fa fa-edit"></i></button>
                                            <button class="btn btn-danger" onclick="eliminar_detalle(<?php echo $d['id_act']; ?>);"><i class="fa fa-minus-circle"></i></button>
                                        <?php } ?>
                                    </td>
                                </tr>
                            <?php } ?>
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="2">Total</th>
                                <th> <?= number_format($total, 0, ',', '.'); ?></th>
                                <th></th>
                            </tr>
                            </tr>
                        </tfoot>
                    </table>
                <?php } else { ?>
                    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron detalles...</label>
                <?php } ?>
            </div>
        </div>
        <?php if ($cabecera[0]['estado'] == 'PENDIENTE') {
            $actividades = pg_fetch_all(pg_query($conn, "SELECT * FROM actividades WHERE estado = 'ACTIVO' AND act_tipo = 'PRESUPUESTO' AND id_act NOT IN (select id_act from v_serv_presupuestos_det WHERE id_pre = " . $cabecera[0]['id_pre'] . ") ORDER BY act_descrip;"))
        ?>
            <!-- PARA AGREGAR PRESUPUESTO DETALLE -->
            <div class="card card-primary col-4">
                <div class="card-header text-center elevation-3">
                    Agregar Motivo de Presupuesto
                </div>
                <div class="card-body">
                    <?php if (!empty($actividades)) { ?>
                        <div class="form-group">
                            <label>Tipo de Presupuesto</label>
                            <select class="select2" id="agregar_id_act">
                                <option selected="true" disabled>Seleccione...</option>
                                <?php foreach ($actividades as $a) { ?>
                                    <option value="<?= $a['id_act']; ?>"><?= $a['act_descrip']; ?></option>
                                <?php } ?>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Descripción</label>
                            <input type="text" value="N/A" class="form-control" id="agregar_descrip">
                        </div>

                        <div class="form-group">
                            <label>Costo Estimado</label>
                            <input type="number" value="" class="form-control" id="agregar_costo">
                        </div>

                        <div class="form-group">
                            <button class="btn btn-success" onclick="agregar_detalles();"><i class="fa fa-plus-circle"></i> Agregar</button>
                        </div>

                    <?php } else { ?>
                        <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se encuentran productos disponibles...</label>
                    <?php } ?>
                </div>
            </div>
            <script>
                const datoMed = <?= json_encode($actividades) ?>;
            </script>
        <?php } ?>

        <!-- MONTOS TOTALES DE PEDIDOS Y PRESUPUESTO -->


    </div>
<?php } ?>

<?php
pg_close($conn);
