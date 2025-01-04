<?php
require '../../Conexion.php';
require '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$ciudades = pg_fetch_all(pg_query($conn, "SELECT * FROM ciudades WHERE estado = 'ACTIVO' ORDER BY 1;"));
$estado_civiles = pg_fetch_all(pg_query($conn, "SELECT * FROM estado_civiles WHERE estado = 'ACTIVO' ORDER BY 1;"));
$generos = pg_fetch_all(pg_query($conn, "SELECT * FROM generos WHERE estado = 'ACTIVO' ORDER BY 1;"));
?>

<div class="modal-dialog">
    <div class="modal-content">
        <div class="card-success">
            <div class="card-header text-center">
                AGREGAR PERSONAS FISICA
            </div>
            <div class="card-body">
                <div class="form-group">
                    <label>Tipo de Persona</label>
                    <select class="form-control" id="persona_fisica">
                        <option selected value="true">FISICA</option>
                        <option value="false">JURIDICA</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Nombre</label>
                    <input type="text" class="form-control" id="agregar_nombre">
                </div>

                <div class="form-group">
                    <label>Apellido</label>
                    <input type="text" class="form-control" id="agregar_apellido">
                </div>

                <div class="form-group">
                    <label>RUC</label>
                    <input type="text" class="form-control" id="agregar_ruc">
                </div>
                <div class="form-group">
                    <label>C.I</label>
                    <input type="text" class="form-control" id="agregar_ci">
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
                    <label>Fecha de Nacimiento</label>
                    <input type="date" value="<?php echo date('Y-m-d'); ?>" class="form-control" id="agregar_fenaci">
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

                <div class="form-group">
                    <label>Estado civil</label>
                    <select class="form-control select2" style="width: 100%;" id="agregar_ecivil">
                        <?php foreach ($estado_civiles as $e) { ?>
                            <option value="<?= $e['id_ecivil']; ?>">
                                <?= $e['ec_descrip']; ?>
                            </option>
                        <?php } ?>
                    </select>
                </div>

                <div class="form-group">
                    <label>Genero</label>
                    <select class="form-control select2" style="width: 100%;" id="agregar_genero">
                        <?php foreach ($generos as $g) { ?>
                            <option value="<?= $g['id_genero']; ?>">
                                <?= $g['gen_descrip']; ?>
                            </option>
                        <?php } ?>
                    </select>
                </div>

            </div>

            <div class="modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal" id="btn-modal-agregar-cerrar">
                    <i class="fa fa-ban"></i> Cancelar
                </button>
                <button class="btn btn-success" onclick="agregar_grabarFisica();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>

<?php pg_close($conn) ?>