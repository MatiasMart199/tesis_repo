<?php
$id_cliente = $_POST['id_cliente'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();
$cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_servicios_inscripciones WHERE  estado = 'CONFIRMADO' AND id_cliente = $id_cliente order by id_inscrip;"));
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

                foreach ($cabecera as $c) {
                    echo '<div class="custom-container">';
                    echo '<label class="custom-container__label">#' . $c['id_inscrip'] . ' Nº-----( ' . $c['fecha'] . ' ) '.$c['cliente'].'</label>';
                    echo '<button class="btn btn-success" onclick="agregar_membresia_inscripcion(' . $c['id_inscrip'] . ');"><i class="fa fa-plus-circle"></i> Agregar</button>';
                    echo '</div>';

                    // Construye la fila de encabezado de la tabla una sola vez
                    $detalle = pg_fetch_all(pg_query($conn, "SELECT * FROM v_servicios_inscripciones_detalle WHERE id_inscrip = " . $c['id_inscrip'] . " ORDER BY precio ASC;"));

                    echo '<input type="hidden" value="' . $c['id_inscrip'] . '" id="id_inscrip">';
                    echo '<table class="table table-bordered">';
                    if (!empty($detalle)) {
                        echo '<thead>';
                        echo '<tr>';
                        echo '<th>Servicio</th>';
                        echo '<th>Dias</th>';
                        echo '<th>Precio Unitario</th>';
                        echo '<th>Subtotal</th>';
                        //echo '<th>Acciones</th>';
                        echo '</tr>';
                        echo '</thead>';

                        
                        echo '<tbody>';
                        $total = 0;
                        foreach ($detalle as $d) {

                            $total = $total + ($d['precio'] * $d['dia']);
                            echo '<tr>';
                            echo '<td>' . $d['ps_descrip']. '</td>';
                            echo '<td>' . $d['dia'] . '</td>';
                            echo '<td>' . $d['precio'] . '</td>';
                            echo '<td>' . ($d['precio'] * $d['dia']) . '</td>';
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
                        // if ($c['estado'] == 'CONFIRMADO') {
                        //     echo '<div class="form-group">';
                        //     echo '<button class="btn btn-success" onclick="agregar_membresia_inscripcion(' . $c['id_cp'] . ');"><i class="fa fa-plus-circle"></i> Agregar</button>';
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

                pg_close($conn);
                ?>
                <div class="modal-footer justify-content-between">
                    <button class="btn btn-danger" data-dismiss="modal" id="btn-modal-secund-cerrar">
                        <i class="fa fa-ban"></i> Cancelar</button>
                </div>
            </div>
        </div>
    </div>
</div>