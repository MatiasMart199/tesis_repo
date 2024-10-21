<?php 
include '../../Conexion.php';
include '../../session.php';
//$id_cp = $_GET['id_cp'];

$pedidos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra WHERE id_cp = 1;"));
$pedidos_detalles = pg_fetch_all(pg_query($conn, "SELECT * FROM v_pedidos_compra_detalles WHERE id_cp = ".$pedidos[0]['id_cp']." ORDER BY item_descrip, mar_descrip;"));

?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Example 1</title>
    <link rel="stylesheet" href="style.css" media="all" />
  </head>
  <body>
    <header class="clearfix">
        <div id="logo">
            <img src="logo2.png">
        </div>
        <h1>PEDIDO # <?php echo $pedidos[0]['id_cp']; ?></h1>
      <div id="company" class="clearfix">
      <div><?php echo $pedidos[0]['emp_denominacion']; ?></div>
        <div><?php echo $_SESSION['suc_direccion']; ?>,<br /> <?php echo $_SESSION['suc_ubicacion']; ?>, PY</div>
        <div><?php echo $_SESSION['suc_telefono']; ?></div>
        <div><a href="mailto:<?php echo $_SESSION['suc_correo'];?>"><?php echo $_SESSION['suc_correo'];?></a></div>
      </div>
      <div id="project">
        <div><span>FUNCIONARIO:   </span><?php echo $pedidos[0]['funcionario']; ?></div>
        <div><span>SUCURSAL:   </span> <?php echo $pedidos[0]['suc_nombre']; ?>, PY</div>
        <div><span>FECHA EMISION:   </span><?php echo $pedidos[0]['fecha']; ?></div>
        <div><span>FECHA APORBAD:   </span><?php echo $pedidos[0]['fecha_aprob']; ?></div>
      </div>
      </header>
    <main>
        <table>
            <thead>
                <tr>
                    <th class="desc">Producto</th>
                    <th>Cantidad</th>
                    <th>Precio Unitario</th>
                    <th>Subtotal</th>
                </tr>
            </thead>
            <tbody>
                <?php
                $total = 0;
                if (!empty($pedidos_detalles)) {
                    foreach ($pedidos_detalles as $d) {
                        $subtotal = $d['precio'] * $d['cantidad'];
                        $total += $subtotal;
                        ?>
                        <tr>
                            <td><?php echo $d['item_descrip'] . " - " . $d['mar_descrip']; ?></td>
                            <td><?php echo $d['cantidad']; ?></td>
                            <td><?php echo $d['precio']; ?></td>
                            <td><?php echo $subtotal; ?></td>
                        </tr>
                        <?php
                    }
                }
                ?>
                <tr>
                    <td colspan="3">TOTAL</td>
                    <td class="total"><?php echo $total; ?></td>
                </tr>
            </tbody>
        </table>
    </main>
    <footer>
        Invoice was created on a computer and is valid without the signature and seal.
    </footer>
</body>
