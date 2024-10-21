<?php
$id_corden = $_POST['id_corden'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();
$ordenes = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_ordenes WHERE id_corden = $id_corden;"));
$consolidacion = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_orden_consolidacion WHERE  id_corden = $id_corden;"));
?>

<div class="modal-dialog modal-lg">
    <div class="modal-content">
        <div class="card card-primary">
            <div class="card-header text-center text-white">
                CONSOLIDACIÓN
            </div>
            <div class="card-body contenido-principal">
                <!--CONTENIDO PRINCIPAL-->

                <div class="card col-12">

                    <div class="card-body">
                        <?php if (!empty($consolidacion)) { ?>
                            <table class="table table-bordered">
                                <thead>
                                    <tr>
                                        <th>Producto</th>
                                        <th>Marca</th>
                                        <th>Tipo</th>
                                        <th>Precio</th>

                                    </tr>
                                </thead>
                                <?php //if(!empty($consolidacion)){ ?>
                                <tbody>
                                    <?php $total = 0;
                                    foreach ($consolidacion as $d) { ?>
                                        <tr>
                                            <td>
                                                <?php echo $d['item_descrip']; ?>
                                            </td>
                                            <td>
                                                <?php echo $d['mar_descrip']; ?>
                                            </td>
                                            <td>
                                                <?php echo $d['tip_item_descrip']; ?>
                                            </td>
                                            <td>
                                                <?php echo number_format($d['precio'], 0, ",", "."); ?>
                                            </td>


                                        </tr>
                                    <?php } ?>
                                </tbody>
                                <tfoot>
                                    <tr>
                                        <th colspan="3">Total</th>
                                        <th>
                                            <?php echo number_format($ordenes[0]['monto_total'], 0, ",", "."); ?>
                                        </th>
                                        <!-- <th>
                                
                            </th> -->
                                    </tr>
                                </tfoot>
                            </table>
                        <?php } else { ?>
                            <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron
                                datos...</label>
                        <?php } ?>
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