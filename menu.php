<?php
$conexion = new Conexion();
$conn = $conexion->getConexion();

//$modulos = pg_fetch_all(pg_query($conn, "SELECT * FROM modulos ORDER BY id_modulo;"));

//INICIO AGREFADO
/*$paginas = null;
$lista_paginas = pg_fetch_all(pg_query($conn, "SELECT * FROM paginas ORDER BY id_pagina;"));

foreach ($lista_paginas as $l) {
    $paginas[$l['id_modulo']][$l['id_pagina']]['id_pagina'] = $l['id_pagina'];
    $paginas[$l['id_modulo']][$l['id_pagina']]['id_modulo'] = $l['id_modulo'];
    $paginas[$l['id_modulo']][$l['id_pagina']]['pag_descrip'] = $l['pag_descrip'];
    $paginas[$l['id_modulo']][$l['id_pagina']]['pag_ubicacion'] = $l['pag_ubicacion'];
    $paginas[$l['id_modulo']][$l['id_pagina']]['pag_icono'] = $l['pag_icono'];
}*/
//var_dump($modulos);
//var_dump($paginas);
//FIN AGREGADO
$permisos = pg_fetch_all(pg_query($conn, "SELECT * FROM v_permisos where id_grupo=" . $_SESSION['id_grupo'] . "AND estado= 'ACTIVO' AND id_accion= 1 order by mod_orden, pag_orden;"));

$modulos = null;
$paginas = null;
if (!empty($permisos)) {
    foreach ($permisos as $p) {
        $modulos[$p['id_modulo']]['id_modulo'] = $p['id_modulo'];
        $modulos[$p['id_modulo']]['mod_descrip'] = $p['mod_descrip'];
        $modulos[$p['id_modulo']]['mod_icono'] = $p['mod_icono'];
        $paginas[$p['id_modulo']][$p['id_pagina']]['id_pagina'] = $p['id_pagina'];
        $paginas[$p['id_modulo']][$p['id_pagina']]['pag_descrip'] = $p['pag_descrip'];
        $paginas[$p['id_modulo']][$p['id_pagina']]['pag_ubicacion'] = $p['pag_ubicacion'];
        $paginas[$p['id_modulo']][$p['id_pagina']]['pag_icono'] = $p['pag_icono'];
    }
}
?>


<!-- Navbar Search -->
<!-- <li class="nav-item">
    <a class="nav-link" data-widget="navbar-search" data-target="#navbar-search3" href="#" role="button">
        <i class="fas fa-search"></i>
    </a>
    <div class="navbar-search-block" id="navbar-search3">
        <form class="form-inline">
            <div class="input-group input-group-sm">
                <input class="form-control form-control-navbar" type="search" placeholder="Search" aria-label="Search">
                <div class="input-group-append">
                    <button class="btn btn-navbar" type="submit">
                        <i class="fas fa-search"></i>
                    </button>
                    <button class="btn btn-navbar" type="button" data-widget="navbar-search">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </div>
        </form>
    </div>
</li> -->

