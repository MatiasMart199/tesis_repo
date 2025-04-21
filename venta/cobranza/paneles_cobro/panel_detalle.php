<?php
$id_vc = $_POST['id_vc'];
$id_cue = $_POST['id_cue'];
include '../../../Conexion.php';
include '../../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$datos = pg_fetch_all(pg_query($conn, "SELECT * FROM vent_cuentas_cobrar WHERE id_vc = $id_vc AND id_cue = $id_cue;"));
$forma_cobros = pg_fetch_all(pg_query($conn, "SELECT * FROM formas_cobros WHERE estado = 'ACTIVO';"));
?>
<div class="modal-dialog">
    <div class="modal-content">
        <div class="card card-success">
            <div class="card-header text-center text-white">
                Agregar Detalle
            </div>
            <div class="card-body">
            <input type="text" class="form-control" value="<?= $datos[0]['cue_monto']; ?>" id=monto hidden>
            <input type="text" class="form-control" value="<?= $datos[0]['id_cue']; ?>" id=id_cue hidden>
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Monto</label>
                            <input type="text" class="form-control" value="<?= number_format($datos[0]['cue_monto'], 0, ",", "."); ?>" disabled>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Saldo</label>
                            <input type="text" class="form-control" value="<?= number_format($datos[0]['cue_saldo'], 0, ",", "."); ?>" disabled>
                        </div>
                    </div>
                </div>

                <div class="col-md-12">
                    <div class="form-group">
                        <label>Forma de Cobro</label>
                        <select class="form-control" id="id_fc">
                            <option value="" disabled selected>Seleccione...</option>
                            <?php if (!empty($forma_cobros)){ ?>
                                <?php foreach ($forma_cobros as $forma_cobro) { ?>
                                    <option value="<?= $forma_cobro['id_fc']; ?>"><?= $forma_cobro['fc_descrip']; ?></option>
                                <?php } ?>
                            <?php } else { ?>
                                <option value="" disabled selected>No hay formas de cobro disponibles</option>
                            <?php } ?>
                        </select>
                    </div>
                </div>

                <div class="col-md-12">
                    <div class="form-group">
                        <label>Monto en Efectivo</label>
                        <input type="number" class="form-control" value="0" id="cob_monto_efe">
                    </div>
                </div>

            </div>
            <div class="modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success text-white" onclick="agregar_detalle_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>