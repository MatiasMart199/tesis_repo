<?php
//$id_vped = $_POST['id_vped'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();

//CONSULTA DE LA VISTA DE LOS DETALLES DEL MOVIMIENTO ANTERIOR
$consultas_bd = pg_fetch_all(pg_query($conn, "SELECT * FROM v_ventas_pedidos WHERE  estado = 'CONFIRMADO' order by id_vped;"));
?>

<div class="modal-dialog modal-lg">
    <div class="modal-content">
        <div class="card card-primary">
            <div class="card-header text-center text-white">
                ORDENES CONFIRMADOS
            </div>
            <input type="hidden" value="<?php echo $consultas_bd[0]['id_vped']; ?>" id="id_vped">
            <div class="card-body contenido-principal">
                <!--CONTENIDO PRINCIPAL-->

                <?php
                // Supongamos que tienes un array de tablas llamado $tablas con datos de las tablas
                // Puedes iterar sobre ellas para generar las tablas en HTML
                echo '<div class="card card-success col-12">';

                echo '<div class="card-body">';

                foreach ($consultas_bd as $p) {
                    echo '<div class="custom-container">';
                    echo '<label class="custom-container__label">#' . $p['id_vped'] . ' Nº-----( ' . $p['fecha'] . ' )</label>';
                    echo '<button class="btn btn-success" onclick="agregar_compra_orden(' . $p['id_vped'] . ');"><i class="fa fa-plus-circle"></i> Agregar</button>';
                    echo '</div>';
                    //echo '<input type="hidden" value="echo '.$p[0]['id_vped'].'" id="id_vped">';
                    // Construye la fila de encabezado de la tabla una sola vez
                    $consultas_consolidacion = pg_fetch_all(pg_query($conn, "SELECT * FROM v_ventas_pedidos_detalle WHERE id_vped = " . $p['id_vped'] . " ORDER BY precio ASC;"));

                    echo '<input type="hidden" value="' . $p['id_vped'] . '" id="id_cpedido">';
                    echo '<table class="table table-bordered">';
                    if (!empty($consultas_consolidacion)) {
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
                        foreach ($consultas_consolidacion as $d) {

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
                        // if ($p['estado'] == 'CONFIRMADO') {
                        //     echo '<div class="form-group">';
                        //     echo '<button class="btn btn-success" onclick="agregar_presupuesto_pedido(' . $p['id_cp'] . ');"><i class="fa fa-plus-circle"></i> Agregar</button>';
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