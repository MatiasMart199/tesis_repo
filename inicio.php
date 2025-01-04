<?php
include './Conexion.php';
include './session.php';

$compras = pg_fetch_all(pg_query($conn, "SELECT count(id_cc) FROM v_compras_cab WHERE estado = 'CONFIRMADO'"));
$inscrip = pg_fetch_all(pg_query($conn, "SELECT count(id_inscrip) FROM v_servicios_inscripciones WHERE estado = 'CONFIRMADO'"));
?>
<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>ENERGYM</title>
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
                            <h1 class="m-0 text-dark">ENERGYM</h1>


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
                    <!-- ---------------------------------------------------------------------------------------------------------------------------------- -->

                    <div class="row">
                        <div class="col-lg-3 col-6">
                            <!-- small box -->
                            <div class="small-box bg-info">
                                <div class="inner d-flex align-items-center justify-content-between">
                                    <div>
                                        <h3><?= $compras[0]['count'] ?></h3>
                                        <p>Compras</p>
                                    </div>
                                    <div class="icon">
                                        <i class="fa fa-cart-plus fa-3x"></i>
                                    </div>
                                </div>
                                <a href="/tesis/compra/compras_facturacion/" class="small-box-footer">
                                    More info <i class="fas fa-arrow-circle-right"></i>
                                </a>
                            </div>
                        </div>

                        <!-- ./col -->
                        <div class="col-lg-3 col-6">
                            <!-- small box -->
                            <div class="small-box bg-warning">
                                <div class="inner d-flex align-items-center justify-content-between">
                                    <div>
                                        <h3><?= $inscrip[0]['count'] ?></h3>
                                        <p>Inscritos</p>
                                    </div>
                                    <div class="icon">
                                        <i class="fa fa-address-card fa-3x"></i>
                                    </div>
                                </div>
                                <a href="/tesis/servicio/inscripciones/" class="small-box-footer">More info <i class="fas fa-arrow-circle-right"></i></a>
                            </div>
                        </div>

                        <!-- ./col -->
                        <div class="col-lg-3 col-6">
                            <!-- small box -->
                            <!-- <div class="small-box bg-success">
                                <div class="inner">
                                    <h3>53<sup style="font-size: 20px">%</sup></h3>

                                    <p>Bounce Rate</p>
                                </div>
                                <div class="icon">
                                    <i class="ion ion-stats-bars"></i>
                                </div>
                                <a href="#" class="small-box-footer">More info <i class="fas fa-arrow-circle-right"></i></a>
                            </div> -->
                        </div>

                        <!-- ./col -->
                        <div class="col-lg-3 col-6">
                            <!-- small box -->
                            <!-- <div class="small-box bg-danger">
                                <div class="inner">
                                    <h3>65</h3>

                                    <p>Unique Visitors</p>
                                </div>
                                <div class="icon">
                                    <i class="ion ion-pie-graph"></i>
                                </div>
                                <a href="#" class="small-box-footer">More info <i class="fas fa-arrow-circle-right"></i></a>
                            </div> -->
                        </div>
                        <!-- ./col -->
                    </div>

                    <!-- ------------------------------------------------------------------------------------------------------------------------------ -->
                </div>
            </section>
        </div>
        <footer class="main-footer">
            <strong>Copyright &copy; 2023 <a href="#">Tesis</a></strong>
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
</body>

</html>