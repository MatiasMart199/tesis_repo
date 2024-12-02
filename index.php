<!-- <?php
// session_start();
// if (isset($_SESSION['id_usuario'])) {
// 	if (!($_SESSION['id_usuario'] == null || $_SESSION['id_usuario'] == '')) {
// 		header('Location: /tesis/inicio.php');
// 	}
// }

// if (isset($_SESSION['mensaje'])) {
// 	if ($_SESSION['mensaje'] == null || $_SESSION['mensaje'] == '') {

// 	} else { //SI EXISTE EL LA VARIABLE MENSAJE
// 		$mensaje= "verificar_mensaje('{$_SESSION['mensaje']}');";
// 		$_SESSION['mensaje'] = '';
// 	}
// }

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
				<form action="login.php" method="post">
					<div class="input-group mb-3">
						<div class="input-group-prepend">
							<span class="input-group-text">
								<i class="far fa-user"></i>
							</span>
						</div>
						<input type="text" required="" name="usuario" class="form-control" placeholder="Usuario"
							autofocus="">
					</div>
					<div class="input-group mb-3">
						<div class="input-group-prepend">
							<span class="input-group-text">
								<i class="fas fa-key"></i>
							</span>
						</div>
						<input type="password" required="" name="contrasena" class="form-control"
							placeholder="Contraseña">
					</div>
					<div class="row">
						<button type="submit" class="btn btn-primary btn-block btn-flat">Ingresar</button>
					</div>
				</form>

				<!-- AUTENTICACION DE 2 FACTOR -->
				<!-- <form action="login.php" method="post">
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
				</form> -->

			<!-- </div>
		</div>
	</div>
	<script src="/tesis/iconos/fontawesome.js"></script>
	<script src="/tesis/estilo/plugins/jquery/jquery.min.js"></script>
	<script src="/tesis/estilo/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
	<script src="/tesis/estilo/plugins/fastclick/fastclick.js"></script>
	<script src="/tesis/estilo/plugins/sweetalert2/sweetalert2.min.js"></script>
	<script src="/tesis/estilo/plugins/toastr/toastr.min.js"></script> -->
	<!-- <script>
		$(document).ready(function () {
				<?php //echo $mensaje;
				//$_SESSION['mensaje'] = '';
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
</html> -->

<?php
session_start();
if (isset($_SESSION['id_usuario'])) {
    header('Location: /tesis/inicio.php');
    exit();
}

$mensaje = $_SESSION['mensaje'] ?? null;
unset($_SESSION['mensaje']);
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ENERGYM - Login</title>
    <link rel="icon" href="/tesis/iconos/1.jpg" type="image/x-icon">
    <link rel="stylesheet" href="/tesis/estilo/plugins/icheck-bootstrap/icheck-bootstrap.min.css">
    <link rel="stylesheet" href="/tesis/estilo/dist/css/adminlte.min.css">
    <link rel="stylesheet" href="/tesis/estilo/plugins/sweetalert2/sweetalert2.min.css">
    <style>
        body { height: 100%; margin: 0; display: flex; align-items: center; justify-content: center; }
        .fondo { background: url('./imagenes/fondo-ondulado-azul.jpg') center/cover no-repeat; width: 100%; height: 100vh; display: flex; justify-content: center; align-items: center; }
    </style>
</head>
<body>
    <div class="fondo">
        <div class="login-box">
            <div class="card">
                <div class="card-header text-center">
                    <h3 class="card-title">ENERGYM</h3>
                </div>
                <div class="card-body">
                    <form action="login.php" method="post">
                        <div class="mb-3">
                            <input type="text" name="usuario" class="form-control" placeholder="Usuario" required>
                        </div>
                        <div class="mb-3">
                            <input type="password" name="contrasena" class="form-control" placeholder="Contraseña" required>
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">Ingresar</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <?php if ($mensaje): ?>
        <script src="/tesis/estilo/plugins/sweetalert2/sweetalert2.min.js"></script>
        <script>
            Swal.fire({ icon: 'error', title: 'Error', text: '<?= htmlspecialchars($mensaje) ?>' });
        </script>
    <?php endif; ?>
</body>
</html>
