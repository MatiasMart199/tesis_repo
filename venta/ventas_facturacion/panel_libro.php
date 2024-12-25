<?php
$id_cc = $_POST['id_cc'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();
$query = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_lib_cuent WHERE  id_cc = $id_cc;"));
?>

<div class="modal-dialog modal-lg">
    <div class="modal-content">
        <div class="card card-primary">
            <div class="card-header text-center text-white">
                LIBRO DE COMPRAS
            </div>
            <div class="card-body contenido-principal">
                <!--CONTENIDO PRINCIPAL-->

                <div class="card col-12">

                    <div class="card-body">
                        <?php if (!empty($query)) { ?>
                            <table class="table table-bordered">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Fecha</th>
                                        <th>Iva 5%</th>
                                        <th>Iva 10%</th>
                                        <th>Exenta</th>
                                        <th>Estado</th>
                                        

                                    </tr>
                                </thead>
                                <?php //if(!empty($query)){ ?>
                                <tbody>
                                    <?php 
                                
                                    foreach ($query as $d) { ?>
                                        <tr>
                                            <td><?= $d['id_cc'] ?></td>
                                            <td> <?= $d['fecha'] ?> </td>
                                            <td><?= number_format($d['lib_iva5'], 0, ",", "."); ?></td>
                                            <td><?= number_format($d['lib_iva10'], 0, ",", "."); ?> </td>
                                            <td><?= number_format($d['lib_exenta'], 0, ",", "."); ?> </td>
                                            <td><?= $d['estadolib']; ?> </td>
                                        </tr>
                                    <?php } ?>
                                </tbody>
                                
                            </table>
                        <?php } else { ?>
                            <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron
                                datos...</label>
                        <?php } pg_close($conn); ?>
                    </div>
                </div>
                <div class="modal-footer justify-content-between">
                    <button class="btn btn-danger" data-dismiss="modal" id="btn-modal-secund-cerrar">
                        <i class="fa fa-ban"></i> Cancelar</button>
                </div>
            </div>
        </div>
    </div>
</div>