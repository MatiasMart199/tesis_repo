<?php
$id_vac = $_POST['id_vac'];
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();
date_default_timezone_set('America/Asuncion');

$cajas = pg_fetch_all(pg_query($conn, "SELECT * FROM cajas WHERE estado = 'ACTIVO' and id_caja not in (select id_caja from vent_aperturas_cierres where estado ='ABIERTO' and id_sucursal = $id_sucursal);"));

if ($id_vac == '-1') { //CUANDO SE RESETEA
?>
    <label class="text-danger"><i class="fa fa-exclamation-circle"></i> Seleccione un pedido</label>
<?php
} else if ($id_vac == '0') { //CUANDO SE PRESIONA EL BOTON AGREGAR
    $cajero = $_SESSION['per_nombre'] . ' ' . $_SESSION['per_apellido'];
?>
    <div class="card card-primary">
        <div class="card-header text-center elevation-3">
            Datos de Aperura
        </div>
        <div class="card-body">
            <input type="hidden" value="0" id="id_vac">

            <!---------------------------------- FORMULARIO DE APERTURA------------------------------------------ -->
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label>Sucursal</label>
                        <input type="text" value="<?= $_SESSION['suc_nombre']; ?>" class="form-control" disabled>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group">
                        <label>Cajero</label>
                        <input type="text" value="<?= $cajero; ?>" class="form-control" disabled>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group">
                        <label>Monto Apertura</label>
                        <input type="number" value="<?php ?>" class="form-control" id="vac_monto_ape">
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group">
                        <label>Caja</label>
                        <select class="form-control" id="id_caja" style="width: 100%;">
                            <?php foreach ($cajas as $c) {
                                if ($c['estado'] == "ACTIVO") { ?>
                                    <option value="<?= $c['id_caja'] ?>"><?= $c['caj_descrip'] ?></option>
                            <?php }
                            } ?>
                        </select>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group">
                        <label>Fecha Apertura</label>
                        <input type="datetime" value="<?= date('Y-m-d H:i:s'); ?>" class="form-control" id="vac_fecha_ape" disabled>
                    </div>
                </div>
            </div>
            <!-------------------------------- FORMULARIO DE CIERRE----------------------------------- -->
            <hr>
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label>Monto Cierre</label>
                        <input type="number" value="0" class="form-control" id="vac_monto_cie" disabled>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group">
                        <label>Fecha Cierre</label>
                        <input type="datetime" value="<?= date('Y-m-d H:i:s'); ?>" class="form-control" id="vac_fecha_cie" disabled>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="form-group">
                        <label>Monto Efectivo</label>
                        <input type="number" value="0" class="form-control" id="vac_monto_efec" disabled>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-group">
                        <label>Monto Cheque</label>
                        <input type="number" value="0" class="form-control" id="vac_monto_cheq" disabled>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-group">
                        <label>Monto Tarjeta</label>
                        <input type="number" value="0" class="form-control" id="vac_monto_tarj" disabled>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-group">
                        <label>Monto Transferencia</label>
                        <input type="number" value="0" class="form-control" id="vac_monto_tranf" disabled>
                    </div>
                </div>

            </div>

            <div class="row">
                <div class="form-group">
                    <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                    <button class="btn btn-success" onclick="agregar_grabar();"><i class="fa fa-save"></i> Grabar</button>
                </div>
            </div>
        </div>
    </div>
<?php
} else { //O SE TRATA DE UN PEDIDO DEFINIDO O SE TRATA DEL ULTIMO PEDIDO
    if ($id_vac == '-2') { //SE TRATA DEL ULTIMO PEDIDO
        $cabeceras = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_aperturas_cierres WHERE id_vac = (select max(id_vac) from vent_aperturas_cierres where id_sucursal = $id_sucursal);"));
        $funcionario = pg_fetch_all(pg_query($conn, "SELECT * FROM v_funcionarios WHERE estado = 'ACTIVO';"));
    } else { //SE TRATA DE UN PEDIDO DEFINIDO
        $cabeceras = pg_fetch_all(pg_query($conn, "SELECT * FROM v_vent_aperturas_cierres WHERE id_vac = $id_vac;"));
        $funcionario = pg_fetch_all(pg_query($conn, "SELECT * FROM v_funcionarios WHERE estado = 'ACTIVO';"));
    }
    $arqueos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_arqueo_resumen WHERE id_vac = " . $cabeceras[0]['id_vac'] . ";"));
    $disabled = 'disabled';
    if ($cabeceras[0]['estado'] == 'PENDIENTE') {
        $disabled = '';
    }

    function verificarFecha($fecha)
    {
        date_default_timezone_set('America/Asuncion');

        if ($fecha == null) {
            return date('Y-m-d H:i:s');
        } else {
            return $fecha;
        }
    }

    // function verificarEntidad($id_ee)
    // {
    //     if ($id_ee == null) {
    //         return 0;
    //     } else {
    //         return $id_ee;
    //     }
    // }
    // $fecha_cierre = null;
    // if ($cabeceras[0]['vac_fecha_cie'] != null) {
    //     $fecha_cierre = $cabeceras[0]['vac_fecha_cie'];
    // } else {
    //     $fecha_cierre = date('Y-m-d H:i:s');
    // }

?>
    <div class="row">
        <div class="card card-primary col-12">
            <div class="card-header text-center elevation-3">
                Datos de Cierre
            </div>
            <div class="card-body">
                <input type="hidden" value="<?php echo $cabeceras[0]['id_vac']; ?>" id="id_vac">

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Sucursal</label>
                            <input type="text" value="<?= $cabeceras[0]['suc_nombre']; ?>" class="form-control" disabled>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Cajero</label>
                            <input type="text" value="<?= $cabeceras[0]['funcionario']; ?>" class="form-control" disabled>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="form-group">
                            <label>Monto Apertura</label>
                            <input type="number" value="<?= $cabeceras[0]['vac_monto_ape'] ?>" class="form-control" id="vac_monto_ape" disabled>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="form-group">
                            <label>Caja</label>
                            <select class="form-control" id="id_caja" style="width: 100%;" disabled>
                                <option value="<?= $cabeceras[0]['id_caja'] ?>"><?= $cabeceras[0]['caj_descrip'] ?></option>
                            </select>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="form-group">
                            <label>Fecha Apertura</label>
                            <input type="datetime" value="<?= verificarFecha($cabeceras[0]['vac_fecha_ape']) ?>" class="form-control" id="vac_fecha_ape" disabled>
                        </div>
                    </div>
                </div>
                <!-------------------------------- FORMULARIO DE CIERRE----------------------------------- -->
                <hr>
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Monto Cierre</label>
                            <input type="number" value="<?= $cabeceras[0]['vac_monto_cie'] ?>" class="form-control" id="vac_monto_cie" readonly>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Fecha Cierre</label>
                            <input type="datetime" value="<?= verificarFecha($cabeceras[0]['vac_fecha_cie']) ?>" class="form-control" id="vac_fecha_cie" disabled>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="form-group">
                            <label>Monto Efectivo</label>
                            <input type="number" value="<?= $cabeceras[0]['vac_monto_efec'] ?>" class="form-control" id="vac_monto_efec" disabled>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-group">
                            <label>Monto Cheque</label>
                            <input type="number" value="<?= $cabeceras[0]['vac_monto_cheq'] ?>" class="form-control" id="vac_monto_cheq" disabled>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-group">
                            <label>Monto Tarjeta</label>
                            <input type="number" value="<?= $cabeceras[0]['vac_monto_tarj'] ?>" class="form-control" id="vac_monto_tarj" disabled>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-group">
                            <label>Monto Transferencia</label>
                            <input type="number" value="<?= $cabeceras[0]['vac_monto_tranf'] ?>" class="form-control" id="vac_monto_tranf" disabled>
                        </div>
                    </div>

                    <div class="form-group">
                        <button class="btn btn-danger" onclick="cancelar();"><i class="fa fa-ban"></i> Cancelar</button>
                        <?php if ($cabeceras[0]['estado'] == 'ABIERTO') { ?>
                            <button hidden class="btn btn-info" onclick=""><i class="fa fa-check-circle"></i>Generar Arqueo</button>
                        <?php } ?>
                        <?php if ($cabeceras[0]['estado'] == 'ABIERTO') { ?>
                            <button class="btn btn-danger" onclick="anular();"><i class="fa fa-minus-circle"></i> Anular</button>
                            <button class="btn btn-success" onclick="modificar();"><i class="fa fa-edit"></i> Cierra Caja</button>
                            <button hidden class="btn btn-success" onclick="confirmar();"><i class="fa fa-check-circle"></i> Confirmar Cierre</button>
                        <?php } ?>
                    </div>
                </div>
            </div>
        </div>
        <script>
            $(document).ready(function() {
                // Función que calcula el total y lo asigna al campo "vac_monto_cie"
                function calcularTotal() {
                    const efectivo = parseFloat($('#vac_monto_efec').val()) || 0;
                    const cheque = parseFloat($('#vac_monto_cheq').val()) || 0;
                    const tarjeta = parseFloat($('#vac_monto_tarj').val()) || 0;
                    const transferencia = parseFloat($('#vac_monto_tranf').val()) || 0;

                    const total = efectivo + cheque + tarjeta + transferencia;
                    // Actualiza el campo Monto Cierre con dos decimales
                    //$('#vac_monto_cie').val(total.toFixed(2));
                    $('#vac_monto_cie').val(total);
                }

                // Asigna los eventos 'input' y 'change' a los campos de monto
                $('#vac_monto_efec, #vac_monto_cheq, #vac_monto_tarj', '#vac_monto_tranf').on('input change', calcularTotal);
                $('#arq_monto_efec, #arq_monto_cheq, #arq_monto_tarj', '#arq_monto_tranf').on('input change', calcularTotal);

                // Ejecuta el cálculo al cargar para establecer el valor inicial
                calcularTotal();
            });
        </script>

        <?php if ($cabeceras[0]['estado'] == 'ABIERTO') { ?>
            <!-- PARA AGREGAR ARQUEO -->
            <div class="card card-primary col-12">
                <div class="card-header text-center elevation-3">
                    Cargar Arqueo de Caja
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="form-group">
                                    <label>Solicitante</label>
                                    <select class="select2" id="id_fun_solicitante">
                                        <?php foreach ($funcionario as $f) { ?>
                                            <option value="<?= $f['id_funcionario'] ?>"><?= $f['funcionario'] ?></option>
                                        <?php } ?>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group col-md-3">
                                <label>Monto Efectivo</label>
                                <input type="number" value="" class="form-control" id="arq_monto_efec">
                            </div>
                            <div class="form-group col-md-3">
                                <label>Monto Cheque</label>
                                <input type="number" value="" class="form-control" id="arq_monto_cheq">
                            </div>
                            <div class="form-group  col-md-3">
                                <label>Monto Tarjeta</label>
                                <input type="number" value="" class="form-control" id="arq_monto_tarj">
                            </div>
                            <div class="form-group col-md-3">
                                <label>Monto Transferencia</label>
                                <input type="number" value="" class="form-control" id="arq_monto_tranf">
                            </div>
                            <div class="form-group">
                            <?php    
                                $disabled = '';
                                if ($arqueos[0]['id_varq'] != null){ 
                                $disabled = 'disabled';
                                }?>
                                <button <?= $disabled ?> class="btn btn-success" onclick="agregar_detalles();"><i class="fa fa-plus-circle"></i> Agregar</button>

                            </div>
                        </div>
                    </div>
                </div>
            <?php } ?>
            </div>

            <!-- TABLA DE ARQUEO -->
            <div class="card card-primary col-12">
                <div class="card-header text-center elevation-3">
                    Arqueo de Caja
                </div>
                <div class="card-body">
                    <?php if (!empty($arqueos) && $arqueos[0]['id_varq'] != null) { ?>
                        <table class="table table-bordered" font-size="10px">
                            <thead>
                                <tr> 
                                    <th>#</th>
                                    <th>Cajero</th>
                                    <th>Caja</th>
                                    <th>Fecha</th>
                                    <th>Efectivo</th>
                                    <th>Cheque</th>
                                    <th>Tarjeta</th>
                                    <th>Transferencia</th>
                                    <th>Dif. Total</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php
                                $total_monto = 0;
                                foreach ($arqueos as $d) {
                                    $total_monto += $d['fisico_efectivo'] + $d['fisico_cheque'] + $d['fisico_tarjeta'] + $d['fisico_tranf'];
                                ?>
                                    <tr>
                                        <td><?= $d['id_varq']; ?></td>
                                        <td><?= $d['funcionario']; ?></td>
                                        <td><?= $d['caj_descrip'] . " " . $d['suc_nombre']; ?></td>
                                        <td><?= $d['fecha_arquo']; ?></td>
                                        <td><?= $d['fisico_efectivo']; ?></td>
                                        <td><?= $d['fisico_cheque']; ?></td>
                                        <td><?= $d['fisico_tarjeta']; ?></td>
                                        <td><?= $d['fisico_tranf']; ?></td>
                                        <td><?= $d['dif_total']; ?></td>
                                        <td>
                                            <?php if ($cabeceras[0]['estado'] == 'ABIERTO') { ?>
                                                <button class="btn btn-danger" onclick="eliminar_detalle(<?php echo $d['id_vac']; ?>);"><i class="fa fa-minus-circle"></i></button>
                                            <?php } ?>
                                        </td>
                                    </tr>
                                <?php } ?>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <th colspan="8">Total monto real:</th>
                                    <th> <?= number_format($total_monto, 0, ',', '.')  ?></th>
                                    <th></th>
                                </tr>

                            </tfoot>
                        </table>
                    <?php } else { ?>
                        <label class="text-danger"><i class="fa fa-exclamation-circle"></i> No se registraron arqueos...</label>
                    <?php } ?>
                </div>
            </div>
        <?php
    }
    pg_close($conn);
