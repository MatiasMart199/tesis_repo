<?php
$id_evo = $_POST['id_evo'];
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

$medicion = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_mediciones_foot WHERE estado = 'CONFIRMADO';"));

if ($id_evo == '-1') { //CUANDO SE RESETEA
?>
    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> Seleccione un presupuesto</label>
<?php
} else if ($id_evo == '0') { //CUANDO SE PRESIONA EL BOTON AGREGAR

?>
    <div class="card card-primary">
        <div class="card-header text-center elevation-3">
            Datos de la Evolución
        </div>
        <div class="card-body">
            <input type="hidden" value="0" id="id_evo">

            <div class="col-md-2">
                <div class="form-group">
                    <label>Sucursal</label>
                    <input type="text" value="<?= $querySucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                </div>
            </div>

            <div class="form-group">
                <label>Fecha</label>
                <input type="date" value="<?php echo date('Y-m-d'); ?>" class="form-control" id="evo_fecha">
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div>
                        <label>Clientes</label>
                        <select class="select2" id="id_cliente">
                            <option selected="true" disabled="disabled">Seleccione...</option>
                            <?php foreach ($cliente as $cl) { ?>
                                <option value="<?= $cl['id_cliente']; ?>"><?= $cl['cliente'] . " " . $cl['per_ci']; ?></option>
                            <?php }; ?>
                        </select>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="form-group">
                        <label>Edad</label>
                        <input type="text" value="" class="form-control" id="evo_edad">
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="form-group">
                        <label>Genero</label>
                        <select class="select2" id="id_genero">
                            <option value=""></option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-4">
                    <div class="form-group">
                        <label>N° de Medición</label>
                        <input type="text" value="" class="form-control" id="id_med" disabled>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="form-group">
                        <label>IMC</label>
                        <input type="number" value="" class="form-control" id="evo_imc" disabled>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="form-group">
                        <label>PGC</label>
                        <input type="number" value="" class="form-control" id="evo_pgc" disabled>
                    </div>
                </div>
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
                <textarea class="form-control" id="evo_observacion"></textarea>
            </div>

            <div class="form-group">
                <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
<?php
} else { //O SE TRATA DE UN PEDIDO DEFINIDO O SE TRATA DEL ULTIMO PEDIDO
    if ($id_evo == '-2') { //SE TRATA DEL ULTIMO PEDIDO
        $cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_evoluciones_cab WHERE id_evo = (select max(id_evo) from serv_evoluciones_cab where  id_sucursal = $id_sucursal);"));
        //$pedidos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra WHERE id_cp = (select max(id_cp) from compras_pedidos_cabecera where id_sucursal = $id_sucursal);"));
    } else { //SE TRATA DE UN PEDIDO DEFINIDO
        $cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_evoluciones_cab WHERE id_evo = $id_evo;"));
    }
    $detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_evoluciones_det WHERE id_evo = $id_evo ORDER BY id_evo;"));
    $footer = pg_fetch_all(pg_query($conn, "SELECT imc, grasa_corporal, peso_anterior, diferencia_peso, estado_peso FROM v_serv_evoluciones_foot WHERE id_evo = $id_evo ORDER BY id_evo;"));
    $disabled = 'disabled';
    if ($cabecera[0]['estado'] == 'PENDIENTE') {
        $disabled = '';
    }
?>
    <div class="card">
        <div class="card-body">
            <button class="btn btn-primary text-white" onclick="modalSecund();" id="btn-modal-secund-cerrar"><i class="fas fa-plus-circle"></i> Pedidos</button>
            <button class="btn btn-primary text-white" onclick="modalConsolidacion(<?php echo $cabecera[0]['id_evo']; ?>);" id="btn-modal-secund-cerrar"><i class="fas fa-table-tree"></i> Consolidacion</button>
            <button class="btn btn-danger text-white" onclick="" id="btn-modal-secund-cerrar"><i class="fas fa-regular fa-file-pdf"></i> Reportes</button>

        </div>
    </div>


    <div class="row">
        <div class="card card-primary col-12">
            <div class="card-header text-center elevation-3">
                Datos de la Evolución
            </div>
            <div class="card-body">
                <input type="hidden" value="<?php echo $cabecera[0]['id_evo']; ?>" id="id_evo">
                <input type="hidden" value="0" id="eliminar_id_act">


                <div class="col-md-2">
                    <div class="form-group">
                        <label>Sucursal</label>
                        <input type="text" value="<?= $querySucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                    </div>
                </div>

                <div class="form-group">
                    <label>Fecha</label>
                    <input type="date" value="<?= $cabecera[0]['evo_fecha']; ?>" class="form-control" id="evo_fecha">
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div>
                            <label>Clientes</label>
                            <select class="select2" id="id_cliente">
                                <option selected="true" value="<?= $cabecera[0]['id_cliente']; ?>"><?= $cabecera[0]['cliente'] ?></option>
                                <?php foreach ($cliente as $cl) { ?>
                                    <option value="<?php echo $cl['id_cliente']; ?>"><?php echo $cl['cliente'] . " " . $cl['per_ci']; ?></option>
                                <?php }; ?>
                            </select>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="form-group">
                            <label>Edad</label>
                            <input type="text" value="<?= $cabecera[0]['evo_edad']; ?>" class="form-control" id="evo_edad" disabled>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="form-group">
                            <label>Genero</label>
                            <select class="select2" id="id_genero" disabled>
                                <option value="<?= $cabecera[0]['id_genero']; ?>"><?= $cabecera[0]['gen_descrip']; ?></option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-4">
                        <div class="form-group">
                            <label>N° de Medición</label>
                            <input type="text" value="<?= $cabecera[0]['id_med']; ?>" class="form-control" id="id_med" disabled>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="form-group">
                            <label>IMC</label>
                            <input type="number" value="<?= $cabecera[0]['evo_imc']; ?>" class="form-control" id="evo_imc" disabled>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="form-group">
                            <label>PGC</label>
                            <input type="number" value="<?= $cabecera[0]['evo_pgc']; ?>" class="form-control" id="evo_pgc" disabled>
                        </div>
                    </div>
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
                    <textarea class="form-control" id="evo_observacion"><?= $cabecera[0]['evo_observacion']; ?></textarea>
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
                Detalles de la Evolución
            </div>
            <div class="card-body">
                <?php if (!empty($detalles)) { ?>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Medición</th>
                                <th>Ud.</th>
                                <th>Valor</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($detalles as $d) { ?>
                                <tr>
                                    <td><?php echo $d['act_descrip']; ?></td>
                                    <td><?php echo $d['act_unidad']; ?></td>
                                    <td><?php echo $d['valor']; ?></td>
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
                                <th colspan="2">Indice de Masa Corporal (IMC)</th>
                                <th> <?= $footer[0]['imc'] !== null ? number_format($footer[0]['imc'], 2, ',', '.') : 'N/A'; ?></th>
                                <th></th>
                            </tr>
                            <tr>
                                <th colspan="2">Porcentaje de Grasa Corporal</th>
                                <th> <?= $footer[0]['grasa_corporal'] !== null ? number_format($footer[0]['grasa_corporal'], 2, ',', '.') . "%" : 'N/A'; ?></th>
                                <th></th>
                            </tr>
                            <tr>
                                <th colspan="2">Peso Anterior</th>
                                <th> <?= $footer[0]['peso_anterior'] !== null ? number_format($footer[0]['peso_anterior'], 0, ',', '.') : 'N/A'; ?></th>
                                <th></th>
                            </tr>
                            <tr>
                                <th colspan="2">Diferencia de Peso</th>
                                <th> <?= $footer[0]['diferencia_peso'] !== null ? $footer[0]['diferencia_peso'] : 'N/A'; ?></th>
                                <th></th>
                            </tr>
                            <tr>
                                <th colspan="2">Estado</th>
                                <th> <?= $footer[0]['estado_peso'] !== null ? $footer[0]['estado_peso'] : 'N/A'; ?></th>
                                <th></th>
                            </tr>
                        </tfoot>
                    </table>
                <?php } else { ?>
                    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron detalles...</label>
                <?php } ?>
            </div>
        </div>
        <?php if ($cabecera[0]['estado'] == 'PENDIENTE') {
            $actividades = pg_fetch_all(pg_query($conn, "SELECT * FROM actividades WHERE estado = 'ACTIVO' AND act_tipo = 'MEDICION' AND id_act NOT IN (select id_act from v_serv_evoluciones_det WHERE id_evo = " . $cabecera[0]['id_evo'] . ") ORDER BY act_descrip;"))
        ?>
            <!-- PARA AGREGAR PRESUPUESTO DETALLE -->
            <div class="card card-primary col-4">
                <div class="card-header text-center elevation-3">
                    Agregar Evolucion
                </div>
                <div class="card-body">
                    <?php if (!empty($actividades)) { ?>
                        <div class="form-group">
                            <label>Tipo de Medición</label>
                            <select class="select2" id="agregar_id_act" onchange="llenarDatosMed()">
                                <option selected="true" disabled>Seleccione...</option>
                                <?php foreach ($actividades as $a) { ?>
                                    <option value="<?= $a['id_act']; ?>"><?= $a['act_descrip']; ?></option>
                                <?php } ?>
                            </select>
                        </div>
                        <div class="row">
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Unidad</label>
                                    <input type="text" value="" class="form-control" id="unidad" disabled>
                                </div>
                            </div>
                            <div class="col-md-9">
                                <div class="form-group">
                                    <label>Valor</label>
                                    <input type="number" value="" class="form-control" id="agregar_valor">
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
            <script>
                const datoMed = <?= json_encode($actividades) ?>;
            </script>
        <?php } ?>

        <!-- MONTOS TOTALES DE PEDIDOS Y PRESUPUESTO -->


    </div>
<?php } ?>
<script>
    const datoCliente = <?= json_encode($cliente) ?>;
    const datoMedicion = <?= json_encode($medicion) ?>;
</script>

<?php
pg_close($conn);
