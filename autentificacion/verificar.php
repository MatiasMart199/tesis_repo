<?php 
include '../Conexion.php';
include '../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();

if (isset($_POST['codigo'])) {
    $codigo = $_POST['codigo'];
    $id_usuario = $_SESSION['id_usuario'];

    $query = "SELECT * FROM auth_2fa WHERE id_usuario = $id_usuario AND codigo = $codigo";
    $resultado = pg_fetch_assoc(pg_query($conn, $query));
    if (!empty($resultado)) {
        $fechaExpiracion = date("Y-m-d H:i:s");

        if ($codigo == $resultado['codigo'] && $fechaExpiracion <= $resultado['fecha_expiracion']) {
           pg_fetch_all(pg_query($conn,"UPDATE auth_2fa 
            SET codigo = NULL, fecha_expiracion = NULL WHERE id_usuario = {$_SESSION['id_usuario']};"));
            
            header("Location: /tesis/inicio.php");
        } else {
            $_SESSION['mensaje'] = "Código expirado.";
            header("Location: /tesis/autentificacion");
        }
    } else {
        $_SESSION['mensaje'] = "Código incorrecto.";
        header("Location: /tesis/autentificacion");
    }
}
?>