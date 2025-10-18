// Variables globales
let datosGlobales = [];
let graficoInstance = null;
let dataTableInstance = null;

$(document).ready(function () {
    inicializarAplicacion();
});

// Función principal de inicialización
function inicializarAplicacion() {
    console.log("🚀 Inicializando aplicación...");
    
    // Cargar en secuencia para evitar conflictos
    panel_filtros().then(() => {
        return listar(); // Cargar datos iniciales
    }).then(() => {
        panel_graficos(); // Cargar gráficos
        configurarEventos(); // Configurar eventos
    }).catch(error => {
        console.error("Error en inicialización:", error);
    });
}

// Configurar eventos globales
function configurarEventos() {
    // Evento para pestañas de Bootstrap
    $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        const target = $(e.target).attr('href');
        console.log("Cambiando a pestaña:", target);
        
        if (target === '#panel-graficos') {
            setTimeout(() => {
                crearGrafico(); // Recrear gráfico al cambiar pestaña
            }, 100);
        }
    });
}

// Función para inicializar DataTable (corregida)
function formato_tabla(tabla, item_cantidad = 10, col_orden = 0, orden = "asc") {
    // Destruir instancia anterior si existe
    if (dataTableInstance) {
        dataTableInstance.destroy();
        $(tabla).empty();
    }
    
    dataTableInstance = $(tabla).DataTable({
        "destroy": true,
        "responsive": true,
        "lengthChange": false,
        "pageLength": item_cantidad,
        "order": [[col_orden, orden]],
        "dom": '<"row"<"col-sm-12 col-md-6"B><"col-sm-12 col-md-6"f>>rtip',
        "buttons": [
            {
                extend: 'copy',
                text: '<i class="fa fa-copy"></i> Copiar',
                className: 'btn btn-secondary btn-sm',
                exportOptions: {
                    columns: ':visible'
                }
            },
            {
                extend: 'excel',
                text: '<i class="fa fa-file-excel"></i> Excel',
                className: 'btn btn-success btn-sm',
                exportOptions: {
                    columns: ':visible'
                }
            },
            {
                extend: 'csv',
                text: '<i class="fa fa-file-csv"></i> CSV',
                className: 'btn btn-info btn-sm',
                exportOptions: {
                    columns: ':visible'
                }
            },
            {
                extend: 'pdf',
                text: '<i class="fa fa-file-pdf"></i> PDF',
                className: 'btn btn-danger btn-sm',
                exportOptions: {
                    columns: ':visible'
                }
            },
            {
                extend: 'print',
                text: '<i class="fa fa-print"></i> Imprimir',
                className: 'btn btn-dark btn-sm',
                exportOptions: {
                    columns: ':visible'
                }
            }
        ],
        "language": {
            "sProcessing": "Procesando...",
            "sLengthMenu": "Mostrar _MENU_ registros",
            "sZeroRecords": "No se encontraron resultados",
            "sEmptyTable": "Ningún dato disponible en esta tabla",
            "sInfo": "Mostrando del _START_ al _END_ de _TOTAL_ registros",
            "sInfoEmpty": "Mostrando 0 registros",
            "sInfoFiltered": "(filtrado de _MAX_ registros totales)",
            "sSearch": "Buscar:",
            "oPaginate": {
                "sFirst": "Primero",
                "sLast": "Último",
                "sNext": "Siguiente",
                "sPrevious": "Anterior"
            }
        },
        "initComplete": function() {
            console.log("✅ DataTable inicializado correctamente");
        }
    });
    
    return dataTableInstance;
}

// Panel de filtros (mejorado)
function panel_filtros() {
    return new Promise((resolve, reject) => {
        $.ajax({
            url: "filtros.php",
            beforeSend: function() {
                $("#panel-filtros").html(`
                    <div class="text-center py-4">
                        <i class="fas fa-spinner fa-spin fa-2x text-primary"></i>
                        <p class="mt-2">Cargando filtros...</p>
                    </div>
                `);
            }
        }).done(function (resultado) {
            $("#panel-filtros").html(resultado);
            
            // Configurar evento del botón filtrar después de cargar el HTML
            setTimeout(() => {
                if (typeof btnFiltrar === 'function') {
                    // El evento ya está en el HTML, no necesita re-asignación
                    console.log("✅ Filtros cargados correctamente");
                }
            }, 100);
            
            resolve();
        }).fail(function(xhr, status, error) {
            console.error("❌ Error cargando filtros:", error);
            $("#panel-filtros").html(`
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-triangle"></i> Error al cargar los filtros
                </div>
            `);
            reject(error);
        });
    });
}

