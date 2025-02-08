<?php
$id_cp = $_POST['id_cp'];
$id_item = $_POST['id_item'];
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$datos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra_detalles WHERE id_cp = $id_cp AND id_item = $id_item;"));
?>
<div class="modal-dialog">
    <div class="modal-content">
        <div class="card card-warning">
            <div class="card-header text-center text-white">
                Modificar Cantidad
            </div>
            <div class="card-body">
                <div class="form-group">
                    <label>Producto</label> 
                    <input type="text" disabled="" value="<?php echo $datos[0]['item_descrip']." - ".$datos[0]['mar_descrip']; ?>" class="form-control">
                    <input type="hidden" id="modificar_id_item" value="<?php echo $datos[0]['id_item']; ?>">
                </div>
                <div class="form-group">
                    <label>Cantidad</label>
                    <input type="number" class="form-control" value="<?php echo $datos[0]['cantidad']; ?>" id="modificar_cantidad">
                </div>
                <!-- <div class="form-group">
                    <label>Precio Unitario</label>
                    <input type="number" class="form-control" value="<?php //echo $datos[0]['precio']; ?>" id="modificar_precio" disabled="">
                </div> -->
            </div>
            <div class="modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-warning text-white" onclick="modificar_detalle_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>