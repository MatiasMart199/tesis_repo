<div class="container-fluid">
    <div class="card">
        <div class="card-header">
            <h3 class="card-title"><i class="fa fa-chart-bar"></i> Gráfico de Compras</h3>
            <div class="card-tools">
                <button type="button" class="btn btn-tool" onclick="actualizarGrafico()">
                    <i class="fas fa-sync-alt"></i>
                </button>
            </div>
        </div>
        <div class="card-body">
            <div class="chart-container" style="position: relative; height: 400px; width: 100%;">
                <canvas id="grafico-data"></canvas>
            </div>
            <div id="info-grafico" class="mt-3 small text-muted text-center">
                <!-- Aquí se mostrará información del gráfico -->
            </div>
        </div>
    </div>
</div>

<script>
function actualizarGrafico() {
    console.log("🔄 Actualizando gráfico...");
    crearGrafico();
}
</script>