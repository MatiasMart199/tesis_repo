<?php
$id_cliente = $_POST['id_cliente'];
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$datos = pg_fetch_all(pg_query($conn, "SELECT * FROM estados_salud WHERE estado = 'ACTIVO' AND id_es NOT IN (SELECT id_es FROM clientes_estados_salud WHERE id_cliente = $id_cliente);"));
?>
<div class="modal-dialog">
    <div class="modal-content">
        <div class="card card-success">
            <div class="card-header text-center text-white">
                Estados de Salud
            </div>
            <div class="card-body">
                <input type="hidden" id="id_cliente" value="<?= $id_cliente; ?>">
                <div class="form-group">
                    <label>Estado de Salud</label> 
                    <select id="id_es" class="select2">
                        <?php if (!empty($datos)) { 
                            foreach ($datos as $d) { ?> 
                            <option value="<?= $d['id_es']; ?>"><?= $d['es_nombre']; ?></option> 
                            <?php } 
                        }else { ?> 
                        <option selected="true" disabled>No hay datos</option> <?php } ?>
                    </select>
                </div>
            </div>
            <div class="modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-warning text-white" onclick="agregar_estado_salud();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>