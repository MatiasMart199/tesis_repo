<?php 
// if(isset($_POST['usuario']) && isset($_POST['contrasena'])){
//     echo"SE RECIBIERON LOS PARAMETROS";
//     echo "<br><br>El usuario es: ".$_POST['usuario'];
//     echo "<br><br>La contraseña es : ".$_POST['contrasena'];
// }else{
//     echo"NO SE RECIBIERON LOS PARAMETROS";
// }

// if(isset($_POST['usuario']) && isset($_POST['contrasena'])){
//     require_once('Conexion.php');
//     $conexion = new Conexion();
//     $conn= $conexion->getConexion();
//     $usu= $_POST['usuario'];
//     $contra=$_POST['contrasena'];
//     $resul= pg_fetch_all(pg_query($conn, "select * from usuarios where usu_login = trim('$usu');"));
//     if (empty($resul)) {
//         echo "NO EXITE ESTE USUARIO";
//     } else {
//         echo "EXITE ESTE USUARIO EL USUARIO: $usu Y CONTRASEÑA $contra";
//     }
    
// }else{
//     header('Location: /conexionphp');
// }
// session_start();
// if(isset($_POST['usuario']) && isset($_POST['contrasena'])){
//     require_once('Conexion.php');
//     $conexion = new Conexion();
//     $conn= $conexion->getConexion();
//     $usu= $_POST['usuario'];
//     $contra=$_POST['contrasena'];
//     $resul= pg_fetch_all(pg_query($conn, "select * from usuarios where usu_login = trim('$usu');"));

//     if (empty($resul)) {    //SI NO EXISTE EL USUARIO
//         $_SESSION['mensaje']="NO EXISTE EL USUARIO";
//         header('Location: /tesis');
//     } else {

//         if($resul[0]['usu_contrasena'] == md5($contra)){
//             $_SESSION['id_usuario']= $resul[0]['id_usuario'];
//             header('Location: /tesis/inicio.php');
            
            
//         }else{ //SI LA CONTRASEÑA NO COINCIDE
//             $_SESSION['mensaje']="LA CONTRASEÑA NO COINCIDE";
//             header('Location: /tesis');
//         }
//     }
    
// }else{//SI NO LLEGA LOS PARAMETROS
//     $_SESSION['mensaje']="NO LLEGA LOS PARAMETROS";
//     header('Location: /tesis');
// }


session_start();
if (isset($_POST['usuario']) && isset($_POST['contrasena'])) {
    require_once('Conexion.php');
    $conexion = new Conexion();
    $conn = $conexion->getConexion();
    $usu = $_POST['usuario'];
    $contra = $_POST['contrasena'];

    $resul = pg_fetch_all(pg_query($conn, "SELECT * FROM usuarios WHERE usu_login = trim('$usu');"));
    if (empty($resul)) {    // SI NO EXISTE EL USUARIO
        $_SESSION['mensaje'] = "NO EXISTE EL USUARIO";
        header('Location: /tesis');

    } else {
        if ($resul[0]['usu_contrasena'] == md5($contra)) {
            $_SESSION['id_usuario'] = $resul[0]['id_usuario'];
            header('Location: /tesis/inicio.php');

        } else { // SI LA CONTRASEÑA NO COINCIDE
            $_SESSION['mensaje'] = "LA CONTRASEÑA NO COINCIDE";
            header('Location: /tesis');

        }
    }
} 


?>