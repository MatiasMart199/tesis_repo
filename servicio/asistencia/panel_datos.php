<?php
include '../../Conexion.php';
include '../../session.php';
$id_sucursal = $_SESSION['id_sucursal'];
$conexion = new Conexion();
$conn = $conexion->getConexion();

$servicio = pg_fetch_all(pg_query($conn, "SELECT id_mem, id_cliente, cliente, per_ci FROM v_serv_membresias_cab;"));
?>
<div class="card card-primary">
    <div class="card-header text-center elevation-3">
        Asistencia
    </div>
    <div class="card-body">
        <input type="hidden" value="0" id="id_asi">
<!-----------------------------CAMPO DE FECHA Y HORA -------------------------------------------------->
        <div class="d-flex justify-content-center align-items-center">
            <div class="form-group text-center">
                <input
                    type="datetime"
                    class="form-control text-center"
                    id="hora_actual"
                    readonly
                    style="font-size: 2rem; font-weight: bold;">
            </div>
        </div>

        <div class="col-md-4 text-center mx-auto">
            <label for="per_ci" class="d-block">Nro de Documento</label>
            <input type="text" class="form-control" id="per_ci" placeholder="Ej: 12345678">
        </div>
        
        <input type="text" value="0" id="id_mem" hidden>
        <input type="text" value="0" id="id_cliente" hidden>
        <input type="text" value="N/A" id="nombre" disabled>

        <script>
            // Simula la consulta a la base de datos
            const servicios = <?= json_encode($servicio); ?>;

            // Función para autocompletar los campos
            document.getElementById('per_ci').addEventListener('input', function() {
                const ci = this.value.trim(); // Obtén el valor ingresado
                const result = servicios.find(servicio => servicio.per_ci === ci); // Busca coincidencia en los datos

                

                if (result) {
                    // Autocompleta los campos
                    document.getElementById('id_mem').value = result.id_mem;
                    document.getElementById('id_cliente').value = result.id_cliente;
                    document.getElementById('nombre').value = result.cliente;
                } else {
                    // Limpia los campos si no hay coincidencia
                    document.getElementById('id_mem').value = '';
                    document.getElementById('id_cliente').value = '';
                    document.getElementById('nombre').value = '';
                }
            });

            function enfocarCampo() {
                document.getElementById('per_ci').focus();
            }

            // Ejecutar la función para enfocar el campo cuando se cargue la página o se actualice
            document.addEventListener('DOMContentLoaded', enfocarCampo);

            // Función para actualizar la hora actual en tiempo real
            function actualizarHora() {
                const now = new Date(); // Fecha y hora actual
                const anhos = String(now.getFullYear()); // Años con 4 dígitos
                const meses = String(now.getMonth() + 1).padStart(2, '0'); // Meses con 2 dígitos
                const dias = String(now.getDate()).padStart(2, '0'); // Días con 2 dígitos
                const horas = String(now.getHours()).padStart(2, '0'); // Horas con 2 dígitos
                const minutos = String(now.getMinutes()).padStart(2, '0'); // Minutos con 2 dígitos
                const segundos = String(now.getSeconds()).padStart(2, '0'); // Segundos con 2 dígitos

                // Formato de hora: YYYY/MM/DD HH:MM:SS
                const horaFormateada = `${anhos}/${meses}/${dias} ${horas}:${minutos}:${segundos}`;
                document.getElementById('hora_actual').value = horaFormateada; // Actualiza el campo de hora
            }

            // Actualiza la hora cada segundo
            setInterval(actualizarHora, 1000);

            // Ejecuta la función para la hora al cargar
            actualizarHora();
        </script>

        <div class="form-group d-flex justify-content-between">
            <button class="btn btn-success" onclick="entrada();"><i class="fa fa-save"></i> ENTRADA</button>
            <button class="btn btn-danger" onclick="salida();"><i class="fa fa-save"></i> SALIDA</button>
        </div>
    </div>
</div>

<?php pg_close($conn); ?>