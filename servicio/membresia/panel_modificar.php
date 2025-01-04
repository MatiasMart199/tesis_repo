<?php
$id_mem = $_POST['id_mem'];
$id_plan_servi = $_POST['id_plan_servi'];
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$datos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_membresias_det WHERE id_mem = $id_mem AND id_plan_servi = $id_plan_servi;"));
?>
<div class="modal-dialog">
    <div class="modal-content">
        <div class="card card-warning">
            <div class="card-header text-center text-white">
                Modificar Cantidad
            </div>
            <div class="card-body">
            <div class="form-group">
                    <label>Planes</label> 
                    <input type="text" disabled="" value="<?php echo $datos[0]['ps_descrip']; ?>" class="form-control">
                    <input type="hidden" id="modificar_id_plan_servi" value="<?php echo $datos[0]['id_plan_servi']; ?>">
                </div>
                <div class="form-group">
                    <label>Dias</label>
                    <input type="number" class="form-control" value="<?php echo $datos[0]['dias']; ?>" id="modificar_dias">
                </div>
                <!-- <div class="form-group">
                    <label>Precio</label>
                    <input type="number" class="form-control" disabled value="<?php //echo $datos[0]['precio']; ?>" id="modificar_precio">
                </div>  -->
            </div>
            <div class="modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-warning text-white" onclick="modificar_detalle_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>