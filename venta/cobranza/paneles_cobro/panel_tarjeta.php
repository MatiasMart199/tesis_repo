<?php
$id_cob = $_POST['id_cob'];
$id_cue = $_POST['id_cue'];
$id_fc = $_POST['id_fc'];
include '../../../Conexion.php';
include '../../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$datos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_cobros_det WHERE id_cob = $id_cob AND id_cue = $id_cue;"));
$entidad_adherida = pg_fetch_all(pg_query($conn, "SELECT * FROM v_entidades_adheridas WHERE estado = 'ACTIVO';"));
?>
<div class="modal-dialog">
    <div class="modal-content">
        <div class="card card-secondary">
            <div class="card-header text-center text-white">
                Agregar Tarjeta
            </div>
            <div class="card-body">
                <input type="text" class="form-control" value="<?= $id_cob ?>" id=id_cob hidden>
                <input type="text" class="form-control" value="" id=id_che hidden>
                <input type="text" class="form-control" value="<?= $id_cue ?>" id=id_cue hidden>
                <input type="text" class="form-control" value="<?= $id_fc ?>" id=id_fc_f hidden>
                <input type="text" class="form-control" value="0" id="id_mt" hidden>

                <div class="row">

                    <div class="col-md-12">
                        <div class="form-group">
                            <label>Vencimiento</label>
                            <input type="date" class="form-control" value="<?= date('Y-m-d'); ?>" id="tar_vencimiento">
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="form-group">
                            <label>Nro. Voucher</label>
                            <input type="text" class="form-control" value="" id="tar_nro_tarjeta">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Cod. Autorizacion</label>
                            <input type="text" class="form-control" value="" id="tar_autorizacion">
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Monto</label>
                            <input type="number" min="0" max="<?= $datos[0]['cue_saldo']; ?>" class="form-control" value="<?= $datos[0]['cue_saldo']; ?>" id="tar_monto">
                            <small>Monto máximo permitido: <?= number_format($datos[0]['cue_saldo'], 0, ',', '.') ?> Gs.</small>
                        </div>
                    </div>

                    <div class="col-md-12">
                        <div class="form-group">
                            <label>Entidades</label>
                            <select class="form-control" id="id_ee">
                                <option value="" disabled selected>Seleccione...</option>
                                <?php if (!empty($entidad_adherida)) { ?>
                                    <?php foreach ($entidad_adherida as $e) { ?>
                                        <option value="<?= $e['id_ee']; ?>"><?= $e['ee_razon_social'] . " - " . $e['mt_descrip']; ?></option>
                                    <?php } ?>
                                <?php } else { ?>
                                    <option value="" disabled selected>No hay formas de cobro disponibles</option>
                                <?php } ?>
                            </select>
                        </div>
                    </div>

                </div>

            </div>
            <div class="modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success text-white" onclick="agregar_tarjeta_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>
<script>
    let adheridas = <?= json_encode($entidad_adherida) ?>;
</script>