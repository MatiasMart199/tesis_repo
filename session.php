<?php 
session_start();
if (isset($_SESSION['id_usuario'])) {
    $conexion = new Conexion();
    $conn= $conexion->getConexion();
    $resul= pg_fetch_all(pg_query($conn, "SELECT * FROM v_usuarios  WHERE id_usuario = ". $_SESSION['id_usuario']));
    $_SESSION['usu_login']= $resul[0]['usu_login'];
    $_SESSION['usu_imagen']= $resul[0]['usu_imagen'];
    $_SESSION['id_grupo']= $resul[0]['id_grupo'];
    $_SESSION['id_funcionario']= $resul[0]['id_funcionario'];
    $_SESSION['id_sucursal']= $resul[0]['id_sucursal'];
    $_SESSION['id_cargo']= $resul[0]['id_cargo'];
    $_SESSION['car_descrip']= $resul[0]['car_descrip'];
    $_SESSION['gru_descrip']= $resul[0]['gru_descrip'];
    $_SESSION['emp_ruc']= $resul[0]['emp_ruc'];
    $_SESSION['suc_nombre']= $resul[0]['suc_nombre'];
    $_SESSION['suc_direccion']= $resul[0]['suc_direccion'];
    $_SESSION['suc_telefono']= $resul[0]['suc_telefono'];
    $_SESSION['suc_correo']= $resul[0]['suc_correo'];
    $_SESSION['suc_ubicacion']= $resul[0]['suc_ubicacion'];
    $_SESSION['suc_imagen']= $resul[0]['suc_imagen'];
    $_SESSION['per_ruc']= $resul[0]['per_ruc'];
    $_SESSION['per_ci']= $resul[0]['per_ci'];
    $_SESSION['per_nombre']= $resul[0]['per_nombre'];
    $_SESSION['per_apellido']= $resul[0]['per_apellido'];
    $_SESSION['per_direccion']= $resul[0]['per_direccion'];
    $_SESSION['per_correo']= $resul[0]['per_correo'];
    $_SESSION['per_fenaci']= $resul[0]['per_fenaci'];
    $_SESSION['per_telefono']= $resul[0]['per_telefono'];
    $_SESSION['id_ciudad']= $resul[0]['id_ciudad'];
    $_SESSION['id_ecivil']= $resul[0]['id_ecivil'];
    $_SESSION['id_genero']= $resul[0]['id_genero'];
    $_SESSION['id_pais']= $resul[0]['id_pais'];
    $_SESSION['ciu_descrip']= $resul[0]['ciu_descrip'];
    $_SESSION['pais_descrip']= $resul[0]['pais_descrip'];
    $_SESSION['pais_gentilicio']= $resul[0]['pais_gentilicio'];
    $_SESSION['pais_codigo']= $resul[0]['pais_codigo'];
    $_SESSION['ec_descrip']= $resul[0]['ec_descrip'];
    $_SESSION['gen_descrip']= $resul[0]['gen_descrip'];
    $_SESSION['codigo']= $resul[0]['codigo'];
    $_SESSION['fecha_expiracion']= $resul[0]['fecha_expiracion'];

    }else {
    header("Location: /tesis");
    $_SESSION['mensaje']= "DEBES INICIAR SESION";
}

?>