<?php
$id_rut = $_POST['id_rut'];
$id_act = $_POST['id_act'];
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$datos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_serv_rutinas_det WHERE id_rut = $id_rut AND id_act = $id_act;"));
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
                    <label>Tipo Ejercicio</label> 
                    <input type="text" disabled="" value="<?php echo $datos[0]['act_descrip']?>" class="form-control">
                </div>
                <div class="form-group">
                    <label>Ejercicio</label> 
                    <input type="text" disabled="" value="<?php echo $datos[0]['ejercicio']?>" class="form-control">
                </div>
                <div class="form-group">
                    <label>Series</label>
                    <input type="number" class="form-control" value="<?php echo $datos[0]['serie']; ?>" id="modificar_serie">
                </div>
                <div class="form-group">
                    <label>Repeticiones</label>
                    <input type="number" class="form-control" value="<?php echo $datos[0]['repeticion']; ?>" id="modificar_repeticion">
                </div> 
                <div class="form-group">
                    <label>Peso</label>
                    <input type="number" class="form-control" value="<?php echo $datos[0]['peso']; ?>" id="modificar_peso">
                </div> 
            </div>
            <div class="modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-warning text-white" onclick="modificar_detalle_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>