<?php
$id_not = $_POST['id_not'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();

$sucursal = pg_fetch_all(pg_query($conn, "SELECT suc_nombre FROM sucursales WHERE id_sucursal=$id_sucursal;"));

$compras = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_cab 
                                                    WHERE estado = 'CONFIRMADO';"));


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
            <div class="col-md-2">
                <div class="form-group">
                    <label>Sucursal</label>
                    <input type="text" value="<?= $sucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                </div>
            </div>
            <div class="form-group">
                <label>Fecha</label>
                <input type="date" value="<?php echo date('Y-m-d'); ?>" class="form-control" id="not_fecha" disabled>
            </div>

            <div class="form-group">
                <label>Tipo de Nota</label>
                <select class="select2" id="not_tipo_nota">
                    <option value="CREDITO">CRÉDITO</option>
                    <option value="DEBITO">DEBITO</option>
                </select>
            </div>

            <div class="form-group">
                <label>Nro. Factura</label>
                <select class="select2" id="id_cc" onchange="autollenar()">
                    <option selected="true" disabled="disabled">Seleccione Factura</option>
                    <?php foreach ($compras as $a) { ?>
                        <option value="<?php echo $a['id_cc']; ?>"><?= $a['cc_nro_factura']; ?></option>
                    <?php } ?>
                </select>
            </div>

            <div class="form-group">
                <label>Fecha del Documento</label>
                <input type="date" value="" class="form-control" id="not_fecha_docu" disabled>
            </div>

            <div class="form-group">
                <label>Proveedor</label>
                <select class="select2" id="id_proveedor" disabled>
                    <option value="" disabled="disabled">Seleccione Proveedor</option>
                </select>
            </div>


            <div class="form-group">
                <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
    <script>
        autollenar();
    </script>
<?php
} else { //O SE TRATA DE UN PEDIDO DEFINIDO O SE TRATA DEL ULTIMO PEDIDO
    if ($id_not == '-2') { //SE TRATA DEL ULTIMO PEDIDO
        $cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_comp_nota_cab WHERE id_not = (select max(id_not) from comp_nota_cab where id_sucursal = $id_sucursal);"));
    } else { //SE TRATA DE UN PEDIDO DEFINIDO
        $cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_comp_nota_cab WHERE id_not = $id_not;"));
    }
    $detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_comp_nota_det WHERE id_not = " . $cabecera[0]['id_not'] . " ORDER BY id_item, item_descrip, mar_descrip ASC;"));
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
                <input type="hidden" value="<?php echo $cabecera[0]['id_not']; ?>" id="id_not">
                <input type="hidden" value="0" id="eliminar_id_item">

                <div class="col-md-2">
                    <div class="form-group">
                        <label>Sucursal</label>
                        <input type="text" value="<?= $sucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                    </div>
                </div>
                <div class="form-group">
                    <label>Fecha</label>
                    <input type="date" value="<?= $cabecera[0]['not_fecha']; ?>" class="form-control" id="not_fecha" disabled>
                </div>

                <div class="form-group">
                    <label>Tipo de Nota</label>
                    <select class="select2" id="not_tipo_nota">
                        <option value="<?= $cabecera[0]['not_tipo_nota']; ?>" selected="true" disabled="disabled"><?= $cabecera[0]['not_tipo_nota']; ?></option>
                        <option value="CREDITO">CRÉDITO</option>
                        <option value="DEBITO">DEBITO</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Nro. Factura</label>
                    <select class="select2" id="id_cc" disabled>
                        <option selected="true" value="<?= $cabecera[0]['id_cc']; ?>"><?= $cabecera[0]['cc_nro_factura']; ?></option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Fecha del Documento</label>
                    <input type="date" value="<?= $cabecera[0]['not_fecha_docu']; ?>" class="form-control" id="not_fecha_docu" disabled>
                </div>

                <div class="form-group">
                    <label>Proveedor</label>
                    <select class="select2" id="id_proveedor" disabled>
                        <option value="<?= $cabecera[0]['id_proveedor']; ?>"><?= $cabecera[0]['proveedor']; ?></option>
                    </select>
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
                Detalles de la Nota
            </div>

            <?php


            ?>
            <div class="card-body">
                <?php if (!empty($detalles)) { ?>
                    <table class="table table-bordered" style="font-size: 12px;">
                        <thead>
                            <tr>
                                <th>Producto</th>
                                <th>Cant</th>
                                <th>P.Unit</th>
                                <th>Monto</th>
                                <th>SubTotal</th>
                                <th>Exenta</th>
                                <th>Iva 5%</th>
                                <th>Iva 10%</th>
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

                                $precioTotal = $d['precio'] * $d['cantidad'];
                                $iva = $d['id_tip_impuesto'];
                                $monto = 0;

                                if ($cabecera[0]['not_tipo_nota'] == 'CREDITO') {
                                    $total -= $d['monto'];
                                } else {
                                    $total += $d['monto'];
                                }
                            ?>
                                <tr>
                                    <td><?= $d['mar_descrip'] . ": " . $d['item_descrip']; ?></td>
                                    <td><?= $d['cantidad']; ?></td>
                                    <td><?= number_format($d['precio'], 0, ",", ".") ?></td>
                                    <td><?= number_format($d['monto'], 0, ",", ".") ?></td>
                                    <td><?= number_format($precioTotal, 0, ",", ".") ?></td>
                                    <td><?= ($iva == 3) ? number_format($d['totalexenta'], 0, ",", ".") : '0'; ?></td>
                                    <td><?= ($iva == 1) ? number_format($d['totaliva5'], 0, ",", ".") : '0'; ?></td>
                                    <td><?= ($iva == 2) ? number_format($d['totaliva10'], 0, ",", ".") : '0'; ?></td>
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
                                <th colspan="6">Total Iva</th>
                                <th><?php
                                    echo number_format($sumaIva, 0, ",", "."); ?></th>
                                <th></th>
                            </tr>
                            <tr>
                                <th colspan="7">Total</th>
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
            $articulos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_items WHERE estado = 'ACTIVO' AND id_item NOT IN (select id_item from comp_nota_det WHERE id_not = " . $cabecera[0]['id_not'] . ") AND id_tip_item = 7 ORDER BY item_descrip;"))
        ?>
            <div class="card card-primary col-4">
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
                            <input type="number" value="" class="form-control" id="agregar_cantidad">
                        </div>

                        <div class="form-group">
                            <label>Monto</label>
                            <input type="number" value="" class="form-control" id="agregar_monto">
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
    const datosCompras = <?= json_encode($compras); ?>;
</script>
<?php pg_close($conn); ?>