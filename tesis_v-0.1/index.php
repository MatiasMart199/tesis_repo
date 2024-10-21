<?php 
session_start();
if (isset($_SESSION['id_usuario'])) {
    if (!($_SESSION['id_usuario']==null || $_SESSION['id_usuario']== '')) {
        header('Location: /tesis/inicio.php');
    }
}

if (isset($_SESSION['mensaje'])) {
    if ($_SESSION['mensaje']==null || $_SESSION['mensaje']== '') {
        
    } else {//SI EXISTE EL LA VARIABLE MENSAJE
        $mensaje = $_SESSION['mensaje'];
        $_SESSION['mensaje'] = '';
    }  
}

?>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<title>Taller</title>
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="icon" href="/tesis/iconos/icono.jpg" type="image/x-icon">
		<link rel="stylesheet" href="/tesis/estilo/plugins/icheck-bootstrap/icheck-bootstrap.min.css">
	  	<link rel="stylesheet" href="/tesis/estilo/dist/css/adminlte.min.css">
		<link rel="stylesheet" href="/tesis/estilo/descarga/font-google.css">
		<link rel="stylesheet" href="/tesis/estilo/plugins/sweetalert2/sweetalert2.min.css">
	  	<link rel="stylesheet" href="/tesis/estilo/plugins/toastr/toastr.min.css">
	</head>
	<body class="hold-transition login-page">
		<div class="login-box card-primary text-center">
			<div class="card-header">
                            <h3 class="card-title">Taller <i class="fa fa-file" aria-hidden="true"></i></h3>
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
							<input type="text" required="" name="usuario" class="form-control" placeholder="Usuario" autofocus="">
						</div>
						<div class="input-group mb-3">
							<div class="input-group-prepend">
								<span class="input-group-text">
									<i class="fas fa-key"></i>
								</span>
							</div>
							<input type="password" required="" name="contrasena" class="form-control" placeholder="Contraseña">
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
	</body>
</html>