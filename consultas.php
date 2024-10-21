<?php 
require_once('Conexion.php');
$conexion = new Conexion();
$conn= $conexion->getConexion();
$paises = pg_fetch_all(pg_query($conn, "select * from paises order by id_pais;"),);
?>
<table border="1" width="100%">
    <tr>
        <th>#</th>
        <th>Descripción</th>
        <th>Gentilicio</th>
        <th>Código</th>
        <th>Estado</th>
        <th>Acciones</th>
    </tr>
    <?php if(!empty($paises)){
    foreach($paises as $p){ ?>
        <tr>
            <td><?php echo $p['id_pais']; ?></td>
            <td><?php echo $p['pais_descrip']; ?></td>
            <td><?php echo $p['pais_gentilicio']; ?></td>
            <td><?php echo $p['pais_codigo']; ?></td>
            <td><?php echo $p['estado']; ?></td>
            <td>
                <?php if($p['estado']=='ACTIVO'){ ?>
                    <button>Modificar</button>
                    <button>Inactivar</button>
                <?php }else {  ?>
                    <button>Activar</button>
                <?php } ?>
            </td>
        </tr>
        <?php }
        }else{?>
        <tr>
            <td colspan="6">NO SE ENCUENTRA DATOS EN LA TABLA</td>
        </tr>
        <?php } ?>
</table>
<?php if(!empty($paises)){ ?>
<label></br></br><?php echo $paises[0]['pais_descrip']; ?></label>
<?php }; ?>