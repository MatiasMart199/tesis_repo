<div class="row">
    <div class="col-md-3">
        <div class="form-group">
            <label for="fecha_inicio">Fecha Desde:</label>
            <input type="date" id="fecha_inicio" class="form-control" value="<?php echo date('Y-m-01'); ?>">
        </div>
    </div>
    <div class="col-md-3">
        <div class="form-group">
            <label for="fecha_fin">Fecha Hasta:</label>
            <input type="date" id="fecha_fin" class="form-control" value="<?php echo date('Y-m-d'); ?>">
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
                        <th>Proveedor</th>
                        <th>Fecha</th>
                        <th>Monto Total</th>
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