<?php
include '../../Conexion.php';
include '../../session.php';
$conexion = new Conexion();
$conn = $conexion->getConexion();
$id_sucursal = $_SESSION['id_sucursal'];
$cabecera = pg_fetch_all(pg_query($conn, "SELECT * FROM v_deposito WHERE estado = 'ACTIVO' ORDER BY id_sucursal ASC;"));
?>
<div class="row">
    <div class="col-md-3">
        <div class="form-group">
            <label for="fecha_inicio">Deposito:</label>
            <select id="id_sucursal" class="form-control">
                <?php if(!empty($cabecera)){ foreach($cabecera as $p){ ?>
                <option value="<?php echo $p['id_sucursal']; ?>"><?php echo $p['dep_descrip']; ?></option>
                <?php } } ?>
            </select>
        </div>
    </div>
    <div class="col-md-3">
        <div class="form-group">
            <label>&nbsp;</label>
            <button class="btn btn-primary btn-block" onclick="btnFiltrar()">
                <i class="fas fa-filter"></i> Aplicar Filtro
            </button>
        </div>
    </div>
    <div class="col-md-3">
        <div class="form-group">
            <label>&nbsp;</label>
            <button class="btn btn-secondary btn-block" onclick="listar()">
                <i class="fas fa-sync"></i> Mostrar Todo
            </button>
        </div>
    </div>
</div>

<div class="row mt-3">
    <div class="col-12">
        <div class="table-responsive">
            <table id="tablaResultados" class="table table-bordered table-striped">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Item</th>
                        <th>Cantidad</th>
                        <th>Deposito</th>
                        <th>Precio</th>
                    </tr>
                </thead>
                <tbody id="grilla_datos">
                    <tr>
                        <td colspan="4" class="text-center text-muted">
                            <i class="fas fa-database"></i> Seleccione un filtro o haga clic en "Mostrar Todo"
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>