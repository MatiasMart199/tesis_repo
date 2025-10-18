<?php 
require '../../Conexion.php';
require '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$marcas = pg_fetch_all(pg_query($conn, "SELECT * FROM marcas WHERE estado = 'ACTIVO' ORDER BY 1;"));
$categorias = pg_fetch_all(pg_query($conn, "SELECT * FROM tipos_items WHERE estado = 'ACTIVO' ORDER BY 1;"));
$impuestos = pg_fetch_all(pg_query($conn, "SELECT * FROM tipos_impuestos WHERE estado = 'ACTIVO' ORDER BY 1;"));
?>

<div class="modal-dialog">
    <div class="modal-content">
        <div class="card-success">
            <div class="card-header text-center">
                AGREGAR ITEM
            </div>
            <div class="card-body">
                <div class="form-group">
                    <label>Descripción</label>
                    <input type="text" class="form-control" id="add_item_descrip">
                </div>
                <div class="form-group">
                    <label>Precio de Conpra</label>
                    <input type="number" class="form-control" id="add_precio_compra">
                </div>
                <div class="form-group">
                    <label>Precio de Venta</label>
                    <input type="number" class="form-control" id="add_precio_venta">
                </div>
                <div class="form-group">
                    <label>Marca</label>
                    <select class="form-control select2" style="width: 100%;" id="add_id_mar">
                        <option value="0">-- Seleccione --</option>
                        <?php foreach($marcas as $m){ ?>
                            <option value="<?= $m['id_mar']; ?>"><?= $m['mar_descrip']; ?> </option>
                        <?php } ?>
                    </select>
                </div>
                <div class="form-group">
                    <label>Categoria</label>
                    <select class="form-control select2" style="width: 100%;" id="add_id_tip_item">
                        <option value="0">-- Seleccione --</option>
                        <?php foreach($categorias as $c){ ?>
                            <option value="<?= $c['id_tip_item']; ?>"><?= $c['tip_item_descrip']; ?> </option>
                        <?php } ?>
                    </select>
                </div>
                <div class="form-group">
                    <label>Tipo de Impuesto</label>
                    <select class="form-control select2" style="width: 100%;" id="add_id_tip_impuesto">
                        <option value="0">-- Seleccione --</option>
                        <?php foreach($impuestos as $i){ ?>
                            <option value="<?= $i['id_tip_impuesto']; ?>"><?= $i['tip_imp_descrip']; ?> </option>
                        <?php } ?>
                    </select>
                </div>
                <div class="form-group">
                    <label>Concepto</label>
                    <select class="form-control select2" style="width: 100%;" id="add_item_concepto">
                        <option value="0">-- Seleccione --</option>
                        <option value="PRODUCTO">PRODUCTO</option>
                        <option value="DEBITO">NOTA DE DEBITO</option>
                        <option value="CREDITO">NOTA DE CREDITO</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal" id="btn-modal-agregar-cerrar">
                    <i class="fa fa-ban"></i> Cancelar
                </button>
                <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>
<?php 
pg_close($conn);
?>