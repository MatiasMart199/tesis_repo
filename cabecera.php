<nav class="main-header navbar navbar-expand border-bottom navbar-dark navbar-primary">
    <ul class="navbar-nav">
        <!-- Botón de Menú -->
        <li class="nav-item">
            <a class="nav-link" data-widget="pushmenu" href="#"><i class="fas fa-bars"></i></a>
        </li>
    </ul>

    <!-- Buscador -->
    <ul class="navbar-nav ml-auto">
        <li class="nav-item">
            <div class="input-group">
                <div class="input-group-prepend">
                    <div class="input-group-text"><i class="fas fa-search"></i></div>
                </div>
                <input class="form-control" type="search" placeholder="Buscar..." aria-label="Buscar" id="buscador">
            </div>
            <!-- Resultados -->
            <ul id="resultado" style="display: none; max-height: 200px; overflow-y: auto; background: white; border: 1px solid #ccc; position: absolute; z-index: 1000; width: 100%; padding: 0; margin: 0; list-style: none;">
            </ul>
        </li>


        <!-- Notifications Dropdown Menu -->
        <!-- <li class="nav-item dropdown">
            <a class="nav-link" data-toggle="dropdown" href="#">
                <i class="far fa-bell"></i>
                <span class="badge badge-warning navbar-badge">15</span>
            </a>
            <div class="dropdown-menu dropdown-menu-lg dropdown-menu-right">
                <span class="dropdown-item dropdown-header">15 Notifications</span>
                <div class="dropdown-divider"></div>
                <a href="#" class="dropdown-item">
                    <i class="fas fa-envelope mr-2"></i> 4 new messages
                    <span class="float-right text-muted text-sm">3 mins</span>
                </a>
                <div class="dropdown-divider"></div>
                <a href="#" class="dropdown-item">
                    <i class="fas fa-users mr-2"></i> 8 friend requests
                    <span class="float-right text-muted text-sm">12 hours</span>
                </a>
                <div class="dropdown-divider"></div>
                <a href="#" class="dropdown-item">
                    <i class="fas fa-file mr-2"></i> 3 new reports
                    <span class="float-right text-muted text-sm">2 days</span>
                </a>
                <div class="dropdown-divider"></div>
                <a href="#" class="dropdown-item dropdown-footer">See All Notifications</a>
            </div>
        </li> -->

        <!-- Cerrar Sesión -->
        <li class="nav-item dropdown">
            <a class="nav-link" href="/tesis/logout.php" title="Cerrar Sesión">
                <i class="fa fa-user"></i>
                <i class="fas fa-sign-out-alt"></i>
            </a>
        </li>



    </ul>




</nav>
<script>
    document.getElementById('buscador').addEventListener('input', function() {
        const filtro = this.value.trim();
        const resultContainer = document.getElementById('resultado');

        if (!filtro) {
            resultContainer.style.display = 'none';
            resultContainer.innerHTML = '';
            return;
        }

        fetch(`listar_paginas.php?filtro=${encodeURIComponent(filtro)}`)
            .then(res => res.json())
            .then(data => {
                resultContainer.innerHTML = data.length ?
                    data.map(item =>
                        `<li style="padding: 5px; border-bottom: 1px solid #ddd;">
                            <a href="${item.pag_ubicacion}" style="text-decoration: none; color: black;">
                                ${item.mod_descrip} - ${item.pag_descrip}
                            </a>
                        </li>`).join('') :
                    '<li style="padding: 5px; color: red;">No se encontraron resultados.</li>';
                resultContainer.style.display = 'block';
            });
    });
</script>