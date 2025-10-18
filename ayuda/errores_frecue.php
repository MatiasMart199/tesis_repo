<?php
include '../Conexion.php';
include '../session.php';
?>
<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>TESIS</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="/tesis/iconos/1.jpg" type="jpg">
    <link rel="stylesheet" href="/tesis/estilo/dist/css/adminlte.min.css">
    <link rel="stylesheet" href="/tesis/estilo/plugins/overlayScrollbars/css/OverlayScrollbars.min.css">
    <link rel="stylesheet" href="/tesis/estilo/descarga/font-google.css">
    <link rel="stylesheet" href="/tesis/estilo/plugins/sweetalert2/sweetalert2.min.css">
    <link rel="stylesheet" href="/tesis/estilo/plugins/toastr/toastr.min.css">
    <link rel="stylesheet" href="/tesis/estilo/plugins/select2/css/select2.min.css">
    <link rel="stylesheet" href="/tesis/estilo/descarga/tabla1.min.css">
    <link rel="stylesheet" href="/tesis/estilo/descarga/tabla2.min.css">
    <link rel="stylesheet" href="/tesis/estilo.css">
</head>

<body class="hold-transition sidebar-mini layout-fixed sidebar-collapse">
    <div class="wrapper">
        <?php include("../cabecera.php"); ?>
        <?php include("../menu.php"); ?>
        <div class="content-wrapper">
            <div class="content-header">
                <div class="container-fluid">
                    <div class="row mb-2">
                        <div class="col-sm-6">
                            <h1 class="m-0 text-dark">Errores Frecuentes</h1>
                        </div>
                        <div class="col-sm-6">
                            <ol class="breadcrumb float-sm-right">
                                <li class="breadcrumb-item active">Ayuda</li>
                                <li class="breadcrumb-item active">Errores Frecuentes</li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>
            <section class="content">
                <!-- END ALERTS AND CALLOUTS -->
                <div class="row">
                    <div class="col-12">
                        <!-- Custom Tabs -->
                        <!-- ========================================================================================================================= -->
                        <div class="card">
                            
                            <div class="card-header d-flex p-0">
                                <ul class="nav nav-pills ml-auto p-2">
                                    <li class="nav-item"><a class="nav-link active" href="#tab_stock" data-toggle="tab">Stock</a></li>
                                    <li class="nav-item"><a class="nav-link" href="#tab_pedidos" data-toggle="tab">Procesos</a></li>
                                    <li class="nav-item"><a class="nav-link" href="#tab_membresias" data-toggle="tab">Membresías</a></li>
                                    <li class="nav-item"><a class="nav-link" href="#tab_pagos" data-toggle="tab">Pagos</a></li>
                                </ul>
                            </div><!-- /.card-header -->
                            <div class="card-body">
                                <div class="tab-content">
                                    <!-- TAB 1: VALIDACIONES DE STOCK -->
                                    <div class="tab-pane active" id="tab_stock">
                                        <h4><i class="fas fa-boxes text-warning"></i> Validaciones de Stock</h4>
                                        <div class="alert alert-warning">
                                            <h5><i class="fas fa-exclamation-triangle"></i> STOCK INSUFICIENTE</h5>
                                            <p><strong>Descripción:</strong> Este error ocurre cuando intentas procesar una venta o pedido de un producto que no tiene suficiente stock disponible en el inventario.</p>
                                            <p><strong>Causas posibles:</strong></p>
                                            <ul>
                                                <li>El producto seleccionado tiene cantidad cero en stock</li>
                                                <li>El stock físico es menor a la cantidad solicitada</li>
                                                <li>Hubo una actualización reciente del inventario no reflejada en el sistema</li>
                                            </ul>
                                            <p><strong>Solución:</strong></p>
                                            <ul>
                                                <li>Verificar el stock actual del producto en el módulo de inventario</li>
                                                <li>Realizar un ajuste de inventario si es necesario</li>
                                                <li>Contactar con el departamento de compras para reponer stock</li>
                                                <li>Considerar productos sustitutos si están disponibles</li>
                                            </ul>
                                        </div>
                                    </div>

                                    <!-- TAB 2: VALIDACIONES DE PEDIDOS -->
                                    <div class="tab-pane" id="tab_pedidos">
                                        <h4><i class="fas fa-clipboard-list text-primary"></i> Validaciones de Pedidos</h4>

                                        <div class="alert alert-info mb-4">
                                            <h5><i class="fas fa-clock"></i> MOVIMIENTOS PENDIENTES DE CONFIRMACIÓN</h5>
                                            <p><strong>Descripción:</strong> El sistema detecta que existen movimientos o transacciones pendientes de confirmación en la sucursal actual.</p>
                                            <p><strong>Causas posibles:</strong></p>
                                            <ul>
                                                <li>Notas de compra en estado "PENDIENTE" sin procesar</li>
                                                <li>Transacciones incompletas en el sistema</li>
                                                <li>Procesos batch que no han finalizado</li>
                                            </ul>
                                            <p><strong>Solución:</strong></p>
                                            <ul>
                                                <li>Revisar el módulo de "Notas de Compra" y filtrar por estado "PENDIENTE"</li>
                                                <li>Completar o cancelar las transacciones pendientes</li>
                                                <li>Contactar al administrador si persisten transacciones fantasma</li>
                                            </ul>
                                        </div>

                                        <div class="alert alert-secondary">
                                            <h5><i class="fas fa-ban"></i> ITEM DUPLICADO EN PEDIDO</h5>
                                            <p><strong>Descripción:</strong> Estás intentando agregar un producto que ya existe en el pedido actual.</p>
                                            <p><strong>Causas posibles:</strong></p>
                                            <ul>
                                                <li>Doble clic accidental al agregar productos</li>
                                                <li>Reintento de agregar el mismo item sin verificar la lista</li>
                                                <li>Error de interfaz que muestra items duplicados</li>
                                            </ul>
                                            <p><strong>Solución:</strong></p>
                                            <ul>
                                                <li>Verificar la lista de items en el pedido antes de agregar nuevos</li>
                                                <li>Si necesitas aumentar la cantidad, modificar el item existente</li>
                                                <li>Utilizar la función "Buscar en pedido" antes de agregar</li>
                                            </ul>
                                        </div>
                                    </div>

                                    <!-- TAB 3: VALIDACIONES DE MEMBRESÍAS -->
                                    <div class="tab-pane" id="tab_membresias">
                                        <h4><i class="fas fa-id-card text-success"></i> Validaciones de Membresías</h4>

                                        <div class="alert alert-success mb-4">
                                            <h5><i class="fas fa-user-check"></i> SIN CUOTAS PENDIENTES</h5>
                                            <p><strong>Descripción:</strong> Se intentó procesar un pago de membresía pero el cliente no tiene cuotas pendientes.</p>
                                            <p><strong>Causas posibles:</strong></p>
                                            <ul>
                                                <li>El cliente ya pagó todas sus cuotas pendientes</li>
                                                <li>La membresía del cliente está vencida o cancelada</li>
                                                <li>Error en la selección del cliente</li>
                                            </ul>
                                            <p><strong>Solución:</strong></p>
                                            <ul>
                                                <li>Verificar el estado de la membresía del cliente</li>
                                                <li>Confirmar que existen cuotas con estado "PENDIENTE"</li>
                                                <li>Revisar el historial de pagos recientes</li>
                                            </ul>
                                        </div>

                                        <div class="alert alert-danger">
                                            <h5><i class="fas fa-money-bill-wave"></i> FACTURA DE SERVICIO DEBE SER AL CONTADO</h5>
                                            <p><strong>Descripción:</strong> Para servicios de membresía específicos, el sistema requiere que el pago sea realizado al contado.</p>
                                            <p><strong>Causas posibles:</strong></p>
                                            <ul>
                                                <li>Selección incorrecta del tipo de factura "CRÉDITO"</li>
                                                <li>Configuración incorrecta del tipo de servicio</li>
                                                <li>Políticas de la empresa para servicios específicos</li>
                                            </ul>
                                            <p><strong>Solución:</strong></p>
                                            <ul>
                                                <li>Cambiar el tipo de factura a "CONTADO"</li>
                                                <li>Verificar las políticas de pago para el servicio seleccionado</li>
                                                <li>Consultar con el departamento de administración si se requiere una excepción</li>
                                            </ul>
                                        </div>
                                    </div>

                                    <!-- TAB 4: VALIDACIONES DE PAGOS -->
                                    <div class="tab-pane" id="tab_pagos">
                                        <h4><i class="fas fa-credit-card text-danger"></i> Validaciones de Pagos</h4>

                                        <div class="alert alert-dark mb-4">
                                            <h5><i class="fas fa-minus-circle"></i> MONTO DE COBRO NEGATIVO</h5>
                                            <p><strong>Descripción:</strong> Se detectó un valor negativo en el monto del cobro, lo cual no es permitido por el sistema.</p>
                                            <p><strong>Causas posibles:</strong></p>
                                            <ul>
                                                <li>Error al digitar el monto (signo negativo accidental)</li>
                                                <li>Problema con la calculadora integrada</li>
                                                <li>Error en fórmulas de cálculo automático</li>
                                            </ul>
                                            <p><strong>Solución:</strong></p>
                                            <ul>
                                                <li>Verificar que el monto ingresado sea un número positivo</li>
                                                <li>Utilizar la calculadora del sistema para confirmar valores</li>
                                                <li>Revisar fórmulas de cálculo si se usan valores automáticos</li>
                                            </ul>
                                        </div>

                                        <div class="alert alert-warning mb-4">
                                            <h5><i class="fas fa-exclamation-circle"></i> PAGO EXCEDE EL MONTO DE LA CUOTA</h5>
                                            <p><strong>Descripción:</strong> El monto del pago ingresado supera el valor total de la cuota pendiente.</p>
                                            <p><strong>Causas posibles:</strong></p>
                                            <ul>
                                                <li>Error al digitar el monto del pago</li>
                                                <li>Confusión entre el monto total y el saldo pendiente</li>
                                                <li>Intento de pagar múltiples cuotas en una sola transacción</li>
                                            </ul>
                                            <p><strong>Solución:</strong></p>
                                            <ul>
                                                <li>Verificar el monto exacto de la cuota pendiente</li>
                                                <li>Si se desea pagar múltiples cuotas, usar la opción correspondiente</li>
                                                <li>Consultar el detalle de cuotas pendientes del cliente</li>
                                            </ul>
                                        </div>

                                        <div class="alert alert-info">
                                            <h5><i class="fas fa-search"></i> MÉTODO DE PAGO NO ENCONTRADO</h5>
                                            <p><strong>Descripción:</strong> El sistema no puede encontrar el método de pago especificado en la transacción.</p>
                                            <p><strong>Causas posibles:</strong></p>
                                            <ul>
                                                <li>El método de pago fue eliminado o desactivado</li>
                                                <li>Error en la referencia del método de pago</li>
                                                <li>Problema de sincronización en la base de datos</li>
                                            </ul>
                                            <p><strong>Solución:</strong></p>
                                            <ul>
                                                <li>Verificar que el método de pago esté activo en el sistema</li>
                                                <li>Contactar al administrador para revisar la configuración de métodos de pago</li>
                                                <li>Intentar seleccionar un método de pago diferente</li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- ========================================================================================================================= -->
                        <!-- ./card -->
                    </div>
                    <!-- /.col -->
                </div>
                <!-- /.row -->
            </section>
        </div>
        <footer class="main-footer">
            <strong>Copyright &copy;
                2023 <a href="#">TESIS</a>
            </strong>
        </footer>
    </div>
    <script src="/tesis/estilo/plugins/jquery/jquery.min.js"></script>
    <script src="/tesis/estilo/plugins/jquery-ui/jquery-ui.min.js"></script>
    <script>
        $.widget.bridge('uibutton', $.ui.button)
    </script>
    <script src="/tesis/estilo/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
    <script src="/tesis/estilo/plugins/overlayScrollbars/js/jquery.overlayScrollbars.min.js"></script>
    <script src="/tesis/estilo/dist/js/adminlte.js"></script>
    <script src="/tesis/iconos/fontawesome.js"></script>
    <script src="/tesis/estilo/plugins/fastclick/fastclick.js"></script>
    <script src="/tesis/estilo/plugins/sweetalert2/sweetalert2.min.js"></script>
    <script src="/tesis/estilo/plugins/toastr/toastr.min.js"></script>
    <script src="/tesis/estilo/plugins/select2/js/select2.full.min.js"></script>
    <script src="/tesis/estilo/descarga/tabla1.min.js"></script>
    <script src="/tesis/estilo/descarga/tabla2.min.js"></script>
    <script src="/tesis/estilo/descarga/tabla3.min.js"></script>
    <script src="/tesis/estilo/descarga/tabla4.min.js"></script>
    <?php //include("../../mensaje.php"); 
    ?>
    <?php require_once "{$_SERVER['DOCUMENT_ROOT']}/tesis/mensaje.php"; ?>
    <script src="funciones.js"></script>

</body>

</html>