<aside class="main-sidebar elevation-4 sidebar-light-primary">
    <a href="/tesis/inicio.php" class="brand-link navbar-primary">
        <img src="/tesis/iconos/1.jpg" alt="LOGO" class="brand-image img-circle elevation-5">
        <span class="brand-text text-white">ENERGYM</span>
    </a>
    <div class="sidebar">
        <div class="user-panel mt-3 pb-3 mb-3 d-flex">
            <div class="image" alt="Imagen de Usuario">
                <img src="<?php echo $_SESSION['usu_imagen']; ?>" class="img-circle elevation-2">
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
                <img src="<?php echo $_SESSION['suc_imagen']; ?>" class="img-circle elevation-2">
            </div>
            <div class="info">
                <a class="d.block">
                    <?php echo $_SESSION['suc_nombre']; ?>
                </a>
            </div>
        </div>




        <nav class="mt-2">

            <!-- <form class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false">
                <div class="input-group mb-2 mr-sm-2">
                    <div class="input-group-prepend">
                        <div class="input-group-text"><i class="fas fa-search"></i></div>
                    </div>
                    <input class="form-control mr-sm-2" type="search" placeholder="Search" aria-label="Search"> -->
            <!-- <button class="btn btn-light" type="submit"><i class="fas fa-search"></i></button> -->
            <!-- </div>
            </form> -->

            <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false">
                <?php if (!empty($modulos)) {
                    foreach ($modulos as $m) { // Recorremos los módulos
                        if ($m['id_modulo'] == 5 || $m['id_modulo'] == 6 || $m['id_modulo'] == 7) {
                            continue;
                        }
                ?>
                        <li class="nav-item has-treeview">
                            <a href="#" class="nav-link">
                                <i class="nav-icon <?php echo $m['mod_icono']; ?>"></i>
                                <p>
                                    <?php echo $m['mod_descrip']; ?>
                                    <i class="right fas fa-angle-down"></i>
                                </p>
                            </a>
                            <ul class="nav nav-treeview">
                                <?php if (!empty($paginas)) {
                                    foreach ($paginas[$m['id_modulo']] as $p) { // Recorremos las páginas del módulo actual
                                ?>
                                        <li class="nav-item">
                                            <a href="<?php echo $p['pag_ubicacion']; ?>" class="nav-link">
                                                <i class="nav-icon <?php echo $p['pag_icono']; ?>"></i>
                                                <p>
                                                    <?php echo $p['pag_descrip']; ?>
                                                </p>
                                            </a>
                                        </li>
                                <?php
                                    }
                                }
                                ?>
                            </ul>
                        </li>
                    <?php
                    }
                } else { ?>
                    <li>
                        <a>
                            <label class="text-danger">
                                <i class="fa fa-exclamation-circle"></i> No se encuentra módulos
                            </label>
                        </a>
                    </li>
                <?php } ?>
            </ul>


            <!-- ----------------------------------------------------------------------------------------------- -->

            <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false">
                <!-- Menú principal: REFERENCIALES -->
                <li class="nav-item has-treeview">
                    <a href="#" class="nav-link">
                        <i class="nav-icon fas fa-database"></i>
                        <p>
                            REFERENCIALES
                            <i class="right fas fa-angle-down"></i>
                        </p>
                    </a>

                    <ul class="nav nav-treeview">
                        <?php
                        if (!empty($modulos)) {
                            $modulosReferenciales = [5, 6, 7]; // IDs de módulos referenciales

                            foreach ($modulos as $m) {
                                if (in_array($m['id_modulo'], $modulosReferenciales)) {
                        ?>
                                    <li class="nav-item has-treeview">
                                        <a href="#" class="nav-link">
                                            <i class="nav-icon <?= $m['mod_icono']; ?>"></i>
                                            <p>
                                                <?= $m['mod_descrip']; ?>
                                                <?php if (!empty($paginas[$m['id_modulo']])) { ?>
                                                    <i class="right fas fa-angle-down"></i>
                                                <?php } ?>
                                            </p>
                                        </a>

                                        <?php if (!empty($paginas[$m['id_modulo']])) { ?>
                                            <ul class="nav nav-treeview">
                                                <?php foreach ($paginas[$m['id_modulo']] as $p) { ?>
                                                    <li class="nav-item">
                                                        <a href="<?= $p['pag_ubicacion']; ?>" class="nav-link">
                                                            <i class="nav-icon <?= $p['pag_icono']; ?>"></i>
                                                            <p><?= $p['pag_descrip']; ?></p>
                                                        </a>
                                                    </li>
                                                <?php } ?>
                                            </ul>
                                        <?php } ?>
                                    </li>
                            <?php
                                }
                            }
                        } else {
                            ?>
                            <li class="nav-item">
                                <a href="#" class="nav-link">
                                    <i class="nav-icon fas fa-exclamation-circle text-danger"></i>
                                    <p class="text-danger">No se encuentran módulos</p>
                                </a>
                            </li>
                        <?php } pg_close($conn); ?>
                    </ul>
                </li>
            </ul>

        </nav>



    </div>
</aside>