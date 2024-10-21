<?php 
$id_ciudad = $_POST['id_ciudad'];
include '../../Conexion.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$ciudades = pg_fetch_all(pg_query($conn, "SELECT * FROM v_ciudades WHERE id_ciudad = $id_ciudad;"));
$paises = pg_fetch_all(pg_query($conn, "SELECT * FROM paises where estado = 'ACTIVO';"));
?>

<div class="modal-dialog">
    <div class="modal-content">
        <div class="card-warning">
            <div class="card-header text-center text-white">
            EDITAR CIUDAD
            </div >
            <div class="card-body" >
                <input type="hidden" id="editar_cod_ciudad" value="<?=  $ciudades[0]['id_ciudad'] ?>">
                <div class="form-group">
                    <label>Descripcion</label>
                    <input type="text" class="form-control" id="editar_descri" value="<?=  $ciudades[0]['ciu_descrip'] ?>">
                </div>

                <div class="form-group">
                    <label>Pais</label>
                    <select class="form-control select2" style="width: 100%;" id="editar_pais">
                    <option value="<?= $ciudades[0]['id_pais']; ?>">
                        <?= $ciudades[0]['pais_descrip'];?>
                    </option>
                        <?php foreach($paises as $p){ ?>
                            <option value="<?= $p['id_pais']; ?>"><?= $p['pais_descrip']; ?> </option>
                        <?php } ?>
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