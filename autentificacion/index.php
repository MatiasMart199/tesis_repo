<?php
session_start();
if (isset($_SESSION['id_usuario'])) {
	if (!($_SESSION['id_usuario'] == null || $_SESSION['id_usuario'] == '')) {
		header('Location: /tesis/inicio.php');
	}
}

if (isset($_SESSION['mensaje'])) {
	if ($_SESSION['mensaje'] == null || $_SESSION['mensaje'] == '') {

	} else { //SI EXISTE EL LA VARIABLE MENSAJE
		$mensaje= "verificar_mensaje('{$_SESSION['mensaje']}');";
		$_SESSION['mensaje'] = '';
	}
}

?>
<!DOCTYPE html>
<html>

<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<title>ENERGYM</title>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="icon" href="/tesis/iconos/1.jpg" type="image/x-icon">
	<link rel="stylesheet" href="/tesis/estilo/plugins/icheck-bootstrap/icheck-bootstrap.min.css">
	<link rel="stylesheet" href="/tesis/estilo/dist/css/adminlte.min.css">
	<link rel="stylesheet" href="/tesis/estilo/descarga/font-google.css">
	<link rel="stylesheet" href="/tesis/estilo/plugins/sweetalert2/sweetalert2.min.css">
	<link rel="stylesheet" href="/tesis/estilo/plugins/toastr/toastr.min.css">
	<style>
		html, body {
        height: 100%;
        margin: 0;
        padding: 0;
    }

    .fondo {
        background-image: url('./imagenes/fondo-ondulado-azul.jpg');
        background-size: cover;
        background-position: center;
        height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
    }
	</style>
</head>

<body class="hold-transition login-page">
	<div class="fondo">
	<div class="login-box card-primary text-center">
		<div class="card-header">
			<h3 class="card-title">ENERGYM <i class="fas fa-user" aria-hidden="true"></i></h3>
		</div>
		<div class="card card-info">
			<div class="card-body">
				<p></p>
				<!-- AUTENTICACION DE 2 FACTOR -->
				<form action="login.php" method="post">
					<div class="input-group mb-3">
						<div class="input-group-prepend">
							<span class="input-group-text">
								<i class="far fa-user"></i>
							</span>
						</div>
						<input type="text" required="" name="a2f" class="form-control" placeholder="Codigo de Seguridad"
							autofocus="">
					</div>
					<div class="row">
						<button type="submit" class="btn btn-primary btn-block btn-flat">Ingresar</button>
					</div>
				</form>

			</div>
		</div>
	</div>
	<script src="/tesis/iconos/fontawesome.js"></script>
	<script src="/tesis/estilo/plugins/jquery/jquery.min.js"></script>
	<script src="/tesis/estilo/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
	<script src="/tesis/estilo/plugins/fastclick/fastclick.js"></script>
	<script src="/tesis/estilo/plugins/sweetalert2/sweetalert2.min.js"></script>
	<script src="/tesis/estilo/plugins/toastr/toastr.min.js"></script>
	<script>
		$(document).ready(function () {
				<?php echo $mensaje;
				$_SESSION['mensaje'] = '';
				?>
		});
		function verificar_mensaje(resultado) {
			$(function () {
				const Toast = Swal.mixin({
					toast: true,
					position: 'top-end',
					showConfirmButton: false,
					timer: 3000
				});

				// Aquí muestra el mensaje almacenado en resultado (que proviene de $_SESSION['mensaje'])
				Toast.fire({
					type: 'error',
					title: resultado
				});
			});
		}
	</script>
	</div>
</body>

</html>