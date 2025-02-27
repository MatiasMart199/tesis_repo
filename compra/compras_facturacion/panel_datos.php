<?php
$id_cc = $_POST['id_cc'];
//$id_cpre = $_POST['id_cpre'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();

$sucursal = pg_fetch_all(pg_query($conn, "SELECT suc_nombre FROM sucursales WHERE id_sucursal=$id_sucursal;"));

//$comprasSucursal = pg_fetch_all(pg_query($conn, "SELECT suc_nombre, id_proveedor FROM v_compras_cab WHERE id_cc = (SELECT max(id_cc) FROM compras_cabecera WHERE id_sucursal = $id_sucursal);"));

// Fetching the active provider for the last recorded purchase
$proveedores = pg_fetch_all(pg_query($conn, "SELECT * FROM v_proveedores WHERE estado = 'ACTIVO';"));

// Fetching a list of active providers not associated with the current purchase
$listProveedores = pg_fetch_all(pg_query($conn, "SELECT * FROM v_proveedores WHERE estado = 'ACTIVO' AND id_proveedor NOT IN (SELECT id_proveedor FROM v_compras_cab WHERE id_cc = $id_cc) ORDER BY proveedor, per_ruc;"));


// Initialize arrays to store total IVA 10%, 5%, and Exentos
// and total to pay
$totalIva10 = array(0); // Total IVA 10%
$totalIva5 = array(0); // Total IVA 5%
$totalExenta = array(0); // Total Exentos
$totalPagar = array(0); // Total to pay

