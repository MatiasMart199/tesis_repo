<?php 
$id_pais = $_POST['id_pais'];
require "{$_SERVER['DOCUMENT_ROOT']}/tesis/Conexion.php";
$conexion = new Conexion();
$conn = $conexion->getConexion();
$pais = pg_fetch_all(pg_query($conn, "SELECT * FROM paises WHERE id_pais = $id_pais;"));
?>


<div class="modal-dialog">
    <div class="modal-content">
        <div class="card-warning">
            <div class="card-header text-center text-white">
            EDITAR PAIS
            </div >
            <div class="card-body" >
                <input type="hidden" id="editar_id_pais" value="<?=  $pais[0]['id_pais'] ?>">
                <div class="form-group">
                    <label>Descripcion</label>
                    <input type="text" class="form-control" id="editar_pais_descrip" value="<?=  $pais[0]['pais_descrip'] ?>">
                </div>
                <div class="form-group">
                    <label>Gentilicio</label>
                    <input type="text" class="form-control" id="editar_pais_gentilicio" value="<?=  $pais[0]['pais_gentilicio'] ?>">
                </div>
                <div class="form-group">
                    <label>Codigo</label>
                    <input type="text" class="form-control" id="editar_pais_codigo" value="<?=  $pais[0]['pais_codigo'] ?>">
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