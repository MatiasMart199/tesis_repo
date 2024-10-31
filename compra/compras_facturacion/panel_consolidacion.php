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

                                    $totalGrav5 = 0;
                                    $totalGrav10 = 0;
                                    $totalExenta= 0;
                                    $totalIva5 = 0;
                                    $totalIva10 = 0;
                                    $sumaGrav10[] = 0;
                                    $sumaGrav5[] = 0;
                                    $sumaExenta[] = 0;
                                    $sumaIva[] = 0;
                                    foreach ($consolidacion as $d) { 
                                        $precioUnitario = $d['precio'];
                                        $cantidad = $d['stock_cantidad'];
                                        $precioTotal = $precioUnitario * $cantidad;
                                        $iva = $d['id_tip_impuesto'];

                                        $sumaTotal[] = $precioTotal;
                                        
                                        
                                        
                                        

                                            if($iva == 2){
                                            $totalGrav10 = $precioTotal;
                                            $totalIva10 = $precioTotal / 11;
                                            $sumaGrav10[] = $totalGrav5 + $totalGrav10 + $totalExenta;

                                            } elseif($iva == 1){
                                            $totalGrav5 = $precioTotal;
                                            $totalIva5 = $precioTotal / 21;
                                            $sumaGrav5[] = $totalGrav5 + $totalGrav10 + $totalExenta;

                                            } else {
                                                $totalExenta = $precioTotal;
                                                $sumaExenta[] = $totalGrav5 + $totalGrav10 + $totalExenta;
                                            }    
                                    
                                        $sumaIva5[] = $totalIva5;
                                        $sumaIva10[] = $totalIva10;
                                        $sumaIva[] = $totalIva5 + $totalIva10;
                                        $sumaGrav[] = $totalGrav5 + $totalGrav10 + $totalExenta;
                                    
                                    ?>
                                        <tr>
                                            <td><?= $cantidad ?></td>
                                            <td> <?= $d['item_descrip'] . " - " . $d['mar_descrip'] . " - " . $d['tip_item_descrip']; ?> </td>
                                            <!-- <td> <?php //echo $d['mar_descrip']; ?> </td> -->
                                            <!-- <td> <?php //echo $d['tip_item_descrip']; ?> </td> -->
                                            <td> <?= number_format($precioUnitario, 0, ",", "."); ?> </td>
                                            <td><?= number_format($totalExenta, 0, ",", ".");?></td>
                                            <td><?= number_format($totalGrav5, 0, ",", ".");?></td>
                                            <td><?= number_format($totalGrav10, 0, ",", ".");?></td>


                                        </tr>
                                    <?php }
                                    $subTotal = array_sum($sumaTotal);
                                    $totalExenta = array_sum($sumaExenta);
                                    $totalGrav5 = array_sum($sumaGrav5);
                                    $totalGrav10 = array_sum($sumaGrav10);
                                    $totalIva5 = array_sum($sumaIva5);
                                    $totalIva10 = array_sum($sumaIva10);
                                    $totalIva = array_sum($sumaIva);
                                    $totalPagar = array_sum($sumaGrav);
                                    ?>
                                </tbody>
                                <tfoot>
                                    <tr>
                                        <th colspan="3">Sub Total</th>
                                        <!-- <th><? //number_format($subTotal, 0, ",", "."); ?> </th> -->
                                        <th><?= number_format($totalExenta, 0, ",", "."); ?> </th>
                                        <th><?= number_format($totalGrav5, 0, ",", "."); ?> </th>
                                        <th><?= number_format($totalGrav10, 0, ",", "."); ?> </th>
                                    
                                    </tr>
                                    <tr>
                                        <th colspan="3">Liquidacion de IVA</th>

                                        <th><?= number_format($totalExenta, 0, ",", ".") ?></th>
                                        <th><?= number_format($totalIva5, 0, ",", ".") ?></th>
                                        <th><?= number_format($totalIva10, 0, ",", ".") ?></th>
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
                        <?php } 
                        
                        pg_close($conn); ?>
                    </div>
                </div>
                <div class="modal-footer justify-content-between">
                    <button class="btn btn-danger" data-dismiss="modal" id="btn-modal-secund-cerrar">
                        <i class="fa fa-ban"></i> Cancelar
                    </button>
                </div>
                <input type="number" name="total_pagar" id="total_pagar" value="<?= $totalPagar ?>" hidden="">
                <input type="number" name="total_iva5" id="total_iva5" value="<?= $totalIva5 ?>" hidden="">
                <input type="number" name="total_iva10" id="total_iva10" value="<?= $totalIva10 ?>" hidden="">
                <input type="number" name="total_exenta" id="total_exenta" value="<?= $totalExenta ?>" hidden="">
                <input type="date" name="fecha_cuenta" id="fecha_cuenta" value="<?= date('Y-m-d'); ?>"   hidden="">
            </div>
        </div>
    </div>
</div>