
$(function () {
    panel_asistencias();
    panel_datos();
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

function panel_asistencias() {
    $.ajax({
        url: "panel_asistencias.php"
    }).done(function (resultado) {
        $("#panel-asistencias").html(resultado);
        formato_tabla("#tabla_panel_asistencias", 5);
    });
}

function panel_datos() {
    $.ajax({
        url: "panel_datos.php",
    }).done(function (resultado) {
        $("#panel-datos").html(resultado);
        //refrescar_select();
    });
}

function datos(id_asi) {
    panel_datos();
    $("#btn-panel-datos").click();
}

function agregar() {
    panel_datos(0);
    $("#btn-panel-datos").click();
}


function agregar_presupuesto_pedido(id_cp) {
    $("#id_cp").val(id_cp);
    $("#operacion").val(8);
    grabar();
    $("html, body").animate({ scrollTop: 0 }, "slow");
}

function entrada() {
    $("#operacion").val(1);
    grabar();
}

function salida() {
    $("#operacion").val(3);
    grabar();
}

function linpiarCampos() {
        document.getElementById('per_ci').value = '';
        document.getElementById('id_mem').value = '0';
        document.getElementById('id_cliente').value = '0';
        document.getElementById('nombre').value = 'N/A';

}
function modificar(id_asi) {
    $("#id_asi").val(id_asi);
    $("#operacion").val(2);
    grabar();
}

function confirmar() {
    $("#operacion").val(3);
    grabar();
}

// function anular() {
//     $("#operacion").val(4);
//     grabar();
// }

function agregar_detalles() {
    $("#operacion").val(5);
    grabar();
}

function modificar_detalle_grabar() {
    $("#operacion").val(6);
    grabar();
}

function anular(id_asi) {
    $("#id_asi").val(id_asi);
    $("#operacion").val(4);
    grabar();
}

function eliminar_presupuesto_pedido(id_item) {
    $("#eliminar_id_item").val(id_item);
    $("#operacion").val(11);
    grabar();
}

function cancelar() {
    panel_datos();
    $("#btn-panel-membresia").click();
    mensaje("CANCELADO", "error");
}

function grabar() {
    var operacion = $("#operacion").val();
    var id_asi = '0';
    var asi_entrada = '2023-03-03';
    var asi_salida = '2023-03-03';
    var id_cliente = '0';
    var nombre = '0';
    var id_mem = '0';
    if (operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4') {
        // id_asi = $("#id_asi").val();
        // asi_entrada = $("#hora_actual").val();
        // asi_salida = $("#hora_actual").val();
        // id_cliente = $("#id_cliente").val();
        // nombre = $("#nombre").val();
        // id_mem = $("#id_mem").val();
        if (operacion !== '' && $("#id_asi").val().trim() !== '') {
            id_asi = $("#id_asi").val();
        }
        if (operacion !== '' && $("#hora_actual").val().trim() !== '') {
            asi_entrada = $("#hora_actual").val();
        }
        if (operacion !== '' && $("#hora_actual").val().trim() !== '') {
            asi_salida = $("#hora_actual").val();
        }
        if (operacion !== '' && $("#id_cliente").val().trim() !== '') {
            id_cliente = $("#id_cliente").val();
        }
        if (operacion !== '' && $("#nombre").val().trim() !== '') {
            nombre = $("#nombre").val();
        }
        if (operacion !== '' && $("#id_mem").val().trim() !== '') {
            id_mem = $("#id_mem").val();
        }
        //console.log(id_asi);
        // console.log(asi_entrada);
        // console.log(asi_salida);
        // console.log(id_cliente);
        // console.log(nombre);
        // console.log(id_mem);
        // console.log(operacion);
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data: {
            id_asi: id_asi,
            asi_entrada: asi_entrada,
            asi_salida: asi_salida,
            id_cliente: id_cliente,
            nombre: nombre,
            id_mem: id_mem,
            operacion: operacion
        }
    }).done(function (resultado) {
        if (verificar_mensaje(resultado)) {
            //postgrabar(operacion);
        }
        postgrabar(operacion);
    }).fail(function (a, b, c) {
        console.error('Error:', a, b, c);
    });
}

function postgrabar(operacion) {
    panel_asistencias();
    if (operacion == '1' || operacion == '3') {
        //panel_datos();
        linpiarCampos();
        //$('#btn-panel-pedidos').click ();
    }
    if (operacion == '2') {
        //panel_datos();
        $("#btn-panel-modificar-cerrar").click();
    }
    if (operacion == '4') {
        //panel_asistencias();
    }
}





/****************************************************************************************************************/

//  // Función para autocompletar los campos
//  document.getElementById('per_ci').addEventListener('input', function() {
//     const ci = this.value.trim(); // Obtén el valor ingresado
//     const result = servicios.find(servicio => servicio.per_ci === ci); // Busca coincidencia en los datos

//     if (result) {
//         // Autocompleta los campos
//         document.getElementById('id_mem').value = result.id_mem;
//         document.getElementById('id_cliente').value = result.id_cliente;
//         document.getElementById('nombre').value = result.cliente;
//     } else {
//         // Limpia los campos si no hay coincidencia
//         document.getElementById('id_mem').value = '';
//         document.getElementById('id_cliente').value = '';
//         document.getElementById('nombre').value = '';
//     }
// });

// // Función para enfocar el campo Nro de Documento
// function enfocarCampo() {
//     document.getElementById('per_ci').focus(); // Enfoca el campo Nro de Documento
// }

// // Ejecutar al cargar la página para enfocar el campo
// window.onload = function() {
//     enfocarCampo();
// };

// // Función para actualizar la hora actual en tiempo real
// function actualizarHora() {
//     const now = new Date(); // Fecha y hora actual
//     const anhos = String(now.getFullYear()); // Años con 4 dígitos
//     const meses = String(now.getMonth() + 1).padStart(2, '0'); // Meses con 2 dígitos
//     const dias = String(now.getDate()).padStart(2, '0'); // Días con 2 dígitos
//     const horas = String(now.getHours()).padStart(2, '0'); // Horas con 2 dígitos
//     const minutos = String(now.getMinutes()).padStart(2, '0'); // Minutos con 2 dígitos
//     const segundos = String(now.getSeconds()).padStart(2, '0'); // Segundos con 2 dígitos

//     // Formato de hora: YYYY/MM/DD HH:MM:SS
//     const horaFormateada = `${anhos}/${meses}/${dias} ${horas}:${minutos}:${segundos}`;
//     document.getElementById('hora_actual').value = horaFormateada; // Actualiza el campo de hora
// }

// // Actualiza la hora cada segundo
// setInterval(actualizarHora, 1000);

// // Ejecuta la función para la hora al cargar
// actualizarHora();