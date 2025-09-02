<?php
$id_cob = $_POST['id_cob'];
include '../../../Conexion.php';
include '../../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$datos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_cobros_det WHERE id_cob = $id_cob;"));
$entidad_emisora = pg_fetch_all(pg_query($conn, "SELECT id_ee, ee_razon_social FROM entidades_emisoras WHERE estado = 'ACTIVO';"));
?>
<div class="modal-dialog">
    <div class="modal-content">
        <div class="card card-secondary">
            <div class="card-header text-center text-white">
                Agregar Transferencia
            </div>
            <div class="card-body">
                <input type="text" class="form-control" value="<?= $id_cob ?>" id=id_cob hidden>
                <input type="text" class="form-control" value="" id=id_ctra hidden>
                <input type="text" class="form-control" value="<?= $id_cue ?>" id=id_cue hidden>
                <input type="text" class="form-control" value="<?= $id_fc ?>" id=id_fc_f hidden>
                <div class="row">

                    <div class="col-md-12">
                        <div class="form-group">
                            <label>Nro de Cuenta</label>
                            <input type="text" class="form-control" value="" id=tra_nro_cuenta>
                        </div>
                    </div>

                    <div class="col-md-12">
                        <div class="form-group">
                            <label>Fecha</label>
                            <input type="date" class="form-control" value="<?= date('Y-m-d'); ?>" id="tar_vencimiento">
                        </div>
                    </div>
                    

                    <div class="col-md-12">
                        <div class="form-group">
                            <label>Monto</label>
                            <input type="text" class="form-control" value="<?= $datos[0]['cob_monto_efe']; ?>" id="tra_monto">
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Entidades Origen</label>
                            <select class="select2" id="id_ee_ori">
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
                            <label>Entidades Destino</label>
                            <select class="select2" id="id_ee_des">
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

                    <div class="col-md-12">
                        <div class="form-group">
                            <label>Motivo</label>
                            <select class="select2" id="tra_motivo">
                                <option value="" disabled selected>Seleccione...</option>
                                <option value="PAGO DE FACTURA">PAGO DE FACTURA</option>
                                <option value="ANTICIPO A CUENTA">ANTICIPO A CUENTA</option>
                                <option value="OTRO">OTRO</option>
                            </select>
                        </div>
                    </div>
                    
                </div>

            </div>

            <div class="modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success text-white" onclick="agregar_transferencia_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>