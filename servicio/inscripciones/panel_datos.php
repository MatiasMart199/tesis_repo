<?php
$id_inscrip = $_POST['id_inscrip'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();
$cliente = pg_fetch_all(pg_query($conn, "SELECT * from  v_clientes where id_cliente not in (select id_cliente from v_servicios_inscripciones) and estado = 'ACTIVO' order by cliente, per_ruc;"));

// function getFechaDays($fechaIni, $fechaFi){
//     $fechaInicio = new DateTime($fechaIni);
//     $fechaFin = new DateTime($fechaFi);

//     $diferencia = $fechaInicio->diff($fechaFin);

//     return $diferencia->days;
// }

function calcularEdad($fechaNacimiento) {
    // $fechaNacimiento debe estar en formato YYYY-MM-DD
    $fechaNacimiento = new DateTime($fechaNacimiento);
    $hoy = new DateTime(date("Y-m-d"));
    $edad = $hoy->diff($fechaNacimiento);
    return $edad->y; // Retorna solo los años
}


if ($id_inscrip == '-1') { //CUANDO SE RESETEA
?>
    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> Seleccione una inscripcion</label>
<?php
} else if ($id_inscrip == '0') { //CUANDO SE PRESIONA EL BOTON AGREGAR
?>
    <div class="card card-primary">
        <div class="card-header text-center elevation-3">
            Datos de la inscripción
        </div>
        <div class="card-body">
            <input type="hidden" value="0" id="id_inscrip">
            <div>
                <label>Cliente</label>
                <select class="select2" id="id_cliente">
                    <option selected="true" disabled>Seleccione...</option>
                    <?php foreach ($cliente as $cl) { ?>
                        <option value="<?php echo $cl['id_cliente']; ?>"><?php echo $cl['cliente'] . " " . $cl['per_ruc']; ?></option>
                    <?php }; ?>
                </select>
            </div>

            <div class="row">
                <div class="form-group col-md-12">
                    <label>Fecha</label>
                    <input type="date" value="<?php echo date('Y-m-d'); ?>" class="form-control" disabled>
                </div>

                <div class="form-group col-md-6" hidden>
                    <label>Vencimiento</label>
                    <input type="date" value="<?php echo date('Y-m-d'); ?>" class="form-control" id="ins_aprobacion">
                </div>
            </div>
            <div class="row">
                <div class="form-group col-md-3">
                    <label>Edad</label>
                    <input type="number" value="" class="form-control" id="ins_edad" disabled>
                </div>
                <div class="form-group col-md-3">
                    <label>Peso (Kg)</label>
                    <input type="number" value="" class="form-control" id="ins_peso">
                </div>
                <div class="form-group col-md-3">
                    <label>Altura (cm)</label>
                    <input type="number" value="" class="form-control" id="ins_altura">
                </div>
                <div class="form-group col-md-3">
                    <label>Seguro Médico</label>
                    <select class="select2" id="ins_seguro_medico">
                        <option selected="true" value="false">NO</option>
                        <option value="true">SI</option>
                    </select>
                </div>
            <div class="form-group">
                <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i> Grabar</button>
            </div>
        </div>
    </div>
    <script> const cliente = <?= json_encode($cliente) ?>; </script>
<?php
} else { //O SE TRATA DE UN PEDIDO DEFINIDO O SE TRATA DEL ULTIMO PEDIDO
    if ($id_inscrip == '-2') { //SE TRATA DEL ULTIMO PEDIDO
        $movimientos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_servicios_inscripciones WHERE id_inscrip = (select max(id_inscrip) from servicios_inscripciones_cabecera where id_sucursal = $id_sucursal);"));
    } else { //SE TRATA DE UN PEDIDO DEFINIDO
        $movimientos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_servicios_inscripciones WHERE id_inscrip = $id_inscrip;"));
    }
    $detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_servicios_inscripciones_detalle WHERE id_inscrip = " . $movimientos[0]['id_inscrip'] . " ORDER BY ps_descrip;"));
    $disabled = 'disabled';
    if ($movimientos[0]['estado'] == 'PENDIENTE') {
        $disabled = '';
    }
?>
    <div class="card">
        <div class="card-body">
            <div class="d-flex justify-content-end">
                <button <?= $disabled ?> class="btn btn-success text-white" onclick="panel_estado_salud(<?= $movimientos[0]['id_cliente']; ?>);" id="btn-modal-secund-cerrar"><i class="fas fa-plus-circle"></i> Agregar Estado de Salud</button>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="card card-primary col-8">
            <div class="card-header text-center elevation-3">
                Datos de la Inscripción
            </div>
            
            <div class="card-body">
                <input type="hidden" value="<?php echo $movimientos[0]['id_inscrip']; ?>" id="id_inscrip">
                <input type="hidden" value="0" id="eliminar_id_plan_servi">
                <div>
                    <label>Cliente</label>
                    <select class="select2" id="id_cliente" disabled>
                        <option selected="true" value="<?= $movimientos[0]['id_cliente']; ?>"><?= $movimientos[0]['cliente'] . " " . $movimientos[0]['per_ci']; ?></option>
                    </select>
                </div>
                <div class="row">
                    <div class="form-group col-md-12">
                        <label>Fecha</label>
                        <input type="date" value="<?= $movimientos[0]['ins_fecha']; ?>" class="form-control" disabled>
                    </div>

                    <div class="form-group col-md-6" hidden>
                        <label>Vencimiento</label>
                        <input type="date" value="<?= $movimientos[0]['ins_aprobacion']; ?>" class="form-control" id="ins_aprobacion">
                    </div>
                </div>
                
                <div class="row">
                    <div class="form-group col-md-3">
                        <label>Edad</label>
                        <input type="number" value="<?= $movimientos[0]['ins_edad']; ?>" class="form-control" id="ins_edad" disabled>
                    </div>
                    <div class="form-group col-md-3">
                        <label>Peso (Kg)</label>
                        <input type="number" value="<?= $movimientos[0]['ins_peso']; ?>" class="form-control" id="ins_peso" <?= $disabled; ?>>
                    </div>
                    <div class="form-group col-md-3">
                        <label>Altura (cm)</label>
                        <input type="number" value="<?= $movimientos[0]['ins_altura']; ?>" class="form-control" id="ins_altura" <?= $disabled; ?>>
                    </div>
                    <div class="form-group col-md-3">
                        <label>Seguro Médico</label>
                        <select class="select2" id="ins_seguro_medico" <?= $disabled; ?>>
                            <option selected="true" value="<?= $movimientos[0]['ins_seguro_medico']; ?>"><?php if ($movimientos[0]['ins_seguro_medico'] == 't') { ?>SI<?php } else { ?>NO<?php } ?></option>
                            <option value="true">SI</option>
                            <option value="false">NO</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-group">
                    <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                    <?php if ($movimientos[0]['estado'] == 'PENDIENTE') { ?>
                        <button class="btn btn-danger" onclick="anular();"><i class="fa fa-minus-circle"></i> Anular</button>
                        <button class="btn btn-warning text-white" onclick="modificar();"><i class="fa fa-edit"></i> Modificar</button>
                        <button class="btn btn-success" onclick="confirmar();"><i class="fa fa-check-circle"></i> Confirmar</button>
                    <?php } 
                    if ($movimientos[0]['estado'] == 'CONFIRMADO') { ?>
                        <button class="btn btn-primary text-white" onclick="generarContrato(<?= $movimientos[0]['id_inscrip']; ?>);"><i class="fa fa-file-pdf"></i> Generar Contrato</button>
                    <?php } ?>
                </div>
            </div>
        </div>
        
        <!-- ESTADO DE SALUD DEL CLIENTE -->
         <?php if ($movimientos[0]['estado'] == 'PENDIENTE') { 
            $estado_salud = pg_fetch_all(pg_query($conn, "SELECT * FROM v_clientes_estados_salud WHERE estado = 'ACTIVO' AND id_cliente = " . $movimientos[0]['id_cliente'] . ""));    ?>
        <div class="card card-primary col-4">
            <div class="card-header text-center elevation-3">
                Estado de Salud del Cliente
            </div>
            <div class="card-body">
                <?php if (!empty($estado_salud)) { ?>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Estado de Salud</th>
                                <th>Observación</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php $total = 0;
                            foreach ($estado_salud as $d) {?>
                                <tr>
                                    <td><?php echo $d['es_nombre']; ?></td>
                                    <td><?php echo $d['es_descrip']; ?></td>
                                </tr>
                            <?php } ?>
                        </tbody>
                    </table>
                <?php } else { ?>
                    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron detalles...</label>
                <?php } ?>
            </div>
        </div>
        <?php } ?>

        <!-- DETALLES DE LA INSCRIPCION  -->
        <div class="card card-primary col-8">
            <div class="card-header text-center elevation-3">
                Detalles de la Inscripción
            </div>
            <div class="card-body">
                <?php if (!empty($detalles)) { ?>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Producto</th>
                                <th>Duración</th>
                                <th>Tip. Duración</th>
                                <th>P. Unitario</th>
                                <th>Subtotal</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php $total = 0;
                            foreach ($detalles as $d) {
                                $total = $total + ($d['precio'] * $d['dia']) ?>
                                <tr>
                                    <td><?= $d['ps_descrip']; ?></td>
                                    <td><?= $d['dia']; ?></td>
                                    <td><?= $d['td_descrip']; ?></td>
                                    <td><?= number_format($d['precio'], 0, ",", ".") ?></td>
                                    <td><?= $d['precio'] * $d['dia']; ?></td>
                                    <td>
                                        <?php if ($movimientos[0]['estado'] == 'PENDIENTE') { ?>
                                            <!-- <button class="btn btn-warning text-white" onclick="modificar_detalle(<?php //echo $d['id_plan_servi']; ?>);" id="btn-panel-modificar-cerrar"><i class="fa fa-edit"></i></button> -->
                                            <button class="btn btn-danger" onclick="eliminar_detalle(<?php echo $d['id_plan_servi']; ?>);"><i class="fa fa-minus-circle"></i></button>
                                        <?php } ?>
                                    </td>
                                </tr>
                            <?php } ?>
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="4">Total</th>
                                <th><?php echo number_format($total, 0, ",", "."); ?></th>
                                <th></th>
                            </tr>
                        </tfoot>
                    </table>
                <?php } else { ?>
                    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron detalles...</label>
                <?php } ?>
            </div>
        </div>
        <?php if ($movimientos[0]['estado'] == 'PENDIENTE') {
            $articulos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_planes_servicios WHERE estado = 'ACTIVO' AND id_plan_servi NOT IN (select id_plan_servi from servicios_inscripciones_detalle WHERE id_inscrip = " . $movimientos[0]['id_inscrip'] . ") ORDER BY ps_descrip;"))
        ?>
            <div class="card card-primary col-4">
                <div class="card-header text-center elevation-3">
                    Agregar Plan
                </div>
                <div class="card-body">
                    <?php if (!empty($articulos)) { ?>
                        <div class="form-group">
                            <label>Plan de Servicio</label>
                            <select class="select2" id="agregar_id_plan_servi">
                                <option selected="true" disabled>Seleccione...</option>
                                <?php foreach ($articulos as $a) { ?>
                                    <option value="<?php echo $a['id_plan_servi']; ?>"><?= $a['td_descrip'] . " - " . $a['ps_descrip']; ?></option>
                                <?php } ?>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Duracion</label>
                            <input type="number" disabled value="" class="form-control" id="agregar_dia">
                        </div>
                        <div class="form-group">
                            <label>Promociones</label>
                            <input type="text" disabled  class="form-control" id="promociones">
                        </div>
                        <div class="form-group">
                            <button class="btn btn-success" onclick="agregar_detalles();"><i class="fa fa-plus-circle"></i> Agregar</button>
                        </div>
                    <?php } else { ?>
                        <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se encuentran plan disponibles...</label>
                    <?php } ?>
                </div>
            </div>
            <script>const articulos = <?php echo json_encode($articulos); ?>; </script>
        <?php } ?>
    </div>
<?php
} pg_close($conn);
