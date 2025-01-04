<?php
$id_caju = $_POST['id_caju'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();

$sucursal = pg_fetch_all(pg_query($conn, "SELECT suc_nombre FROM sucursales WHERE id_sucursal=$id_sucursal;"));
$comprasSucursal = pg_fetch_all(pg_query($conn, "SELECT suc_nombre, id_proveedor FROM v_compras_cab WHERE id_cc = (SELECT max(id_cc) FROM compras_cabecera WHERE id_sucursal = $id_sucursal);"));

if ($id_caju == '-1') { //CUANDO SE RESETEA
?>
    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> Seleccione un Ajuste</label>
<?php
} else if ($id_caju == '0') { //CUANDO SE PRESIONA EL BOTON AGREGAR
?>
    <div class="card card-primary">
        <div class="card-header text-center elevation-3">
            Datos del Ajuste
        </div>
        <div class="card-body">
            <input type="hidden" value="0" id="id_caju">

            <div class="col-md-2">
                <div class="form-group">
                    <label>Sucursal</label>
                    <input type="text" value="<?= $sucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                </div>
            </div>

            <div class="form-group">
                <label>Fecha</label>
                <input type="date" value="<?php echo date('Y-m-d'); ?>" class="form-control" id="aju_fecha" disabled>
            </div>

            <div class="form-group">
                <label>Observacón</label>
                <textarea class="form-control" id="aju_observacion"></textarea>
            </div>

            <div class="form-group">
                <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
<?php
} else { //O SE TRATA DE UN PEDIDO DEFINIDO O SE TRATA DEL ULTIMO PEDIDO
    if ($id_caju == '-2') { //SE TRATA DEL ULTIMO PEDIDO
        $cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_comp_ajustes_cab WHERE id_caju = (select max(id_caju) from comp_ajustes_cab where id_sucursal = $id_sucursal);"));
    } else { //SE TRATA DE UN PEDIDO DEFINIDO
        $cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_comp_ajustes_cab WHERE id_caju = $id_caju;"));
    }
    $detalle = pg_fetch_all(pg_query($conn, "SELECT * FROM v_comp_ajustes_det WHERE id_caju = " . $cabecera[0]['id_caju'] . " ORDER BY item_descrip, mar_descrip;"));
    $disabled = 'disabled';
    if ($cabecera[0]['estado'] == 'PENDIENTE') {
        $disabled = '';
    }
?>
    <div class="row">
        <div class="card card-primary col-12">
            <div class="card-header text-center elevation-3">
                Datos del Ajuste
            </div>
            <div class="card-body">
                <input type="hidden" value="<?php echo $cabecera[0]['id_caju']; ?>" id="id_caju">
                <input type="hidden" value="0" id="eliminar_id_item">
                <input type="hidden" value="0" id="eliminar_id_motivo">

                <div class="col-md-2">
                    <div class="form-group">
                        <label>Sucursal</label>
                        <input type="text" value="<?= $sucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                    </div>
                </div>

                <div class="form-group">
                    <label>Fecha</label>
                    <input type="date" value="<?= $cabecera[0]['aju_fecha']; ?>" class="form-control" id="aju_fecha" disabled>
                </div>

                <div class="form-group">
                    <label>Observacón</label>
                    <textarea class="form-control" id="aju_observacion"><?= $cabecera[0]['aju_observacion']; ?></textarea>
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
        <div class="card card-primary col-8">
            <div class="card-header text-center elevation-3">
                Detalles del Ajuste
            </div>
            <div class="card-body">
                <?php if (!empty($detalle)) { ?>
                    <table class="table table-bordered" style="font-size: 12px">
                        <thead>
                            <tr>
                                <th>Producto</th>
                                <th>Cant</th>
                                <th>Stock</th>
                                <th>Motivo</th>
                                <th>Tip. Ajuste</th>
                                <th>Deposito</th>
                                <th>Precio Unitario</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php $total = 0;
                            foreach ($detalle as $d) {
                                $total = $total + ($d['precio'] * $d['cantidad']) ?>
                                <tr>
                                    <td><?= $d['item_descrip'] . " - " . $d['mar_descrip']; ?></td>
                                    <td><?= $d['cantidad']; ?></td>
                                    <td><?= $d['stock_cantidad']; ?></td>
                                    <td><?= $d['mot_descrip']; ?></td>
                                    <td><?= $d['mot_tipo_ajuste']; ?></td>
                                    <td><?= $d['dep_descrip']; ?></td>
                                    <td><?= $d['precio']; ?></td>
                                    <td>
                                        <?php if ($cabecera[0]['estado'] == 'PENDIENTE') { ?>
                                            <button class="btn btn-warning text-white" onclick="modificar_detalle(<?= $d['id_caju'] ?>, <?= $d['id_item'] ?>);" id="btn-panel-modificar-cerrar"><i class="fa fa-edit"></i></button>
                                            <button class="btn btn-danger" onclick="eliminar_detalle(<?= $d['id_item'] ?>, <?= $d['id_motivo'] ?>);"><i class="fa fa-minus-circle"></i></button>
                                        <?php } ?>
                                    </td>
                                </tr>
                            <?php } ?>
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="6">Total</th>
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
        <?php if ($cabecera[0]['estado'] == 'PENDIENTE') {
            $depositos = pg_fetch_all(pg_query($conn, "
            SELECT * FROM deposito 
            WHERE estado = 'ACTIVO'"));

            $articulos = pg_fetch_all(pg_query($conn, "
                    SELECT * FROM v_stocks 
                    WHERE estado = 'ACTIVO' 
                    AND id_item NOT IN (
                        SELECT id_item 
                        FROM comp_ajustes_det 
                        WHERE id_caju = " . $cabecera[0]['id_caju'] . "
                    ) AND id_tip_item NOT IN (7)
                    ORDER BY item_descrip;
                "));

            // Convertimos los artículos a un formato JSON para usarlos en JavaScript
            $productosPorDeposito = [];
            foreach ($articulos as $a) {
                $productosPorDeposito[$a['id_sucursal']][] = [
                    'id_item' => $a['id_item'],
                    'item_descrip' => $a['item_descrip'] . " - " . $a['mar_descrip']
                ];
            }

            $tiposAjuste = pg_fetch_all(pg_query($conn, "
                                                    SELECT DISTINCT mot_tipo_ajuste
                                                    FROM motivo_ajustes
                                                    WHERE estado = 'ACTIVO';
                                                "));

            // Obtener todos los motivos
            $motivos = pg_fetch_all(pg_query($conn, "
            SELECT id_motivo, mot_descrip, mot_tipo_ajuste
            FROM motivo_ajustes
            WHERE estado = 'ACTIVO';
        "));
        ?>
            <div class="card card-primary col-4">
                <div class="card-header text-center elevation-3">
                    Agregar Producto
                </div>
                <div class="card-body">
                <input type="number" value="" class="form-control" id="agregar_id_motivo" hidden>
                    <?php if (!empty($articulos)) { ?>



                        <div class="form-group">
                            <label>Depósito</label>
                            <select class="select2" id="agregar_id_deposito" onchange="actualizarProductos()">
                                <option selected="true" disabled="disabled">Seleccione Depósito</option>
                                <?php foreach ($depositos as $a) { ?>
                                    <option value="<?= $a['id_sucursal']; ?>"><?= $a['dep_descrip']; ?></option>
                                <?php } ?>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Producto</label>
                            <select class="select2" id="agregar_id_item">
                                <option selected="true" disabled="disabled">Seleccione Producto</option>
                                <!-- Las opciones se llenarán dinámicamente con JavaScript -->
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Tipo de Ajuste</label>
                            <select class="select2" id="agregar_mot_tipo_ajuste">
                                <option selected="true">Seleccione el tipo de Ajuste</option>
                                <?php foreach ($tiposAjuste as $m) { ?>
                                    <option value="<?= $m['mot_tipo_ajuste'] ?>"><?= $m['mot_tipo_ajuste'] ?></option>
                                <?php } ?>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Motivo</label>
                            <select class="select2" id="agregar_mot_descrip" onchange="mostrarIdMotivo()">
                            <option selected="true" disabled="disabled">Seleccione Producto</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Cantidad</label>
                            <input type="number" value="" class="form-control" id="agregar_cantidad">
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
    // Convertimos la lista de productos a un objeto JSON
    const productosPorDeposito = <?php echo json_encode($productosPorDeposito); ?>;
    const motivos = <?= json_encode($motivos); ?>;

</script>