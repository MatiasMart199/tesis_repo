<?php
$id_cob = $_POST['id_cob'];
$id_cue = $_POST['id_cue'];
$id_fc = $_POST['id_fc'];
include '../../../Conexion.php';
include '../../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$datos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_cobros_det WHERE id_cob = $id_cob AND id_cue = $id_cue;"));
$entidad_emisora = pg_fetch_all(pg_query($conn, "SELECT id_ee, ee_razon_social FROM entidades_emisoras WHERE estado = 'ACTIVO';"));
?>
<div class="modal-dialog">
    <div class="modal-content">
        <div class="card card-secondary">
            <div class="card-header text-center text-white">
                Agregar Cheque
            </div>
            <div class="card-body">
                <input type="text" class="form-control" value="<?= $id_cob ?>" id=id_cob hidden>
                <input type="text" class="form-control" value="" id=id_che hidden>
                <input type="text" class="form-control" value="<?= $id_cue ?>" id=id_cue hidden>
                <input type="text" class="form-control" value="<?= $id_fc ?>" id=id_fc_f hidden>
                <div class="row">

                    <div class="col-md-12">
                        <div class="form-group">
                            <label>Vencimiento</label>
                            <input type="date" class="form-control" value="<?= date('Y-m-d'); ?>" id="che_vencimiento">
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Nro Cheque</label>
                            <input type="text" class="form-control" value="" id=che_nro_cheque>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Monto</label>
                            <input type="text" class="form-control" value="<?= $datos[0]['cob_monto_efe']; ?>" id="che_monto">
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Entidades</label>
                            <select class="form-control" id="id_ee">
                                <option value="" disabled selected>Seleccione...</option>
                                <?php if (!empty($entidad_emisora)) { ?>
                                    <?php foreach ($entidad_emisora as $e) { ?>
                                        <option value="<?= $e['id_ee']; ?>"><?= $e['ee_razon_social']; ?></option>
                                    <?php } ?>
                                <?php } else { ?>
                                    <option value="" disabled selected>No hay formas de cobro disponibles</option>
                                <?php } ?>
                            </select>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Tipo de Cheque</label>
                            <select class="form-control" id="che_tipo_cheque">
                                <option value="" disabled selected>Seleccione...</option>
                                <option value="CHEQUE COMÚN">CHEQUE COMÚN</option>
                                <option value="CHEQUE A FECHA O DIFERIDO">CHEQUE A FECHA O DIFERIDO</option>
                                <option value="CHEQUE DE GERENCIA O CHEQUE CERTIFICADO">CHEQUE DE GERENCIA O CHEQUE CERTIFICADO</option>
                                <option value="CHEQUE CRUZADO">CHEQUE CRUZADO</option>
                                <option value="CHEQUE PARA ABONO EN CUENTA">CHEQUE PARA ABONO EN CUENTA</option>
                                <option value="CHEQUE NO A LA ORDEN">CHEQUE NO A LA ORDEN</option>
                                <option value="CHEQUE AL PORTADOR">CHEQUE AL PORTADOR</option>
                            </select>
                        </div>
                    </div>
                </div>

            </div>
            <div class="modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success text-white" onclick="agregar_cheque_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>