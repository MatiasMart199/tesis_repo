<?php
$id_ali = $_POST['id_ali'];
//$id_cp = $_POST['id_cp'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();


$querySucursal = pg_fetch_all(pg_query($conn, "SELECT id_sucursal, suc_nombre FROM sucursales WHERE id_sucursal = $id_sucursal;"));

$cliente = pg_fetch_all(pg_query($conn, "SELECT DISTINCT ON (id_cliente) id_cliente, cliente, per_ci,
                                            per_edad, id_genero, gen_descrip
                                        FROM v_servicios_inscripciones
                                        WHERE estado = 'CONFIRMADO'
                                        ORDER BY id_cliente, cliente, per_ci;
                                        "));

$servicio = pg_fetch_all(pg_query($conn, "SELECT id_mem, id_plan_servi, ps_descrip, id_cliente, cliente FROM v_serv_membresias_cliente_f WHERE 
    id_mem = (SELECT MAX(id_mem) 
                FROM v_serv_membresias_cliente_f) AND estadoCab = 'CONFIRMADO' order by ps_descrip;"));

$nutriologos = pg_fetch_all(pg_query($conn, "SELECT * from  v_nutriologos where estado = 'ACTIVO' order by v_nutriologos;"));
if ($id_ali == '-1') { //CUANDO SE RESETEA
?>
    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> Seleccione un presupuesto</label>
<?php
} else if ($id_ali == '0') { //CUANDO SE PRESIONA EL BOTON AGREGAR

?>
    <div class="card card-primary">
        <div class="card-header text-center elevation-3">
            Datos de la Medición
        </div>
        <div class="card-body">
            <input type="hidden" value="0" id="id_ali">

            <div class="col-md-2">
                <div class="form-group">
                    <label>Sucursal</label>
                    <input type="text" value="<?= $querySucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label>Fecha Inicio</label>
                        <input disabled type="date" value="<?php echo date('Y-m-d'); ?>" class="form-control" id="ali_fecha">
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="form-group">
                        <label>Fecha Fin</label>
                        <input type="date" value="<?php echo date('Y-m-d'); ?>" class="form-control" id="ali_fecha_fin">
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label>Objetivo</label>
                        <input type="text" value="" class="form-control" id="ali_objetivo">
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="form-group">
                        <label>Dias de la Semana</label>
                        <select class="select2" id="ali_dias">
                            <option value="L,M,Mi,J,V,S,D">Lunes a Domingo</option>
                            <option value="L,M,Mi,J,V">Lunes a Viernes</option>
                            <option value="L,M,Mi">Lunes a Miércoles</option>
                        </select>
                    </div>
                </div>
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

                <div class="col-md-6">
                    <div class="form-group">
                        <label>Genero</label>
                        <select class="select2" id="id_genero">
                            <option value=""></option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label>Servicio</label>
                <select class="select2" id="id_plan_servi">
                    <option selected="true" disabled>Seleccione...</option>
                </select>
            </div>

            <div class="form-group">
                <label>Nutriologo</label>
                <select class="select2" id="id_nutriologo">
                    <?php foreach ($nutriologos as $cl) { ?>
                        <option value="<?php echo $cl['id_funcionario']; ?>"><?php echo $cl['nutriologo'] . " " . $cl['per_ci']; ?></option>
                    <?php }; ?>
                </select>
            </div>

            <div class="form-group">
                <label>Observación</label>
                <textarea class="form-control" id="ali_observacion"></textarea>
            </div>

            <div class="form-group">
                <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
<?php
} else { //O SE TRATA DE UN PEDIDO DEFINIDO O SE TRATA DEL ULTIMO PEDIDO
    if ($id_ali == '-2') { //SE TRATA DEL ULTIMO PEDIDO
        $cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_alimentaciones_cab WHERE id_ali = (select max(id_ali) from serv_alimentaciones_cab where  id_sucursal = $id_sucursal);"));
        //$pedidos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra WHERE id_cp = (select max(id_cp) from compras_pedidos_cabecera where id_sucursal = $id_sucursal);"));
    } else { //SE TRATA DE UN PEDIDO DEFINIDO
        $cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_alimentaciones_cab WHERE id_ali = $id_ali;"));
    }
    $detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_alimentaciones_det WHERE id_ali = $id_ali ORDER BY id_ali;"));
    //$footer = pg_fetch_all(pg_query($conn, "SELECT imc, grasa_corporal FROM v_serv_mediciones_foot WHERE id_ali = $id_ali ORDER BY id_ali;"));
    $disabled = 'disabled';
    if ($cabecera[0]['estado'] == 'PENDIENTE') {
        $disabled = '';
    }
?>
    <div class="card">
        <div class="card-body">
            <button class="btn btn-primary text-white" onclick="modalSecund();" id="btn-modal-secund-cerrar"><i class="fas fa-plus-circle"></i> Pedidos</button>
            <button class="btn btn-primary text-white" onclick="modalConsolidacion(<?php echo $cabecera[0]['id_ali']; ?>);" id="btn-modal-secund-cerrar"><i class="fas fa-table-tree"></i> Consolidacion</button>
            <button class="btn btn-danger text-white" onclick="" id="btn-modal-secund-cerrar"><i class="fas fa-regular fa-file-pdf"></i> Reportes</button>

        </div>
    </div>


    <div class="row">
        <div class="card card-primary col-12">
            <div class="card-header text-center elevation-3">
                Datos de la Medición
            </div>
            <div class="card-body">
                <input type="hidden" value="<?php echo $cabecera[0]['id_ali']; ?>" id="id_ali">
                <input type="hidden" value="0" id="eliminar_id_act">


                <div class="col-md-2">
                    <div class="form-group">
                        <label>Sucursal</label>
                        <input type="text" value="<?= $querySucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Fecha Inicio</label>
                            <input disabled type="date" value="<?= $cabecera[0]['ali_fecha']; ?>" class="form-control" id="ali_fecha">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Fecha Fin</label>
                            <input type="date" value="<?= $cabecera[0]['ali_fecha_fin']; ?>" class="form-control" id="ali_fecha_fin">
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Objetivo</label>
                            <input type="text" value="<?= $cabecera[0]['ali_objetivo']; ?>" class="form-control" id="ali_objetivo">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Dias de la Semana</label>
                            <select class="select2" id="ali_dias">
                            <option value="<?= $cabecera[0]['ali_dias']; ?>" selected><?= $cabecera[0]['ali_dias']; ?></option>
                            <option value="Lunes a Domingo">Lunes a Domingo</option>
                            <option value="Lunes a Viernes">Lunes a Viernes</option>
                            <option value="Lunes a Miércoles">Lunes a Miércoles</option>
                            </select>
                        </div>
                    </div>
                </div>


                <div class="row">
                    <div class="col-md-6">
                        <div>
                            <label>Clientes</label>
                            <select class="select2" id="id_cliente">
                                <option selected="true" value="<?= $cabecera[0]['id_cliente']; ?>"><?= $cabecera[0]['cliente']; ?></option>
                                <?php foreach ($cliente as $cl) { ?>
                                    <option value="<?= $cl['id_cliente']; ?>"><?= $cl['cliente'] . " " . $cl['per_ci']; ?></option>
                                <?php }; ?>
                            </select>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Genero</label>
                            <select class="select2" id="id_genero" disabled>
                                <option value="" selected><?= $cabecera[0]['gen_descrip']; ?></option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label>Servicio</label>
                    <select class="select2" id="id_plan_servi">
                        <option selected="true" value="<?= $cabecera[0]['id_plan_servi']; ?>"><?= $cabecera[0]['ps_descrip']; ?></option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Nutriologo</label>
                    <select class="select2" id="id_nutriologo">
                        <option value="<?= $cabecera[0]['id_nutriologo']; ?>" selected><?= $cabecera[0]['nutriologo']; ?></option>
                        <?php foreach ($nutriologos as $cl) { ?>
                            <option value="<?php echo $cl['id_funcionario']; ?>"><?php echo $cl['nutriologo'] . " " . $cl['per_ci']; ?></option>
                        <?php }; ?>
                    </select>
                </div>

                <div class="form-group">
                    <label>Observación</label>
                    <textarea class="form-control" id="ali_observacion"><?= $cabecera[0]['ali_observacion']; ?></textarea>
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
                Detalles de la Medición
            </div>
            <div class="card-body">
                <?php if (!empty($detalles)) { ?>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Comida</th>
                                <th>Alimento</th>
                                <th>Cant.(g)</th>
                                <th>Cal.(kcal)</th>
                                <th>Carb.(g)</th>
                                <th>Prot.(g)</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php 
                            $totalCal = 0;
                            $totalCarb = 0;
                            $totalProt = 0;    
                            foreach ($detalles as $d) {
                                $totalCal += $d['calorias'];
                                $totalCarb += $d['carbohidratos'];
                                $totalProt += $d['proteinas'];
                            ?>
                                <tr>
                                    <td><?php echo $d['act_descrip']; ?></td>
                                    <td><?php echo $d['alimento']; ?></td>
                                    <td><?php echo $d['cantidad']; ?></td>
                                    <td><?php echo $d['calorias']; ?></td>
                                    <td><?php echo $d['carbohidratos']; ?></td>
                                    <td><?php echo $d['proteinas']; ?></td>
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
                                <th colspan="3">Total Calorias:</th>
                                <th> <?= number_format($totalCal, 1, ',', '.')  ?></th>
                                <th></th>
                                <th></th> 
                                <th></th> 
                            </tr>
                            <tr>
                                <th colspan="4">Total Carbohidratos:</th>
                                <th> <?= number_format($totalCarb, 1, ',', '.')  ?></th>
                                <th></th>
                                <th></th>
                            </tr>
                            <tr>
                                <th colspan="5">Total Proteinas:</th>
                                <th> <?= number_format($totalProt, 1, ',', '.')  ?></th>
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
            $actividades = pg_fetch_all(pg_query($conn, "SELECT * FROM actividades WHERE estado = 'ACTIVO' AND act_tipo = 'COMIDA' AND id_act NOT IN (select id_act from serv_alimentaciones_det WHERE id_ali = " . $cabecera[0]['id_ali'] . ") ORDER BY act_descrip;"))
        ?>
            <!-- PARA AGREGAR PRESUPUESTO DETALLE -->
            <div class="card card-primary col-4">
                <div class="card-header text-center elevation-3">
                    Agregar Plan
                </div>
                <div class="card-body">
                    <?php if (!empty($actividades)) { ?>
                        <div class="form-group">
                            <label>Comida</label>
                            <select class="select2" id="agregar_id_act">
                                <option selected="true" disabled>Seleccione...</option>
                                <?php foreach ($actividades as $a) { ?>
                                    <option value="<?= $a['id_act']; ?>"><?= $a['act_descrip']; ?></option>
                                <?php } ?>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Alimento</label>
                            <input type="text" value="" class="form-control" id="agregar_alimento">
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
                                    <label>Cantidad</label>
                                    <input type="number" value="" class="form-control" id="agregar_cantidad">
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>Calorías</label>
                                    <input type="number" value="" class="form-control" id="agregar_calorias">
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>Carbohidratos</label>
                                    <input type="number" value="" class="form-control" id="agregar_carbohidratos">
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>Proteínas</label>
                                    <input type="number" value="" class="form-control" id="agregar_proteinas">
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
                const datoAct = <?= json_encode($actividades) ?>;
            </script>
        <?php } ?>

        <!-- MONTOS TOTALES DE PEDIDOS Y PRESUPUESTO -->


    </div>
<?php } ?>
<script>
    const datoCliente = <?= json_encode($cliente) ?>;
    const datoServicio = <?= json_encode($servicio) ?>;
</script>

<?php
pg_close($conn);
