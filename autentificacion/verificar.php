<?php 
session_start();
require_once '../Conexion.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['codigo'])) {
    $codigo = trim($_POST['codigo']);
    $idUsuario = $_SESSION['id_usuario'] ?? null;

    if (!$idUsuario) {
        $_SESSION['mensaje'] = "Sesión expirada. Por favor, inicia sesión nuevamente.";
        header('Location: /tesis/index.php');
        exit();
    }

    $conexion = new Conexion();
    $conn = $conexion->getConexion();

    // Verificar código en la base de datos
    $query = "SELECT codigo, fecha_expiracion FROM auth_2fa WHERE id_usuario = $1 AND codigo = $2";
    $result = pg_query_params($conn, $query, [$idUsuario, $codigo]);

    if ($result && $data = pg_fetch_assoc($result)) {
        $fechaActual = date('Y-m-d H:i:s');

        if ($fechaActual <= $data['fecha_expiracion']) {
            // Código válido: Limpiar el registro de 2FA
            $updateQuery = "UPDATE auth_2fa SET codigo = NULL, fecha_expiracion = NULL WHERE id_usuario = $1";
            pg_query_params($conn, $updateQuery, [$idUsuario]);

            // Redirigir al inicio
            header('Location: /tesis/inicio.php');
            exit();
        } else {
            $_SESSION['mensaje'] = "El código ha expirado.";
        }
    } else {
        $_SESSION['mensaje'] = "El código es incorrecto.";
    }
    header('Location: /tesis/autentificacion/index.php');
    exit();
}