$(function () {
    panel_ajustes();
    panel_datos(-1);
});

function refrescar_select() {
    $(".select2").select2();
    $(".select2").attr("style", "width: 100%;");
}

function formato_tabla(tabla, item_cantidad) {
    $(tabla).DataTable({
        "lengthChange": false,
        responsive: "true",
        "iDisplayLength": item_cantidad,
        language: {
            "sSearch": "Buscar: ",
            "sInfo": "Mostrando resultados del _START_ al _END_ de un total de _TOTAL_ registros",
            "sInfoFiltered": "(filtrado de entre _MAX_ registros)",
            "sInfoEmpty": "No hay resultados",
            "oPaginate": {
                "sNext": "Siguiente",
                "sPrevious": "Anterior"
            }
        }
    });
}

function panel_ajustes() {
    $.ajax({
        url: "panel_ajustes.php"
    }).done(function (resultado) {
        $("#panel-ajustes").html(resultado);
        formato_tabla("#tabla_panel_ajustes", 5);
    });
}

function panel_datos(id_caju) {
    $.ajax({
        url: "panel_datos.php",
        type: "POST",
        data: {
            id_caju: id_caju
        }
    }).done(function (resultado) {
        $("#panel-datos").html(resultado);
        refrescar_select();
    });
}

function datos(id_caju) {
    panel_datos(id_caju);
    $("#btn-panel-datos").click();
}

// function generarInforme(id_caju) {
//     // Abre una nueva ventana del navegador con la URL que incluye el parámetro id_caju
//     //window.open('./reporte.php?id_caju=' + id_caju, '_blank');
//     window.open('../../reportes/compra/reporte.php?id_caju=' + id_caju, '_blank');
// }


function agregar() {
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function modificar_detalle(id_item) {
    var id_caju = $("#id_caju").val();
    $.ajax({
        url: "panel_modificar.php",
        type: "POST",
        data: {
            id_caju: id_caju,
            id_item: id_item
        }
    }).done(function (resultado) {
        $("#panel-modificar").html(resultado);
        $("#btn-panel-modificar").click();
    });
}

function agregar_grabar() {
    $("#operacion").val(1);
    grabar();
}

function modificar() {
    $("#operacion").val(2);
    grabar();
}

function confirmar() {
    $("#operacion").val(3);
    grabar();
}

function anular() {
    $("#operacion").val(4);
    grabar();
}

function agregar_detalles() {
    $("#operacion").val(5);
    grabar();
}

function modificar_detalle_grabar() {
    $("#operacion").val(6);
    grabar();
}

function eliminar_detalle(cod_item, cod_motivo) {
    $("#eliminar_id_item").val(cod_item);
    $("#eliminar_id_motivo").val(cod_motivo);
    $("#operacion").val(7);
    grabar();
}

function cancelar() {
    panel_datos(-1);
    $("#btn-panel-ajustes").click();
    mensaje("CANCELADO", "error");
}

function grabar() {
    var operacion = $("#operacion").val();
    var id_caju = '0';
    var aju_fecha = '2021-01-01';
    var aju_observacion = '0';
    var id_deposito = '0';
    var id_motivo = '0';
    var mot_tipo_ajuste = '0';
    var mot_descrip = '0';
    var id_item = '0';
    var cantidad = '0';
    if (operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4') {
        id_caju = $("#id_caju").val();
        aju_fecha = $("#aju_fecha").val();
        aju_observacion = $("#aju_observacion").val();
    }
    if (operacion == '5') {
        id_caju = $("#id_caju").val();
        id_item = $("#agregar_id_item").val();
        cantidad = $("#agregar_cantidad").val();
        id_deposito = $("#agregar_id_deposito").val();
        id_motivo = $("#agregar_mot_descrip").val();
        mot_descrip = $("#agregar_mot_descrip").val();
        mot_tipo_ajuste = $("#agregar_mot_tipo_ajuste").val();
        //item_precio = 0;$("#agregar_precio").val();
    }
    if (operacion == '6') {
        id_caju = $("#id_caju").val();
        id_item = $("#modificar_id_item").val();
        cantidad = $("#modificar_cantidad").val();
    }
    if (operacion == '7') {
        id_caju = $("#id_caju").val();
        id_item = $("#eliminar_id_item").val();
        id_motivo = $("#eliminar_id_motivo").val();
        console.log(id_caju, id_item, id_motivo);
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data: {
            id_caju: id_caju,
            aju_fecha: aju_fecha,
            aju_observacion: aju_observacion,
            id_deposito: id_deposito,
            id_motivo: id_motivo,
            mot_tipo_ajuste: mot_tipo_ajuste,
            mot_descrip: mot_descrip,
            id_item: id_item,
            cantidad: cantidad,
            operacion: operacion
        }
    }).done(function (resultado) {
        if (verificar_mensaje(resultado)) {
            //postgrabar(operacion);
        }
        postgrabar(operacion);
    }).fail(function (a, b, c) {
        //console.error(b);
        console.error("Error:", a, b, c); // Error detallado
    });
}

function postgrabar(operacion) {
    panel_ajustes();
    if (operacion == '1') {
        panel_datos(-2);
    }
    if (operacion == '2' || operacion == '5' || operacion == '6' || operacion == '7') {
        panel_datos($("#id_caju").val());
        if (operacion == '6') {
            $("#btn-panel-modificar-cerrar").click();
        }
    }
    if (operacion == '3' || operacion == '4') {
        panel_datos(-1);
        $("#btn-panel-ajustes").click();
    }
}





function filtrarMotivos() {
    const tipoAjusteSeleccionado = document.getElementById('agregar_mot_tipo_ajuste').value;
    const selectMotivo = document.getElementById('agregar_mot_descrip');

    // Limpiar las opciones actuales
    selectMotivo.innerHTML = '<option selected disabled>Seleccione Motivo</option>';

    // Filtrar motivos según el tipo de ajuste seleccionado
    motivos
        .filter(motivo => motivo.mot_tipo_ajuste === tipoAjusteSeleccionado)
        .forEach(motivo => {
            const option = document.createElement('option');
            option.value = motivo.id_motivo;
            option.textContent = motivo.mot_descrip;
            selectMotivo.appendChild(option);
        });
}


function actualizarProductos() {
    // Obtener el depósito seleccionado
    const depositoSeleccionado = document.getElementById('agregar_id_deposito').value;

    // Obtener el elemento <select> de productos
    const selectProductos = document.getElementById('agregar_id_item');

    // Limpiar las opciones actuales
    selectProductos.innerHTML = '<option selected="true" disabled="disabled">Seleccione Producto</option>';

    // Agregar las opciones de productos correspondientes al depósito seleccionado
    if (productosPorDeposito[depositoSeleccionado]) {
        productosPorDeposito[depositoSeleccionado].forEach(producto => {
            const option = document.createElement('option');
            option.value = producto.id_item;
            option.textContent = producto.item_descrip;
            selectProductos.appendChild(option);
        });
    }
}