<?php 
$conexion = new Conexion();
$conn= $conexion->getConexion();
$modulos= pg_fetch_all(pg_query($conn, "SELECT * FROM modulos ORDER BY id_modulo;"));
?>
<aside class="main-sidebar elevation-4 sidebar-light-primary">
            <a href="/tesis/inicio.php" class="brand-link navbar-primary">
                <img src="/tesis/iconos/logo.jpg" alt="LOGO" class="brand-image img-circle elevation-5">
                <span class="brand-text text-white">TESIS</span>
            </a>
            <div class="sidebar">
                <div class="user-panel mt-3 pb-3 mb-3 d-flex">
                    <div class="image" alt="Imagen de Usuario">
                        <img src="<?php echo $_SESSION['usu_imagen'];?>" class="img-circle elevation-2">
                    </div>
                    <div class="info">
                        <a class="d.block">
                            <?php echo $_SESSION['per_nombre'] . " " . $_SESSION['per_apellido']; ?><br>
                            <span class="text-muted">
                                <?php echo $_SESSION['car_descrip']; ?>
                            </span>
                        </a>
                    </div>
                </div>

                <div class="user-panel mt-3 pb-3 mb-3 d-flex">
                    <div class="image" alt="Imagen de Sucursal">
                        <img src="<?php echo $_SESSION['suc_imagen'];?>" class="img-circle elevation-2">
                    </div>
                    <div class="info">
                        <a class="d.block">
                            <?php echo $_SESSION['suc_nombre']; ?>
                        </a>
                    </div>
                </div>
                <nav class="mt-2">
                    <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false">
                        <?php if (!empty($modulos)) { ?>
                            <?php foreach($modulos  as $m){ ?>
                                <li class="nav-item has-treeview">
                                    <a href="#" class="nav-link">
                                        <i class="nav-icon <?php echo $m['mod_icono'];?>"></i></i>
                                        <p>
                                            <?php echo $m['mod_descrip']; ?>
                                            <i class="right fas fa-angle-down"></i>
                                        </p>
                                    </a>
                                </li>
                        <?php } ?>
                        <?php }else{ ?>
                            <li>
                                <a>
                                    <label class="text-danger">
                                        <i class="fa fa-exclamation-circle"></i> No se encuentra modulos
                                    </label>
                                </a>
                            </li>
                            <?php } ?>
                    </ul>
                </nav>

            </div>
        </aside>