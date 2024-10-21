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
                    <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu"
                        data-accordion="false">
                        <li class="nav-item has-treeview">
                            <a href="#" class="nav-link">
                                <i class="nav-icon fa fa-list-alt"></i>
                                <p>
                                    Compra
                                    <i class="right fas fa-angle-down"></i>
                                </p>
                            </a>
                            <ul class="nav nav-treeview">
                                <li class="nav-item">
                                    <a href="#" class="nav-link">
                                        <i class="far fa-circle nav-icon"></i>
                                        <p>Submenú 1</p>
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a href="#" class="nav-link">
                                        <i class="far fa-circle nav-icon"></i>
                                        <p>Submenú 2</p>
                                    </a>
                                </li>
                            </ul>
                        </li>
                        <li class="nav-item has-treeview">
                            <a href="#" class="nav-link">
                                <i class="nav-icon fa fa-list-alt"></i>
                                <p>
                                    Servicio
                                    <i class="right fas fa-angle-down"></i>
                                </p>
                            </a>
                            <ul class="nav nav-treeview">
                                <li class="nav-item">
                                    <a href="#" class="nav-link">
                                        <i class="far fa-circle nav-icon"></i>
                                        <p>Submenú 3</p>
                                    </a>
                                </li>
                            </ul>
                        </li>
                        <li class="nav-item has-treeview">
                            <a href="#" class="nav-link">
                                <i class="nav-icon fa fa-list-alt"></i>
                                <p>
                                    Venta
                                    <i class="right fas fa-angle-down"></i>
                                </p>
                            </a>
                            <ul class="nav nav-treeview">
                                <li class="nav-item">
                                    <a href="#" class="nav-link">
                                        <i class="far fa-circle nav-icon"></i>
                                        <p>Submenú 4</p>
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a href="#" class="nav-link">
                                        <i class="far fa-circle nav-icon"></i>
                                        <p>Submenú 5</p>
                                    </a>
                                </li>
                            </ul>
                        </li>
                    </ul>
                </nav>

            </div>
        </aside>