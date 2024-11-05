<?php
include '../../Conexion.php';
include '../../session.php';
$_SESSION['id_pagina'] = '25';
//include "../../permiso.php";
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
    <?php include("../../cabecera.php"); ?>
    <?php include("../../menu.php"); ?>
    <div class="content-wrapper">
      <div class="content-header">
        <div class="container-fluid">
          <div class="row mb-2">
            <div class="col-sm-6">
              <h1 class="m-0 text-dark">Presupuesto de Preparación</h1>
              <input type="hidden" id="operacion" value="0">
              <input type="hidden" id="btn-panel-modificar" data-toggle="modal" data-target="#panel-modificar">
              <input type="hidden" id="btn-panel-secund" data-toggle="modal" data-target="#panel-secund">
              <input type="hidden" id="btn-panel-consolidacion" data-toggle="modal" data-target="#panel-consolidacion">
            </div>
            <div class="col-sm-6">
              <ol class="breadcrumb float-sm-right">
                <li class="breadcrumb-item active">Servicio</li>
                <li class="breadcrumb-item active">Presupuesto de Preparación</li>
              </ol>
            </div>
          </div>
        </div>
      </div>
      <section class="content">
        <div class="card">
          <div class="card-header p-0">
            <ul class="nav nav-pills ml-auto p-2">
              <li class="nav-item"><a class="nav-link active" href="#panel-membresias" id="btn-panel-membresias"
                  data-toggle="tab">Presupuesto de Preparación</a></li>
              <li class="nav-item"><a class="nav-link" href="#panel-datos" id="btn-panel-datos"
                  data-toggle="tab">Datos</a></li>
                  <!-- <li class="nav-item"><a class="nav-link" href="#panel-pedidos" id="btn-panel-pedidos"
                  data-toggle="tab">Pedidos</a></li> -->
            </ul>
          </div>
          <div class="card-body">
            <div class="tab-content">
              <div class="tab-pane active" id="panel-membresias">
                <label class="text-danger"><i class="fa fa-exclamation-circle"></i> Cargando...</label>
              </div>
              <div class="tab-pane" id="panel-datos">
                <label class="text-danger"><i class="fa fa-exclamation-circle"></i> Seleccione un Presupuesto...</label>
              </div>
              <!-- <div class="tab-pane" id="panel-pedidos">
                <label class="text-danger"><i class="fa fa-exclamation-circle"></i> Seleccione un pedido...</label> -->
              </div>
            </div>
          </div>
        </div>
      </section>
      <div class="modal fade" id="panel-modificar">

      </div>
      <div class="modal fade" id="panel-secund">

      </div>
      <div class="modal fade" id="panel-consolidacion">

      </div>
    </div>
    <footer class="main-footer">
      <strong>Copyright &copy;
        <?php echo date('Y'); ?> <a href="#">TESIS</a>
      </strong>
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