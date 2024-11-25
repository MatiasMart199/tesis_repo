<?php
$id_mem = $_POST['id_mem'];
//$id_cp = $_POST['id_cp'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();

$comprasSucursal = pg_fetch_all(pg_query($conn, "SELECT id_sucursal, suc_nombre FROM sucursales WHERE id_sucursal = $id_sucursal;"));

$cliente = pg_fetch_all(pg_query($conn, "SELECT DISTINCT ON (id_cliente) id_cliente, cliente, per_ci
                                        FROM v_servicios_inscripciones
                                        WHERE estado = 'CONFIRMADO'
                                        ORDER BY id_cliente, cliente, per_ci;
                                        "));



// Devuelve la cantidad de dias entre dos fechas dadas.
function getFechaDays($fechaIni, $fechaFi){
    $fechaInicio = new DateTime($fechaIni);
    $fechaFin = new DateTime($fechaFi);

    $diferencia = $fechaInicio->diff($fechaFin);

    return $diferencia->days;
}

if ($id_mem == '-1') { //CUANDO SE RESETEA
?>
    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> Seleccione una membresia</label>
<?php
} else if ($id_mem == '0') { //CUANDO SE PRESIONA EL BOTON AGREGAR

?>
    <div class="card card-primary">
        <div class="card-header text-center elevation-3">
            Datos de la membresía
        </div>
        <div class="card-body">
            <input type="hidden" value="0" id="id_mem">

            <div class="col-md-2">
                <div class="form-group">
                    <label>Sucursal</label>
                    <input type="text" value="<?= $comprasSucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                </div>
            </div>

            <div>
                <label>Clientes Inscritos</label>
                <select class="select2" id="id_cliente">
                    <?php foreach ($cliente as $cl) { ?>
                        <option value="<?php echo $cl['id_cliente']; ?>"><?php echo $cl['cliente'] . " " . $cl['per_ci']; ?></option>
                    <?php }; ?>
                </select>
            </div>

            <div class="form-group">
                <label>Fecha</label>
                <input type="date" value="<?php echo date('Y-m-d'); ?>" class="form-control" id="mem_fecha" disabled>
            </div>

            <div class="form-group">
                <label>Vencimiento</label>
                <input type="date" value="" class="form-control" id="mem_vence">
            </div>

            <div class="form-group">
                <label>Observación</label>
                <textarea class="form-control" id="mem_observacion"></textarea>
            </div>
            <div class="form-group">
                <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
<?php
} else { //O SE TRATA DE UN PEDIDO DEFINIDO O SE TRATA DEL ULTIMO PEDIDO
    if ($id_mem == '-2') { //SE TRATA DEL ULTIMO PEDIDO
        $membresias = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_membresias_cab WHERE id_mem = (select max(id_mem) from serv_membresias_cab where  id_sucursal = $id_sucursal);"));
        //$pedidos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra WHERE id_cp = (select max(id_cp) from compras_pedidos_cabecera where id_sucursal = $id_sucursal);"));
    } else { //SE TRATA DE UN PEDIDO DEFINIDO
        $membresias = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_membresias_cab WHERE id_mem = $id_mem;"));
        $consolidacion = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_membresias_consolidacion WHERE  id_mem = $id_mem;"));
    }
    $membresias_detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_membresias_det WHERE id_mem = $id_mem ORDER BY ps_descrip;"));
    $inscripcionMembresias = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_inscripciones_membresias where id_mem = $id_mem ORDER BY  ps_descrip;"));
    $disabled = 'disabled';
    if ($membresias[0]['estado'] == 'PENDIENTE') {
        $disabled = '';
    }
?>
    <div class="card">
        <div class="card-body">
            <button class="btn btn-primary text-white" onclick="modalSecund();" id="btn-modal-secund-cerrar"><i class="fas fa-plus-circle"></i> Inscripciones</button>
            <button class="btn btn-primary text-white" onclick="modalConsolidacion(<?php echo $membresias[0]['id_mem']; ?>);" id="btn-modal-secund-cerrar"><i class="fas fa-table-tree"></i> Consolidacion</button>
            <button class="btn btn-danger text-white" onclick="" id="btn-modal-secund-cerrar"><i class="fas fa-regular fa-file-pdf"></i> Reportes</button>

        </div>
    </div>

    <div class="row">
        <div class="card card-primary col-12">
            <div class="card-header text-center elevation-3">
            Datos de la membresía
            </div>
            <div class="card-body">
                <input type="hidden" value="<?= $membresias[0]['id_mem'] ?>" id="id_mem">
                <input type="hidden" value="<?= $pedidos[0]['id_cp'] ?>" id="id_cp">
                <input type="hidden" value="0" id="eliminar_id_plan_servi">
                <!-- <input type="hidden" value="0" id="eliminar_id_plan_servis"> -->

                <div class="col-md-2">
                    <div class="form-group">
                        <label>Sucursal</label>
                        <input type="text" value="<?= $comprasSucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                    </div>
                </div>

                <div>
                    <label>Clientes Inscritos</label>
                    <select class="select2" id="id_cliente" disabled>
                        <option selected="true" value="<?= $membresias[0]['id_cliente']; ?>"><?= $membresias[0]['cliente'] . " " . $membresias[0]['per_ci']; ?></option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Fecha</label>
                    <input type="date" value="<?= $membresias[0]['mem_fecha'] ?>" class="form-control" id="mem_fecha">
                </div>

                <div class="form-group">
                    <label>Vencimiento</label>
                    <input type="date" value="<?= $membresias[0]['mem_vence'] ?>" class="form-control" id="mem_vence">
                </div>

                <div class="form-group">
                    <label>Observación</label>
                    <textarea type="text" class="form-control" id="mem_observacion"><?=  $membresias[0]['mem_observacion'] ?></textarea>
                </div>
                <div class="form-group">
                    <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                    <?php if ($membresias[0]['estado'] == 'PENDIENTE') { ?>
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
                Detalles de la membresía
            </div>
            <div class="card-body">
                <?php if (!empty($membresias_detalles)) { ?>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Servicio</th>
                                <th>Dias</th>
                                <th>Precio Unitario</th>
                                <th>Subtotal</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php $total = 0;
                            foreach ($membresias_detalles as $d) {
                                $total = $total + ($d['precio'] * $d['dias']) ?>
                                <tr>
                                    <td><?php echo $d['ps_descrip']; ?></td>
                                    <td><?php echo $d['dias']; ?></td>
                                    <td><?php echo $d['precio']; ?></td>
                                    <td><?php echo $d['precio'] * $d['dias']; ?></td>
                                    <td>
                                        <?php if ($membresias[0]['estado'] == 'PENDIENTE') { ?>
                                            <button class="btn btn-warning text-white" onclick="modificar_detalle(<?php echo $d['id_plan_servi']; ?>);" id="btn-panel-modificar-cerrar"><i class="fa fa-edit"></i></button>
                                            <button class="btn btn-danger" onclick="eliminar_detalle(<?php echo $d['id_plan_servi']; ?>);"><i class="fa fa-minus-circle"></i></button>
                                            <!-- <button class="btn btn-danger" onclick="eliminar_detalle(<?php //echo $d['id_plan_servi']; 
                                                                                                            ?>);"><i class="fa fa-minus-circle"></i></button> -->
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
        <?php if ($membresias[0]['estado'] == 'PENDIENTE') {
            $articulos = pg_fetch_all(pg_query($conn, "SELECT * FROM planes_servicios WHERE estado = 'ACTIVO' AND id_plan_servi NOT IN (select id_plan_servi from v_serv_membresias_det WHERE id_mem = " . $membresias[0]['id_mem'] . ") ORDER BY ps_descrip;"))
        ?>
            <!-- PARA AGREGAR PRESUPUESTO DETALLE -->
            <div class="card card-primary col-4">
                <div class="card-header text-center elevation-3">
                    Agregar Producto
                </div>

                <div class="card-body">
                    <?php if (!empty($articulos)) { ?>
                        <div class="form-group">
                            <label>Servicios</label>
                            <select class="select2" id="agregar_id_plan_servi">
                                <option selected="true" disabled>Seleccione un servicio</option>
                                <?php foreach ($articulos as $a) { ?>
                                    <option value="<?= $a['id_plan_servi']; ?>" data_precio="<?= $a['precio_servicio']; ?>"><?= $a['ps_descrip']; ?></option>
                                <?php } ?>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Dias</label>
                            <input type="number" value="<?= getFechaDays($membresias[0]['mem_fecha'], $membresias[0]['mem_vence']) ?>" class="form-control" id="agregar_dias" disabled>
                        </div>
                        <div class="form-group">
                            <label>Precio</label>
                            <input type="number" value="0" class="form-control" id="agregar_precio">
                        </div>
                        <div class="form-group">
                            <button class="btn btn-success" onclick="agregar_detalles();"><i class="fa fa-plus-circle"></i> Agregar</button>
                        </div>

                    <?php } else { ?>
                        <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se encuentran servicios disponibles...</label>
                    <?php } ?>
                </div>
            </div>
        <?php } ?>
        <!-- TABLA DE PEDIDOS CONFIRMADOS -->
        <div class="card card-success col-12">
            <div class="card-header text-center elevation-3">
                Detalles de las Inscripciones a Membresías
            </div>
            <div class="card-body">

                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>Servicio</th>
                            <th>Dias</th>
                            <th>Precio Unitario</th>
                            <th>Subtotal</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <?php if (!empty($inscripcionMembresias)) { ?>
                        <tbody>
                            <?php $total = 0;
                            foreach ($inscripcionMembresias as $d) {
                                $total = $total + ($d['precio'] * $d['dias']) ?>

                                <input type="hidden" value="<?php echo $d['id_inscrip']; ?>" id="id_inscrip">
                
                                <tr>
                                    <td><?php echo $d['ps_descrip']; ?></td>
                                    <td><?php echo $d['dias']; ?></td>
                                    <td><?php echo $d['precio']; ?></td>
                                    <td><?php echo $d['precio'] * $d['dias']; ?></td>
                                    <td>
                                        <?php if ($membresias[0]['estado'] == 'PENDIENTE') { ?>
                                            <button class="btn btn-danger" onclick="eliminar_membresia_inscripcion(<?= $d['id_plan_servi'] ?>);"><i class="fa fa-minus-circle"></i></button>
                                            <!-- <button class="btn btn-danger" onclick="eliminar_detalle(<?php //echo $d['id_item']; ?>);"><i class="fa fa-minus-circle"></i></button> -->
                                        <?php } ?>
                                    </td>
                                </tr>
                            <?php } ?>
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="3">Total</th>
                                <th><?php echo number_format($total, 0, ",", "."); ?></th>
                                <th>

                                </th>
                            </tr>
                        </tfoot>
                </table>
            <?php } else { ?>
                <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron detalles...</label>
            <?php } ?>
            </div>
        </div>

        <!-- MONTOS TOTALES DE PEDIDOS Y PRESUPUESTO -->

        <script>
            autoCompletePrecio();
        </script>
    </div>
<?php
}
