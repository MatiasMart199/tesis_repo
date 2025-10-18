<?php 
$id_item = $_POST['id_item'];
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/Conexion.php";
$conexion = new Conexion();
$conn = $conexion->getConexion();
$item = pg_fetch_all(pg_query($conn, "SELECT * FROM v_items WHERE id_item = $id_item;"));
?>


<div class="modal-dialog">
    <div class="modal-content">
        <div class="card-warning">
            <div class="card-header text-center text-white">
            EDITAR PAIS
            </div >
            <div class="card-body" >
                <input type="hidden" id="edit_id_item" value="<?= $item[0]['id_item']; ?>">
                <div class="form-group">
                    <label>Descripción</label>
                    <input type="text" class="form-control" id="edit_item_descrip" value="<?= $item[0]['item_descrip']; ?>">
                </div>
                <div class="form-group">
                    <label>Precio de Compra</label>
                    <input type="number" class="form-control" id="edit_precio_compra" value="<?= $item[0]['precio_compra']; ?>">
                </div>
                <div class="form-group">
                    <label>Precio de Venta</label>
                    <input type="number" class="form-control" id="edit_precio_venta" value="<?= $item[0]['precio_venta']; ?>">
                </div>
                <div class="form-group">
                    <label>Marca</label>
                    <select class="form-control select2" style="width: 100%;" id="edit_id_mar">
                        <option value="<?= $item[0]['id_mar']; ?>"><?= $item[0]['mar_descrip']; ?></option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Categoria</label>
                    <select class="form-control select2" style="width: 100%;" id="edit_id_tip_item">
                        <option value="<?= $item[0]['id_tip_item']; ?>"><?= $item[0]['tip_item_descrip']; ?></option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Tipo de Impuesto</label>
                    <select class="form-control select2" style="width: 100%;" id="edit_id_tip_impuesto">
                        <option value="<?= $item[0]['id_tip_impuesto']; ?>"><?= $item[0]['tip_imp_descrip']; ?></option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Concepto</label>
                    <select class="form-control select2" style="width: 100%;" id="edit_item_concepto">
                        <option value="<?= $item[0]['item_concepto']; ?>"><?= $item[0]['item_concepto']; ?></option>
                    </select>
                </div>
            </div>
            <div class = "modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal" id="btn-modal-editar-cerrar">
                    <i class="fa fa-ban"></i> Cancelar
                </button>
                <button class="btn btn-success" onclick="editar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>

<?php 
pg_close($conn);
?>