<?php
$id_cc = $_POST['id_cc'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();
$consultasCab = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_cab WHERE id_cc = $id_cc;"));
$consolidacion = pg_fetch_all(pg_query($conn, "SELECT * FROM v_compras_consolidacion WHERE  id_cc = $id_cc;"));
?>
conponents
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
                                        <th>Cant</th>
                                        <th>Producto</th>
                                        <!-- <th>Marca</th>
                                        <th>Tipo</th> -->
                                        <th>Precio</th>
                                        <th>Exenta</th>
                                        <th>Gravada 5%</th>
                                        <th>Gravada 10%</th>
                                        

                                    </tr>
                                </thead>
                                <?php //if(!empty($consolidacion)){ ?>
                                <tbody>
                                    <?php 
                                    

                                    // $total = 0;
                                    // $subTotal = $d['precio']*$d['stock_cantidad'];
                                    // $grav5= $precio + $consolidacion['0']['tasa1'];
                                    // $grav10= $precio + $consolidacion['0']['tasa2'];
                                    

                                    $totalExenta= 0;
                                    $totalGrav5= 0;
                                    $totalGrav10= 0;
                                    foreach ($consolidacion as $d) { 
                                    $tasaImpuesto[] = $d['tasa1'];
                                    //$iva10[] = $d['tasa2'];

                                    $totalImpuest = $d['precio'] + $d['tasa1'];
                                    //$totalGrav10= $d['precio'] + $d['tasa2'];

                                    $divIva5 = $totalGrav5 / 21;
                                    //$divIva10 = $totalGrav10 / 11;

                                    $grav5 = $totalGrav5 * $d['stock_cantidad'];
                                    $grav10 = $totalGrav10 * $d['stock_cantidad'];
                                    $exento= 0; //$subTotal + $consolidacion['0']['tasa1'];

                                    $gravArray5[]= $grav5;
                                    $gravArray10[]= $grav10;

                                    ?>
                                        <tr>
                                            <td><?= $d['stock_cantidad'] ?></td>
                                            <td> <?= $d['item_descrip'] . " - " . $d['mar_descrip'] . " - " . $d['tip_item_descrip']; ?> </td>
                                            <!-- <td> <?php //echo $d['mar_descrip']; ?> </td> -->
                                            <!-- <td> <?php //echo $d['tip_item_descrip']; ?> </td> -->
                                            <td> <?= number_format($d['precio'], 0, ",", "."); ?> </td>
                                            <td><?= number_format($exento, 0, ",", ".");?></td>
                                            <td><?= number_format($grav5, 0, ",", ".");?></td>
                                            <td><?= number_format($grav10, 0, ",", ".");?></td>


                                        </tr>
                                    <?php }

                                    // Sum all the values in the array
                                    $totalGrav5= array_sum($gravArray5);
                                    $totalGrav10= array_sum($gravArray10);

                                    $divIva5 = $totalGrav5 / 21;
                                    $divIva10 = $totalGrav10 / 11;
                                    $totalDiv = $divIva5 + $divIva10;

                                    

                                    // Sum all the values in the array
                                    // $iva5 and $iva10 contain all the values of the taxes
                                    // The total IVA is the sum of the two taxes
                                    // plus the total exempt
                                    $iva5= array_sum($iva5);
                                    $iva10= array_sum($iva10);

                                    /**
                                     * Calculate the total to pay
                                     * The total to pay is the sum of the two taxes
                                     * plus the total exempt
                                     */
                                    $totalIva = $iva5 + $iva10;

                                    // Calculate the total to pay
                                    // The total to pay is the sum of the two taxes
                                    // plus the total exempt
                                    $totalPagar= $consultasCab['0']['monto_total'] + $totalDiv + $totalExenta;

                                    

                                    ?>
                                </tbody>
                                <tfoot>
                                    <tr>
                                        <th colspan="2">Sub Total</th>
                                        <th><?= number_format($consultasCab['0']['monto_total'], 0, ",", "."); ?> </th>
                                        <th><?= number_format($totalExenta, 0, ",", "."); ?> </th>
                                        <th><?= number_format($totalGrav5, 0, ",", "."); ?> </th>
                                        <th><?= number_format($totalGrav10, 0, ",", "."); ?> </th>
                                    
                                    </tr>
                                    <tr>
                                        <th colspan="3">Liquidacion de IVA</th>

                                        <th><?= number_format($totalExenta, 0, ",", ".") ?></th>
                                        <th><?= number_format($iva5, 0, ",", ".") ?></th>
                                        <th><?= number_format($iva10, 0, ",", ".") ?></th>
                                    </tr>
                                    <tr class="bg-orange">
                                        <th colspan="5">Total IVA:</th>
                                        <th><?= number_format($totalIva, 0, ",", ".")?></th>
                                    </tr>
                                    <tr class="bg-red">
                                        <th colspan="5">Total a pagar:</th>
                                        <th><?= number_format($totalPagar, 0, ",", ".") ?></th>
                                    </tr>
                                </tfoot>
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