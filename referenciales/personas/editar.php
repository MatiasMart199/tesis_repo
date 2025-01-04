<?php
$id_persona = $_POST['id_persona'];
include '../../Conexion.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$datos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_personas WHERE id_persona = $id_persona;"));
?>

<div class="modal-dialog">
    <div class="modal-content">
        <div class="card card-warning">
            <div class="card-header text-center text-white">
                EDITAR CIUDAD
            </div>
            <div class="card-body"> <!-- Contenedor con padding -->
                <div class="form-group" hidden>
                    <label>Tipo de Persona</label>
                    <select class="form-control" id="editar_persona_fisica">
                        <option selected value="<?= $datos[0]['persona_fisica']; ?>"><?= $datos[0]['persona_fisica']; ?></option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Nombre</label>
                    <input type="text" value="<?= $datos[0]['per_nombre']; ?>" class="form-control" id="editar_nombre">
                </div>

                <div class="form-group">
                    <label>Apellido</label>
                    <input type="text" value="<?= $datos[0]['per_apellido']; ?>" class="form-control" id="editar_apellido">
                </div>

                <div class="form-group">
                    <label>RUC</label>
                    <input type="text" value="<?= $datos[0]['per_ruc']; ?>" class="form-control" id="editar_ruc">
                </div>

                <div class="form-group">
                    <label>C.I</label>
                    <input type="text" value="<?= $datos[0]['per_ci']; ?>" class="form-control" id="editar_ci">
                </div>

                <div class="form-group">
                    <label>Direccion</label>
                    <input type="text" value="<?= $datos[0]['per_direccion']; ?>" class="form-control" id="editar_direccion">
                </div>

                <div class="form-group">
                    <label>Correo </label>
                    <input type="text" value="<?= $datos[0]['per_correo']; ?>" class="form-control" id="editar_correo">
                </div>

                <div class="form-group">
                    <label>Fecha de Nacimiento</label>
                    <input type="date" value="<?= $datos[0]['per_fenaci']; ?>" class="form-control" id="editar_fenaci">
                </div>

                <div class="form-group">
                    <label>Telefono</label>
                    <input type="text" value="<?= $datos[0]['per_telefono']; ?>" class="form-control" id="editar_telefono">
                </div>

                <div class="form-group">
                    <label>Ciudad</label>
                    <select class="form-control select2" style="width: 100%;" id="editar_ciudad">
                        <option value="<?= $datos[0]['id_ciudad']; ?>"><?= $datos[0]['ciu_descrip']; ?></option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Estado civil</label>
                    <select class="form-control select2" style="width: 100%;" id="editar_ecivil">
                        <option value="<?= $datos[0]['id_ecivil']; ?>"><?= $datos[0]['ec_descrip']; ?></option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Genero</label>
                    <select class="form-control select2" style="width: 100%;" id="editar_genero">
                        <option value="<?= $datos[0]['id_genero']; ?>"><?= $datos[0]['gen_descrip']; ?></option>
                    </select>
                </div>
            </div>
            <div class="modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal" id="btn-modal-editar-cerrar">
                    <i class="fa fa-ban"></i> Cancelar
                </button>
                <button class="btn btn-success" onclick="editar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>

