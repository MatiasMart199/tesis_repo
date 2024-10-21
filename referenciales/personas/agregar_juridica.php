<?php
require '../../Conexion.php';
require '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$ciudades = pg_fetch_all(pg_query($conn, "SELECT * FROM ciudades WHERE estado = 'ACTIVO' ORDER BY 1;"));

?>

<div class="modal-dialog">
    <div class="modal-content">
        <div class="card-success">
            <div class="card-header text-center">
                AGREGAR PERSONAS JURIDICA
            </div>
            <div class="card-body">
            <input type="hidden" values="JURIDICA" class="form-control" id="agregar_nombre">
            <input type="hidden" values="" class="form-control" id="agregar_apellido">
            <input type="hidden" values ="" class="form-control" id="agregar_ci">
            <input type="hidden" value="2003-03-03" class="form-control" id="agregar_fenaci">
            <input type="hidden" value="1" class="form-control" id="agregar_ecivil">
            <input type="hidden" value="3" class="form-control" id="agregar_genero">


                <div class="form-group">
                    <label>RUC</label>
                    <input type="text" class="form-control" id="agregar_ruc">
                </div>
                

                <div class="form-group">
                    <label>Direccion</label>
                    <input type="text" class="form-control" id="agregar_direccion">
                </div>

                <div class="form-group">
                    <label>Correo </label>
                    <input type="text" class="form-control" id="agregar_correo">
                </div>

                <div class="form-group">
                    <label>Telefono</label>
                    <input type="text" class="form-control" id="agregar_telefono ">
                </div>

                <div class="form-group">
                    <label>Ciudad</label>
                    <select class="form-control select2" style="width: 100%;" id="agregar_ciudad">
                        <?php foreach ($ciudades as $c) { ?>
                            <option value="<?= $c['id_ciudad']; ?>">
                                <?= $c['ciu_descrip']; ?>
                            </option>
                        <?php } ?>
                    </select>
                </div>

            </div>

            <div class="modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal" id="btn-modal-agregar-cerrar">
                    <i class="fa fa-ban"></i> Cancelar
                </button>
                <button class="btn btn-success" onclick="agregar_grabarJuridica();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>