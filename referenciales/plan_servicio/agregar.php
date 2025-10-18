<?php 
require '../../Conexion.php';
require '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$promociones = pg_fetch_all(pg_query($conn, "SELECT * FROM promociones WHERE estado = 'ACTIVO' ORDER BY 1;"));
$tipos_duracion = pg_fetch_all(pg_query($conn, "SELECT * FROM tipos_duracion WHERE estado = 'ACTIVO' ORDER BY 1;"));
?>

<div class="modal-dialog">
    <div class="modal-content">
        <div class="card-success">
            <div class="card-header text-center">
            AGREGAR PLAN DE SERVICIO
            </div >
            <div class="card-body" >

                <div class="form-group">
                    <label>Descripcion</label>
                    <input type="text" class="form-control" id="agregar_descri">
                </div>
                                <div class="form-group">
                    <label>Precio</label>
                    <input type="text" class="form-control" id="agregar_descri">
                </div>

                <div class="form-group">
                    <label>Promoción</label>
                    <select class="form-control select2" style="width: 100%;" id="agregar_id_promo">
                        <?php foreach($promociones as $p){ ?>
                            <option value="<?= $p['id_promo']; ?>"><?= $p['pro_nombre']; ?> </option>
                        <?php } ?>
                    </select>
                </div>
                <div class="form-group">
                    <label>Tipo de Duracion</label>
                    <select class="form-control select2" style="width: 100%;" id="agragar_id_td">
                        <?php foreach($tipos_duracion as $p){ ?>
                            <option value="<?= $p['id_td']; ?>"><?= $p['td_descrip']; ?> </option>
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