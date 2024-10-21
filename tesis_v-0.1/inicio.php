<?php
include './Conexion.php';
include './session.php';
?>
<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Tesis</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="/tesis/iconos/icono.jpg" type="jpg">
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
        <!--CABEZERA INICIO-->
        <?php include './cabecera.php'; ?>
        <!--CABEZERA FINAL-->
        <!--MENU INICIO -->
        <?php include './menu.php'; ?>
        <!--MENU FINAL-->

        <div class="content-wrapper">
            <div class="content-header">
                <div class="container-fluid">
                    <div class="row mb-2">
                        <div class="col-sm-6">
                            <h1 class="m-0 text-dark">Tesis</h1>
                        </div>
                        <div class="col-sm-6">
                            <ol class="breadcrumb float-sm-right">
                                <li class="breadcrumb-item active"></li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>
            <section class="content">
                <div class="container-fluid">

                </div>
            </section>
        </div>
        <footer class="main-footer">
            <strong>Copyright &copy; 2023 <a href="#">Tesis</a></strong>
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
</body>

</html>