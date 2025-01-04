<?php
$id_pre = $_POST['id_pre'];
$id_act = $_POST['id_act'];
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$datos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_presupuestos_det WHERE id_pre = $id_pre AND id_act = $id_act;"));
?>
<div class="modal-dialog">
    <div class="modal-content">
        <div class="card card-warning">
            <div class="card-header text-center text-white">
                Modificar Detalles
            </div>
            <div class="card-body">
                <input type="text" hidden value="<?php echo $id_act; ?>" id="id_act">
                <div class="form-group">
                    <label>Tipo de Presupuesto</label> 
                    <input type="text" disabled="" value="<?php echo $datos[0]['act_descrip']?>" class="form-control">
                </div>
                <div class="form-group">
                    <label>Descripción</label> 
                    <input type="text" disabled="" value="<?php echo $datos[0]['descrip']?>" class="form-control">
                </div>
                <div class="form-group">
                    <label>Costo Estimado</label>
                    <input type="number" class="form-control" value="<?php echo $datos[0]['costo']; ?>" id="modificar_costo">
                </div>
            </div>
            <div class="modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-warning text-white" onclick="modificar_detalle_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>