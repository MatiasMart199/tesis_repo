<?php
session_start();
if (!isset($_SESSION['id_usuario'])) {
    // Si no hay usuario logueado, redirigir a la página principal
    header('Location: /tesis/index.php');
    exit();
}

$mensaje = $_SESSION['mensaje'] ?? '';
$_SESSION['mensaje'] = ''; // Limpiar mensaje después de mostrarlo
?>
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verificación 2FA - ENERGYM</title>
    <link rel="icon" href="/tesis/iconos/1.jpg" type="image/x-icon">
    <link rel="stylesheet" href="/tesis/estilo/plugins/icheck-bootstrap/icheck-bootstrap.min.css">
    <link rel="stylesheet" href="/tesis/estilo/dist/css/adminlte.min.css">
    <link rel="stylesheet" href="/tesis/estilo/plugins/sweetalert2/sweetalert2.min.css">
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
                <h3 class="card-title">Verificación 2FA - ENERGYM</h3>
            </div>
            <div class="card card-info">
                <div class="card-body">
                    <p>Por favor, ingresa el código que se envió a tu correo electrónico.</p>

                    <!-- Formulario de verificación -->
                    <form action="verificar.php" method="POST">
                        <div class="input-group mb-3">
                            <div class="input-group-prepend">
                                <span class="input-group-text">
                                    <i class="fas fa-key"></i>
                                </span>
                            </div>
                            <input type="text" name="codigo" class="form-control" placeholder="Código de seguridad" required autofocus>
                        </div>
                        <div class="row">
                            <button type="submit" class="btn btn-primary btn-block">Verificar</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="/tesis/iconos/fontawesome.js"></script>
    <script src="/tesis/estilo/plugins/jquery/jquery.min.js"></script>
    <script src="/tesis/estilo/plugins/sweetalert2/sweetalert2.min.js"></script>
    <script>
        // Mostrar mensajes de error o éxito
        const mensaje = "<?php echo $mensaje; ?>";
        if (mensaje) {
            Swal.fire({
                icon: 'error',
                title: 'Error',
                text: mensaje,
                timer: 3000,
                showConfirmButton: false
            });
        }
    </script>
</body>

</html>
