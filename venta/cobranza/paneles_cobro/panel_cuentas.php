<?php
$id_cob = $_POST['id_cob'];
$id_vc = $_POST['id_vc'];
include '../../../Conexion.php';
include '../../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();

$cuenta_cobrar = pg_fetch_all(pg_query($conn, "SELECT * FROM vent_cuentas_cobrar WHERE id_vc =" . $id_vc . "AND id_cue NOT IN (SELECT id_cue FROM v_vent_cobros_det WHERE id_cob =" . $id_cob . " );"));
?>
<div class="modal-dialog modal-lg">
    <div class="modal-content">
        <div class="card card-secondary">
            <div class="card-header text-center text-white">
                Cuentas Pendientes
            </div>
            <div class="card-body">
                <?php if (!empty($cuenta_cobrar)) { ?>
                    <table id="tabla_cuentas" width="100%" class="table table-bordered table-striped" style="font-size: 12px;">
                        <thead>
                            <tr>
                                <th>Nro Cuota</th>
                                <th>Fecha Intevalo</th>
                                <th>Monto</th>
                                <th>Saldo</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($cuenta_cobrar as $c) { ?>
                                <tr>
                                    <td>CUOTA <?= $c['nro_cuota'] ?></td>
                                    <td><?= $c['fecha_intervalo'] ?></td>
                                    <td><?= number_format($c['cue_monto'], 0, ",", ".") ?></td>
                                    <td><?= number_format($c['cue_saldo'], 0, ",", ".") ?></td>
                                    <td><?= $c['estado']; ?></td>
                                    <td>
                                        <button class="btn btn-success" title="Agregar" onclick="agregar_cuenta(<?= $c['id_vc'] ?>, <?= $c['id_cue'] ?>);"><i class="fa fa-plus"></i></button>
                                    </td>
                                </tr>
                            <?php } ?>
                        </tbody>
                    </table>
                <?php } else { ?>
                    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron cuentas pendientes...</label>
                <?php } ?>
            </div>
        </div>
    </div>
</div>