// Panel de gráficos (mejorado)
function panel_graficos() {
    $.ajax({
        url: "graficos.php",
        beforeSend: function() {
            $("#panel-graficos").html(`
                <div class="text-center py-4">
                    <i class="fas fa-spinner fa-spin fa-2x text-primary"></i>
                    <p class="mt-2">Cargando gráficos...</p>
                </div>
            `);
        }
    }).done(function (resultado) {
        $("#panel-graficos").html(resultado);
        console.log("✅ Panel de gráficos cargado");
        
        // Crear gráfico solo si hay datos
        if (datosGlobales.length > 0) {
            setTimeout(() => {
                crearGrafico();
            }, 200);
        }
    }).fail(function(xhr, status, error) {
        console.error("❌ Error cargando gráficos:", error);
        $("#panel-graficos").html(`
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-triangle"></i> Error al cargar los gráficos
            </div>
        `);
    });
}

// Función principal para listar datos (corregida)
// Función principal para listar datos (CORREGIDA)
function listar(id_deposito = 1) {
    return new Promise((resolve, reject) => {
        $.ajax({
            method: "POST",
            url: "datos.php",
            data: { id_deposito: id_deposito }, // ✅ objeto
            dataType: "json",
            beforeSend: function() {
                $("#grilla_datos").html(`
                    <tr>
                        <td colspan="5" class="text-center">
                            <i class="fas fa-spinner fa-spin"></i> Cargando datos...
                        </td>
                    </tr>
                `);
            }
        }).done(function (resultado) {
            console.log("📊 Datos recibidos:", resultado);
            datosGlobales = resultado; // Almacenar datos globalmente

            mostrarDatosEnTabla(resultado); // tu función para renderizar la tabla
            resolve(resultado);
            
        }).fail(function (xhr, status, error) {
            console.error("❌ Error cargando datos:", error);
            $("#grilla_datos").html(`
                <tr>
                    <td colspan="5" class="text-center text-danger">
                        <i class="fas fa-exclamation-triangle"></i> Error al cargar los datos
                    </td>
                </tr>
            `);
            reject(error);
        });
    });
}


// Función para mostrar datos en tabla (CORREGIDA)
function mostrarDatosEnTabla(datos) {
    console.log("🔄 Mostrando datos en tabla, cantidad:", datos.length);
    
    // Destruir DataTable existente SI existe
    if (dataTableInstance) {
        console.log("🗑️ Destruyendo DataTable anterior");
        dataTableInstance.destroy();
        dataTableInstance = null;
        
        // Limpiar la tabla completamente
        $("#tablaResultados").empty();
        
        // Recrear la estructura básica de la tabla
        $("#tablaResultados").html(`
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Item</th>
                    <th>Cantidad</th>
                    <th>Deposito</th>
                    <th>Precio</th>
                </tr>
            </thead>
            <tbody id="grilla_datos"></tbody>
        `);
    }

    let lineas = "";

    if (!datos || datos.length === 0) {
        lineas = `
            <tr>
                <td colspan="5" class="text-center text-muted">
                    <i class="fas fa-database"></i> No hay datos disponibles para el filtro seleccionado
                </td>
            </tr>
        `;
    } else {
        datos.forEach(rs => {
            lineas += `
                <tr>
                    <td>${escapeHtml(rs.id_item)}</td>
                    <td>${escapeHtml(rs.item_descrip)}</td>
                    <td>${escapeHtml(rs.stock_cantidad)}</td>
                    <td>${escapeHtml(rs.dep_descrip)}</td>
                    <td>${escapeHtml(rs.precio_venta)}</td>
                </tr>
            `;
        });
    }

    $("#grilla_datos").html(lineas);
    
    // Inicializar DataTable SOLO si hay datos
    if (datos && datos.length > 0) {
        console.log("✅ Inicializando nuevo DataTable");
        setTimeout(() => {
            dataTableInstance = formato_tabla("#tablaResultados", 10, 2, "desc");
        }, 100);
    } else {
        console.log("ℹ️ No hay datos, DataTable no se inicializa");
    }
}
// Función para filtrar (corregida)
function btnFiltrar() {
    const id_deposito = $("#id_sucursal").val();



    console.log("🔍 Aplicando filtro:", { id_deposito });
    
    // Mostrar loading
    mostrarAlerta("info", "Aplicando filtro...", true);

    listar(id_deposito).then(() => {
        // Actualizar gráfico si está en la pestaña activa
        if ($('#panel-graficos').hasClass('active')) {
            crearGrafico();
        }
        
        mostrarAlerta("success", "Filtro aplicado correctamente");
        
    }).catch(error => {
        mostrarAlerta("error", "Error al aplicar el filtro");
    });
}

