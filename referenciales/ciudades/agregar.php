<?php 
require '../../Conexion.php';
require '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$paises = pg_fetch_all(pg_query($conn, "SELECT * FROM paises WHERE estado = 'ACTIVO' ORDER BY 1;"));
?>

<div class="modal-dialog">
    <div class="modal-content">
        <div class="card-success">
            <div class="card-header text-center">
            AGREGAR CIUDADES
            </div >
            <div class="card-body" >

                <div class="form-group">
                    <label>Descripcion</label>
                    <input type="text" class="form-control" id="agregar_descri">
                </div>

                <div class="form-group">
                    <label>Paises</label>
                    <select class="form-control select2" style="width: 100%;" id="agregar_pais">
                        <?php foreach($paises as $p){ ?>
                            <option value="<?= $p['id_pais']; ?>"><?= $p['pais_descrip']; ?> </option>
                        <?php } ?>
                    </select>
                </div>

            </div>
            
            <div class = "modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal" id="btn-modal-agregar-cerrar">
                    <i class="fa fa-ban"></i> Cancelar
                </button>
                <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>