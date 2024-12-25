<?php
//$id_cpre = $_POST['id_cp'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();
$pedidos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra WHERE  estado = 'CONFIRMADO' order by id_cp;"));
?>

<div class="modal-dialog modal-lg">
    <div class="modal-content">
        <div class="card card-primary">
            <div class="card-header text-center text-white">
                PEDIDOS CONFIRMADOS
            </div>
            <div class="card-body contenido-principal">
                <!--CONTENIDO PRINCIPAL-->

                <?php
                // Supongamos que tienes un array de tablas llamado $tablas con datos de las tablas
                // Puedes iterar sobre ellas para generar las tablas en HTML
                echo '<div class="card card-success col-12">';

                echo '<div class="card-body">';

                foreach ($pedidos as $pedido) {
                    echo '<div class="custom-container">';
                    echo '<label class="custom-container__label">#' . $pedido['id_cp'] . ' Nº-----( ' . $pedido['fecha'] . ' )</label>';
                    echo '<button class="btn btn-success" onclick="agregar_presupuesto_pedido(' . $pedido['id_cp'] . ');"><i class="fa fa-plus-circle"></i> Agregar</button>';
                    echo '</div>';

                    // Construye la fila de encabezado de la tabla una sola vez
                    $pedidos_detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra_detalles WHERE id_cp = " . $pedido['id_cp'] . " ORDER BY precio ASC;"));

                    echo '<input type="hidden" value="' . $pedido['id_cp'] . '" id="id_cp">';
                    echo '<table class="table table-bordered">';
                    if (!empty($pedidos_detalles)) {
                        echo '<thead>';
                        echo '<tr>';
                        echo '<th>Producto</th>';
                        echo '<th>Cantidad</th>';
                        echo '<th>Precio Unitario</th>';
                        echo '<th>Subtotal</th>';
                        //echo '<th>Acciones</th>';
                        echo '</tr>';
                        echo '</thead>';

                        
                        echo '<tbody>';
                        $total = 0;
                        foreach ($pedidos_detalles as $d) {

                            $total = $total + ($d['precio'] * $d['cantidad']);
                            echo '<tr>';
                            echo '<td>' . $d['item_descrip'] . ' - ' . $d['mar_descrip'] . '</td>';
                            echo '<td>' . $d['cantidad'] . '</td>';
                            echo '<td>' . $d['precio'] . '</td>';
                            echo '<td>' . ($d['precio'] * $d['cantidad']) . '</td>';
                            // echo '<td>';
                
                            // echo '</td>';
                            echo '</tr>';
                        }
                        echo '</tbody>';

                        echo '<tfoot>';
                        echo '<tr>';
                        echo '<th colspan="3">Total</th>';
                        echo '<th>' . number_format($total, 0, ",", ".") . '</th>';
                        // echo '<th>';
                        // if ($pedido['estado'] == 'CONFIRMADO') {
                        //     echo '<div class="form-group">';
                        //     echo '<button class="btn btn-success" onclick="agregar_presupuesto_pedido(' . $pedido['id_cp'] . ');"><i class="fa fa-plus-circle"></i> Agregar</button>';
                        //     echo '</div>';
                        // }
                        // echo '</th>';
                        echo '</tr>';
                        echo '</tfoot>';
                    } else {
                        echo '<label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron detalles...</label>';
                    }
                    // Cierra la tabla al final de cada iteración
                    echo '</table>';
                    
                }
                

                echo '</div>';
                echo '</div>';
                ?>
                <div class="modal-footer justify-content-between">
                    <button class="btn btn-danger" data-dismiss="modal" id="btn-modal-secund-cerrar">
                        <i class="fa fa-ban"></i> Cancelar</button>
                </div>
            </div>
        </div>
    </div>
</div>