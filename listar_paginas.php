<?php 
include './Conexion.php';
include './session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();

$filtro = $_GET['filtro'] ?? '';
$query = pg_fetch_all(pg_query($conn, "SELECT * FROM v_permisos 
                            WHERE id_grupo=" . $_SESSION['id_grupo'] . "
                            AND estado= 'ACTIVO' AND id_accion= 1 AND pag_descrip ILIKE '$filtro%' order by mod_orden, id_pagina"));

echo json_encode($query);
pg_close($conn);
?>