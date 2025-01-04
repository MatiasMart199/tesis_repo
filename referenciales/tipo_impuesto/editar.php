<?php 
$id_tip_impuesto = $_POST['id_tip_impuesto'];
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/Conexion.php";
$conexion = new Conexion();
$conn = $conexion->getConexion();
$pais = pg_fetch_all(pg_query($conn, "SELECT * FROM tipos_impuestos WHERE id_tip_impuesto = $id_tip_impuesto;"));
?>


<div class="modal-dialog">
    <div class="modal-content">
        <div class="card-warning">
            <div class="card-header text-center text-white">
            EDITAR TIPO DE IMPUESTO
            </div >
            <div class="card-body" >
                <input type="hidden" id="editar_id_tip_impuesto" value="<?=  $pais[0]['id_tip_impuesto'] ?>">
                <div class="form-group">
                    <label>Descripcion</label>
                    <input type="text" class="form-control" id="editar_tip_imp_descrip" value="<?=  $pais[0]['tip_imp_descrip'] ?>">
                </div>
                <div class="form-group">
                    <label>Tasa 1</label>
                    <input type="text" class="form-control" id="editar_tip_imp_tasa" value="<?=  $pais[0]['tip_imp_tasa'] ?>">
                </div>
                <div class="form-group">
                    <label>Tasa 2</label>
                    <input type="text" class="form-control" id="editar_tip_imp_tasa2" value="<?=  $pais[0]['tip_imp_tasa2'] ?>">
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
