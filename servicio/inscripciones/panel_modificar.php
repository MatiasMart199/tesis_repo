<?php
$id_inscrip = $_POST['id_inscrip'];
$id_plan_servi = $_POST['id_plan_servi'];
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$datos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_servicios_inscripciones_detalle WHERE id_inscrip = $id_inscrip AND id_plan_servi = $id_plan_servi;"));
?>
<div class="modal-dialog">
    <div class="modal-content">
        <div class="card card-warning">
            <div class="card-header text-center text-white">
                Modificar Dia
            </div>
            <div class="card-body">
                <div class="form-group">
                    <label>Planes</label> 
                    <input type="text" disabled="" value="<?php echo $datos[0]['ps_descrip']; ?>" class="form-control">
                    <input type="hidden" id="modificar_id_plan_servi" value="<?php echo $datos[0]['id_plan_servi']; ?>">
                </div>
                <div class="form-group">
                    <label>Dias</label>
                    <input type="number" class="form-control" value="<?php echo $datos[0]['dia']; ?>" id="modificar_dia">
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