<?php
   include "{$_SERVER['DOCUMENT_ROOT']}/tesis/Conexion.php";
   include "{$_SERVER['DOCUMENT_ROOT']}/tesis/session.php";
   $_SESSION['id_pagina'] = '23';
   //include "../../permiso.php";
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>TESIS</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="icon" href="/tesis/iconos/icono.png" type="png">
        <link rel="stylesheet" href="/tesis/estilo/dist/css/adminlte.min.css">
        <link rel="stylesheet" href="/tesis/estilo/plugins/overlayScrollbars/css/OverlayScrollbars.min.css">
        <link rel="stylesheet" href="/tesis/estilo/descarga/font-google.css">
        <link rel="stylesheet" href="/tesis/estilo/plugins/sweetalert2/sweetalert2.min.css">
        <link rel="stylesheet" href="/tesis/estilo/plugins/toastr/toastr.min.css">
        <link rel="stylesheet" href="/tesis/estilo/plugins/select2/css/select2.min.css">
        <link rel="stylesheet" href="/tesis/estilo/descarga/tabla1.min.css">
        <link rel="stylesheet" href="/tesis/estilo/descarga/tabla2.min.css">
    </head>
    <body class="hold-transition sidebar-mini layout-fixed sidebar-collapse">
        <div class="wrapper">
            <?php include ("{$_SERVER['DOCUMENT_ROOT']}/tesis/cabecera.php"); ?>
            <?php include ("{$_SERVER['DOCUMENT_ROOT']}/tesis/menu.php"); ?>
            <div class="content-wrapper">
                <div class="content-header">
                    <div class="container-fluid">
                        <div class="row mb-2">
                            <div class="col-sm-6">
                                <h1 class="m-0 text-dark">CIUDADES</h1>
                            </div>
                            <div class="col-sm-6">
                                <ol class="breadcrumb float-sm-right">
                                    <li class="breadcrumb-item active">Referenciales Archivos</li>
                                    <li class="breadcrumb-item active">Ciudades</li>
                                </ol>
                            </div>
                        </div>
                    </div>
                </div>
                <section class="content">
                    <div class="card">
                        <div class="card-header">
                            <button type="button" class="btn btn-success" onclick="agregar();">
                                <i class="fas fa-plus-circle"></i> Agregar
                            </button>
                            <input type="hidden" id="operacion" value="0">
                            <!-- colocar en id el codigo de la referencia trabajada -->
                            <input type="hidden" id="id_ciudad" value="0">
                            <input type="hidden" id="btn-modal-agregar" data-toggle="modal" data-target="#modal-agregar">
                            <input type="hidden" id="btn-modal-editar" data-toggle="modal" data-target="#modal-editar">
                        </div>
                        <div class="card-body" id="div_datos">

                        </div>
                    </div>
                    <div class="modal fade" id="modal-agregar">

                    </div>
                    <div class="modal fade" id="modal-editar">

                    </div>
                </section>
            </div>
            <footer class="main-footer">
                <strong>Copyright &copy; <?php echo date('Y'); ?> <a href="#">TESIS</a></strong>
            </footer>
        </div>
        <script src="/tesis/estilo/plugins/jquery/jquery.min.js"></script>
        <script src="/tesis/estilo/plugins/jquery-ui/jquery-ui.min.js"></script>
        <script> $.widget.bridge('uibutton', $.ui.button) </script>
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
        <?php include("../../mensaje.php"); ?>
        <script src="funciones.js"></script>
    </body>
</html>