// Función para crear gráfico (corregida)
function crearGrafico() {
    console.log("🎨 Creando gráfico con datos:", datosGlobales);
    
    // Verificar si el canvas existe
    const canvas = document.getElementById("grafico-data");
    if (!canvas) {
        console.error("❌ Canvas #grafico-data no encontrado");
        return null;
    }

    // Verificar si hay datos
    if (!datosGlobales || datosGlobales.length === 0) {
        console.warn("⚠️ No hay datos para el gráfico");
        mostrarMensajeGraficoVacio(canvas);
        return null;
    }

    // Preparar datos para el gráfico
    const datosPreparados = prepararDatosParaGrafico(datosGlobales);
    
    // Destruir gráfico anterior si existe
    if (graficoInstance) {
        graficoInstance.destroy();
    }

    // Crear nuevo gráfico
    const ctx = canvas.getContext("2d");
    try {
        graficoInstance = new Chart(ctx, {
            type: "bar",
            data: {
                labels: datosPreparados.labels,
                datasets: [{
                    label: "Monto Total (Gs.)",
                    data: datosPreparados.valores,
                    backgroundColor: "rgba(54, 162, 235, 0.6)",
                    borderColor: "rgba(54, 162, 235, 1)",
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { 
                        position: "top",
                        labels: {
                            font: {
                                size: 12
                            }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function (context) {
                                const value = context.raw || 0;
                                return `${context.dataset.label}: ${new Intl.NumberFormat("es-PY").format(value)}`;
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function (value) {
                                return new Intl.NumberFormat("es-PY").format(value);
                            }
                        }
                    },
                    x: {
                        ticks: {
                            maxRotation: 45,
                            minRotation: 45
                        }
                    }
                }
            }
        });
        
        console.log("✅ Gráfico creado exitosamente");
        return graficoInstance;
        
    } catch (error) {
        console.error("❌ Error al crear gráfico:", error);
        mostrarMensajeGraficoError(canvas);
        return null;
    }
}

// Función para preparar datos del gráfico
function prepararDatosParaGrafico(datos) {
    const labels = [];
    const valores = [];

    datos.forEach(item => {
        labels.push(item.item_descrip);
        
        // Convertir formato numérico (1.000.000,00 → 1000000.00)
        const montoLimpio = item.stock_cantidad.toString()
            .replace(/\./g, '')  // Eliminar puntos de miles
            .replace(',', '.');  // Convertir coma decimal a punto
            
        const montoNumerico = parseFloat(montoLimpio);
        valores.push(isNaN(montoNumerico) ? 0 : montoNumerico);
    });

    console.log("📈 Datos preparados:", { labels, valores });
    return { labels, valores };
}

// Función para mostrar mensaje cuando no hay datos en el gráfico
function mostrarMensajeGraficoVacio(canvas) {
    const ctx = canvas.getContext("2d");
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    ctx.font = "16px Arial";
    ctx.fillStyle = "#6c757d";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText("No hay datos para mostrar", canvas.width / 2, canvas.height / 2);
}

// Función para mostrar error en el gráfico
function mostrarMensajeGraficoError(canvas) {
    const ctx = canvas.getContext("2d");
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    ctx.font = "14px Arial";
    ctx.fillStyle = "#dc3545";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText("Error al cargar el gráfico", canvas.width / 2, canvas.height / 2);
}

// Función auxiliar para mostrar alertas
function mostrarAlerta(tipo, mensaje, persistente = false) {
    const iconos = {
        success: "check-circle",
        error: "exclamation-triangle",
        warning: "exclamation-circle",
        info: "info-circle"
    };

    const clases = {
        success: "alert-success",
        error: "alert-danger",
        warning: "alert-warning",
        info: "alert-info"
    };

    const alertaHTML = `
        <div class="alert ${clases[tipo]} alert-dismissible fade show">
            <i class="fas fa-${iconos[tipo]}"></i> ${mensaje}
            ${!persistente ? '<button type="button" class="close" data-dismiss="alert">&times;</button>' : ''}
        </div>
    `;

    // Mostrar en la parte superior del content-wrapper
    $(".content-wrapper").prepend(alertaHTML);
    
    if (!persistente) {
        setTimeout(() => {
            $(".alert").alert('close');
        }, 5000);
    }
}

// Función auxiliar para escape HTML (seguridad)
function escapeHtml(text) {
    if (text === null || text === undefined) return '';
    return text.toString()
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}