$impuestos = "";
if ($id_cc == '-1') { //CUANDO SE RESETEA
?>
    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> Seleccione un presupuesto</label>
<?php
} else if ($id_cc == '0') { //CUANDO SE PRESIONA EL BOTON AGREGAR

?>

    <div class="card card-primary">
        <div class="card-header text-center elevation-3">
            Datos del presupuesto
        </div>
        <input type="hidden" value="0" id="id_cc">
        <div class="card-body">
            <div class="row">


                <div class="col-md-2">
                    <div class="form-group">
                        <label>Sucursal</label>
                        <input type="text" value="<?= $sucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                    </div>
                </div>





                <div class="col-md-4">
                    <div class="form-group">
                        <label>Proveedor</label>
                        <select class="select2" id="id_proveedor">
                            <option selected="true" disabled="disabled">SELECCIONE EL PROVEEDOR</option>
                            <?php foreach ($proveedores as $pr) { ?>
                                <option value="<?php echo $pr['id_proveedor']; ?>">
                                    <?= $pr['proveedor'] . " " . $pr['per_ruc']; ?>
                                </option>
                            <?php }; ?>
                        </select>
                    </div>
                </div>


                <div class="col-md-4">
                    <label>Fecha</label>
                    <input type="date" value="<?= date('Y-m-d') ?>" class="form-control" id="cc_fecha">
                </div>

                <div class="col-md-3">
                    <div class="form-group">
                        <label>Nro Factura</label>
                        <input type="text" value="0" class="form-control" id="cc_nro_factura">
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="form-group">
                        <label>Timbrado</label>
                        <input type="text" value="0" class="form-control" id="cc_timbrado">
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group">
                        <label>Tipo de Factura</label>
                        <select class="form-control" id="cc_tipo_factura" style="width: 100%;">
                            <option selected="true" disabled="disabled">SELECCIONE EL TIPO DE FACTURA</option>
                            <option value="CONTADO">CONTADO</option>
                            <option value="CREDITO">CRÉDITO</option>
                        </select>
                    </div>
                </div>

                <div class="col-md-1">
                    <div class="form-group">
                        <label>Intervalo</label>
                        <input type="number" value="0" class="form-control" id="cc_intervalo" disabled>
                    </div>
                </div>

                <div class="col-md-1 mb-2">
                    <div class="form-group">
                        <label>Cuota</label>
                        <input type="number" value="0" class="form-control" id="cc_cuota" disabled>
                    </div>
                </div>

                <!-- -------------------------------------------------------------------------------------------------------------- -->
                <div class="row">
                    <div class="card-body col-md-12">
                        <div class="form-group">
                            <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                            <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i>
                                Grabar</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

<?php
} else { //O SE TRATA DE UN PEDIDO DEFINIDO O SE TRATA DEL ULTIMO PEDIDO
    if ($id_cc == '-2') { //SE TRATA DEL ULTIMO PEDIDO
        $compras = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_cab WHERE id_cc = (select max(id_cc) from compras_cabecera where  id_sucursal = $id_sucursal);"));
        //$ordenes = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra WHERE id_cp = (select max(id_cp) from compras_pedidos_cabecera where id_sucursal = $id_sucursal);"));
        $proveedores;
    } else { //SE TRATA DE UN PEDIDO DEFINIDO
        $compras = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_cab WHERE id_cc = $id_cc;"));

        $impuestos = pg_fetch_all(pg_query($conn, "SELECT id_cc, totalgrav10, totaliva10, totalgrav5, totaliva5, totalexenta FROM v_cal_impuesto_compra WHERE id_cc = $id_cc;"));

        //TRAE LA VISTA DEL MOVIMIENTO CORRELACIONADO A ES MOVIMIENTO DE COMPRA
        $ordenes = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_ordenes WHERE  estado = 'CONFIRMADO';"));
        //$consolidacion = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_orden_consolidacion WHERE  id_cc = $id_cc;"));

    }
    $compras_detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_detalles WHERE id_cc = $id_cc ORDER BY item_descrip, mar_descrip;"));
    $compras_ordenes = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_orden_factu where id_cc = $id_cc ORDER BY  item_descrip, mar_descrip;"));
    $disabled = 'disabled';
    if ($compras[0]['estado'] == 'PENDIENTE') {
        $disabled = '';

        // if($compras[0]['cc_tipo_factura'] == 'CRÉDITO'){
        //     $disabled = 'disabled';
        // }
    }
    $totalIva10 = [];
    $totalIva5 = [];
    $totalExenta = [];
    $totaGrav = [];
    $totalIva = [];

    // Procesar los impuestos
    if ($impuestos) {
        foreach ($impuestos as $imp) {
            $totalIva10[] = isset($imp['totaliva10']) ? $imp['totaliva10'] : 0;
            $totalIva5[] = isset($imp['totaliva5']) ? $imp['totaliva5'] : 0;
            $totalExenta[] = isset($imp['totalexenta']) ? $imp['totalexenta'] : 0;
            $totalGrav10[] = isset($imp['totalgrav10']) ? $imp['totalgrav10'] : 0;
            $totalGrav5[] = isset($imp['totalgrav5']) ? $imp['totalgrav5'] : 0;

            // Sumar los impuestos calculados
            $totaGrav[] = end($totalGrav10) + end($totalGrav5) + end($totalExenta);
            $totalIva[] = end($totalIva10) + end($totalIva5);
        }
    }

    // Sumar totales
    $totalIva10 = array_sum($totalIva10);
    $totalIva5 = array_sum($totalIva5);
    $totalExenta = array_sum($totalExenta);
    $totalGrav = array_sum($totaGrav);
    $totalIva = array_sum($totalIva);

    //verificar si la compra tiene una orden de compra asociada
    $id_corden = isset($ordenes[0]['id_corden']) ? $ordenes[0]['id_corden'] : 0;
?>
    <div class="card">
        <div class="card-body">
            <button class="btn btn-primary text-white" onclick="modalSecund();" id="btn-modal-secund-cerrar"><i
                    class="fas fa-plus-circle"></i> Ordenes</button>
            <button class="btn btn-primary text-white"
                onclick="modalConsolidacion(<?= $compras[0]['id_cc']; ?>);" id="btn-modal-secund-cerrar"><i
                    class="fas fa fa-object-group"></i> Consolidacion</button>
            <button class="btn btn-danger text-white" onclick="generarInforme(<?= $compras[0]['id_cc']; ?>)" id="btn-modal-secund-cerrar"><i
                    class="fas fa-regular fa-file-pdf"></i> Gr. Factura</button>
            <button class="btn btn-success" onclick="modalLibro(<?= $compras[0]['id_cc']; ?>)" id="btn-modal-secund-cerrar"><i
                    class="fas fa-regular fa fa-book"></i>libro de Compras</button>
            <button class="btn btn-success" onclick="modalCuenta(<?= $compras[0]['id_cc']; ?>)" id="btn-modal-secund-cerrar"><i
                    class="fas fa-regular fa fa-book"></i>Cuenta a Pagar</button>

        </div>
    </div>

    <div class="row">
        <div class="card card-primary col-12">
            <div class="card-header text-center elevation-3">
                Datos de la Compra
            </div>
            <div class="card-body">
                <input type="number" id="total_pagar" value="<?= $totalGrav ?>" hidden>
                <input type="number" id="total_iva5" value="<?= $totalIva5 ?>" hidden>
                <input type="number" id="total_iva10" value="<?= $totalIva10 ?>" hidden>
                <input type="number" id="total_exenta" value="<?= $totalExenta ?>" hidden>

                <input type="hidden" value="<?php echo $compras[0]['id_cc']; ?>" id="id_cc">
                <input type="hidden" value="<?= $id_corden; ?>" id="id_corden">
                <input type="hidden" value="0" id="eliminar_id_item">
                <input type="hidden" value="0" id="eliminar_id_items">

                <div class="row">

                    <div class="col-md-2">
                        <div class="form-group">
                            <label>Sucursal</label>
                            <input type="text" value="<?= $sucursal[0]['suc_nombre']; ?>" class="form-control" disabled>
                        </div>
                    </div>




                    <div class="col-md-4">
                        <div class="form-group">
                            <label>Proveedor</label>
                            <select class="select2" id="id_proveedor">
                                <option disabled="disabled" <?= empty($proveedores[0]['id_proveedor']) ? 'selected' : '' ?>>Seleccione un proveedor</option>
                                <?php foreach ($listProveedores as $pr) { ?>
                                    <option value="<?php echo $pr['id_proveedor']; ?>" <?= $pr['id_proveedor'] == $proveedores[0]['id_proveedor'] ? 'selected' : '' ?>>
                                        <?= $pr['proveedor'] . " " . $pr['per_ruc']; ?>
                                    </option>
                                <?php } ?>
                            </select>
                        </div>
                    </div>


                    <div class="col-md-4 mb-4">
                        <div class="form-group">
                            <label>Fecha de Emision</label>
                            <input type="date" value="<?= $compras[0]['cc_fecha'] ?>" class="form-control" id="cc_fecha">
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="form-group">
                            <label>Nro Factura</label>
                            <input type="text" value="<?= $compras[0]['cc_nro_factura'] ?>" class="form-control" id="cc_nro_factura">
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="form-group">
                            <label>Timbrado</label>
                            <input type="text" value="<?= $compras[0]['cc_timbrado'] ?>" class="form-control" id="cc_timbrado">
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="form-group">
                            <label>Tipo de Factura</label>
                            <select class="form-control" id="cc_tipo_factura" style="width: 100%;">
                                <option disabled="disabled" <?= empty($compras[0]['cc_tipo_factura']) ? 'selected' : '' ?>>Seleccione Tipo de Factura</option>
                                <option value="CONTADO" <?= $compras[0]['cc_tipo_factura'] == 'CONTADO' ? 'selected' : '' ?>>CONTADO</option>
                                <option value="CREDITO" <?= $compras[0]['cc_tipo_factura'] == 'CREDITO' ? 'selected' : '' ?>>CRÉDITO</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="col-md-1">
                        <div class="form-group">
                            <label>Intervalo</label>
                            <input type="number" value="<?= $compras[0]['cc_intervalo'] ?>" class="form-control" id="cc_intervalo" disabled>
                        </div>
                    </div>

                    <div class="col-md-1 mb-2">
                        <div class="form-group">
                            <label>Cuota</label>
                            <input type="number" value="<?= $compras[0]['cc_cuota'] ?>" class="form-control" id="cc_cuota" disabled>
                        </div>
                    </div>
                    <!-- <fieldset>
                            <legend>Is your cat an indoor or outdoor cat?</legend>
                
                        </fieldset> -->

                </div>
                <div class="form-group">
                    <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                    <?php if ($compras[0]['estado'] == 'PENDIENTE') { ?>
                        <button class="btn btn-danger" onclick="anular();"><i class="fa fa-minus-circle"></i> Anular</button>
                        <button class="btn btn-warning text-white" onclick="modificar();"><i
                                class="fa fa-edit"></i>Modificar</button>
                        <button class="btn btn-success" onclick="confirmar();"><i
                                class="fa fa-check-circle"></i>Confirmar</button>
                    <?php } ?>
                </div>
            </div>
        </div>
        <!-- TABLA DE PRESUPUESTO -->
        <div class="card card-primary col-8">
            <div class="card-header text-center elevation-3">
                Detalles de la Compra
            </div>
            <div class="card-body">
                <?php if (!empty($compras_detalles)) { ?>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Producto</th>
                                <th>Cantidad</th>
                                <th>Stock</th>
                                <th>Precio Unitario</th>
                                <th>Subtotal</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php $total = 0;
                            foreach ($compras_detalles as $d) {
                                $total = $total + ($d['precio'] * $d['cantidad']) ?>
                                <tr>
                                    <td>
                                        <?php echo $d['item_descrip'] . " - " . $d['mar_descrip']; ?>
                                    </td>
                                    <td>
                                        <?php echo $d['cantidad']; ?>
                                    </td>
                                    <td>
                                        <?php echo $d['stock_cantidad']; ?>
                                    </td>
                                    <td>
                                        <?php echo $d['precio']; ?>
                                    </td>
                                    <td>
                                        <?php echo $d['precio'] * $d['cantidad']; ?>
                                    </td>
                                    <td>
                                        <?php if ($compras[0]['estado'] == 'PENDIENTE') { ?>
                                            <button class="btn btn-warning text-white"
                                                onclick="modificar_detalle(<?= $d['id_cc'] ?>, <?= $d['id_item'] ?>);"
                                                id="btn-panel-modificar-cerrar"><i class="fa fa-edit"></i></button>
                                            <button class="btn btn-danger" onclick="eliminar_detalle(<?php echo $d['id_item']; ?>);"><i
                                                    class="fa fa-minus-circle"></i></button>
                                            <!-- <button class="btn btn-danger" onclick="eliminar_detalle(<?php //echo $d['id_item']; 
                                                                                                            ?>);"><i class="fa fa-minus-circle"></i></button> -->
                                        <?php } ?>
                                    </td>
                                </tr>
                            <?php } ?>
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="4">Total</th>
                                <th>
                                    <?php echo number_format($total, 0, ",", "."); ?>
                                </th>
                                <th></th>
                            </tr>
                        </tfoot>
                    </table>
                <?php } else { ?>
                    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron detalles...</label>
                <?php } ?>
            </div>
        </div>
        <?php if ($compras[0]['estado'] == 'PENDIENTE') {
            $articulos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_items WHERE estado = 'ACTIVO' AND id_item NOT IN (select id_item from v_compras_detalles WHERE id_cc = " . $compras[0]['id_cc'] . ") AND id_tip_item NOT IN (7) ORDER BY item_descrip;"));
            $depositos = pg_fetch_all(pg_query($conn, "SELECT * FROM deposito WHERE estado = 'ACTIVO'"));
        ?>
            <!-- PARA AGREGAR PRESUPUESTO DETALLE -->
            <div class="card card-primary col-4">
                <div class="card-header text-center elevation-3">
                    Agregar Producto
                </div>
                <div class="card-body">
                    <?php if (!empty($articulos) && !empty($depositos)) { ?>


                        <div class="form-group">
                            <label>Depositos</label>
                            <select class="select2" id="ag_id_deposito">
                                <!-- <option selected="true" disabled="disabled"></option> -->

                                <?php foreach ($depositos as $pr) { ?>
                                    <option value="<?= $pr['id_sucursal']; ?>">
                                        <?= $pr['dep_descrip']; ?>
                                    </option>
                                <?php }; ?>
                            </select>
                        </div>


                        <div class="form-group">
                            <label>Producto</label>
                            <select class="select2" id="agregar_id_item">
                                <?php foreach ($articulos as $a) { ?>
                                    <option value="<?php echo $a['id_item']; ?>">
                                        <?php echo $a['item_descrip'] . " - " . $a['mar_descrip']; ?>
                                    </option>
                                <?php } ?>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Cantidad</label>
                            <input type="number" value="1" class="form-control" id="agregar_cantidad">
                        </div>

                        <div class="form-group">
                            <label>Precio</label>
                            <input type="number" value="" class="form-control" id="agregar_precio">
                        </div>

                        <!-- <input type="number" value="1" id="id_deposito" hidden> -->

                        <div class="form-group">
                            <button class="btn btn-success" onclick="agregar_detalles();"><i class="fa fa-plus-circle"></i>
                                Agregar</button>
                        </div>

                    <?php } else { ?>
                        <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se encuentran productos
                            disponibles...</label>
                    <?php } ?>
                </div>
            </div>
        <?php } ?>
        <!-- TABLA DE PEDIDOS CONFIRMADOS -->
        <div class="card card-success col-12">
            <div class="card-header text-center elevation-3">
                Detalles de Ordenes a Compras
            </div>
            <div class="card-body">

                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>Producto</th>
                            <th>Cantidad</th>
                            <th>Stock</th>
                            <th>Precio Unitario</th>
                            <th>Subtotal</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <?php if (!empty($compras_ordenes)) { ?>
                        <tbody>
                            <?php $total = 0;
                            foreach ($compras_ordenes as $d) {
                                $total = $total + ($d['precio'] * $d['cantidad']) ?>
                                <input type="hidden" value="<?php echo $d['id_corden']; ?>" id="id_cped_item">
                                <tr>
                                    <td>
                                        <?php echo $d['item_descrip'] . " - " . $d['mar_descrip']; ?>
                                    </td>
                                    <td>
                                        <?php echo $d['cantidad']; ?>
                                    </td>
                                    <td>
                                        <?php echo $d['stock_cantidad']; ?>
                                    </td>
                                    <td>
                                        <?php echo $d['precio']; ?>
                                    </td>
                                    <td>
                                        <?php echo $d['precio'] * $d['cantidad']; ?>
                                    </td>
                                    <td>
                                        <?php if ($compras[0]['estado'] == 'PENDIENTE') { ?>
                                            <button class="btn btn-warning text-white"
                                                onclick="modificar_detalle_ord(<?= $d['id_cc'] ?>, <?= $d['id_item'] ?>);"
                                                id="btn-panel-modificar-cerrar"><i class="fa fa-edit"></i></button>
                                            <button class="btn btn-danger"
                                                onclick="eliminar_presupuesto_pedido(<?php echo $d['id_item']; ?>);"><i
                                                    class="fa fa-minus-circle"></i></button>
                                            <!-- <button class="btn btn-danger" onclick="eliminar_detalle(<?php //echo $d['id_item']; 
                                                                                                            ?>);"><i class="fa fa-minus-circle"></i></button> -->
                                        <?php } ?>
                                    </td>
                                </tr>
                            <?php } ?>
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="4">Total</th>
                                <th>
                                    <?php echo number_format($total, 0, ",", "."); ?>
                                </th>
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


    </div>
<?php

}
?>
<script>
    validarTipoFactura();
    const artuculos = JSON.parse('<?php echo json_encode($articulos); ?>');
</script>