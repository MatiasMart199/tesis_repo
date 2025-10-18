<?php
$id_cob = $_POST['id_cob'];
$id_cue = $_POST['id_cue'];
include '../../../Conexion.php';
include '../../../session.php'; 
$conexion = new Conexion();
$conn = $conexion->getConexion();
$datos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_cobros_det WHERE id_cob = $id_cob AND id_cue = $id_cue;"));
$forma_cobros = pg_fetch_all(pg_query($conn, "SELECT * FROM formas_cobros WHERE estado = 'ACTIVO';"));
?>
<div class="modal-dialog">
    <div class="modal-content">
        <div class="card card-warning">
            <div class="card-header text-center text-white">
                Agregar Forma de Pago
            </div>
            <div class="card-body">
            <input type="text" class="form-control" value="<?= $datos[0]['cue_monto']; ?>" id=monto hidden>
            <input type="text" class="form-control" value="<?= $datos[0]['id_cue']; ?>" id=id_cue hidden>

                <div class="col-md-12">
                    <div class="form-group">
                        <label>Forma de Cobro</label>
                        <select class="form-control" id="modificar_id_fc">
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
                        <label>Inporte Efectivo</label>
                        <input type="number" min="0" max="<?= $datos[0]['cue_saldo'];?>" class="form-control" value="<?= $datos[0]['cob_monto_efe'];?>" id="modificar_cob_monto_efe" class="form-control" step="1" disabled>
                        <small>Monto máximo permitido: <?= number_format($datos[0]['cue_saldo'], 0, ',', '.') ?> Gs.</small>
                    </div>
                </div>

            </div>
            <div class="modal-footer justify-content-between">
                <button class="btn btn-danger" data-dismiss="modal"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success text-white" onclick="modificar_detalle();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
</div>
    <script>
        //const forma_cobro = <?//= json_encode($forma_cobros) ?>;
    </script>
<?php pg_close($conn) ?>