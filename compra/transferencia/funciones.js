
$(function () {
    panel_transferencia();
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

function panel_transferencia() {
    $.ajax({
        url: "panel_transferencia.php"
    }).done(function (resultado) {
        $("#panel-transferencia").html(resultado);
        formato_tabla("#tabla_panel_transferencia", 5);
    });
}

function panel_datos(id_tra) {
    $.ajax({
        url: "panel_datos.php",
        type: "POST",
        data: {
            id_tra: id_tra
        }
    }).done(function (resultado) {
        $("#panel-datos").html(resultado);
        refrescar_select();
    });
}

function datos(id_tra) {
    panel_datos(id_tra);
    $("#btn-panel-datos").click();
}

function generarInforme(id_tra) {
    // Abre una nueva ventana del navegador con la URL que incluye el parámetro id_tra
    //window.open('./reporte.php?id_tra=' + id_tra, '_blank');
    window.open('../../reportes/compra/reporte.php?id_tra=' + id_tra, '_blank');
}


function agregar() {
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function modificar_detalle(id_tra, id_item) {
    var id_tra = $("#id_tra").val();
    $.ajax({
        url: "panel_modificar.php",
        type: "POST",
        data: {
            id_tra: id_tra,
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

function enviar() {
    $("#operacion").val(8);
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

function eliminar_detalle(cod_item) {
    $("#eliminar_id_item").val(cod_item);
    $("#operacion").val(7);
    grabar();
}

function cancelar() {
    panel_datos(-1);
    $("#btn-panel-transferencia").click();
    mensaje("CANCELADO", "error");
}

function grabar() {
    var operacion = $("#operacion").val();
    var id_tra = '0';
    var tra_fecha_elabo = '2021-01-01';
    var tra_fecha_salida = '2021-01-01';
    var tra_fecha_recep = '2021-01-01';
    var id_sucursal_ori = '0';
    var id_sucursal_des = '0';
    var id_deposito_ori = '0';
    var id_deposito_des = '0';
    var id_vehiculo = '0';
    var id_chofer = '0';
    var observacion = '0';
    var id_item = '0';
    var cantidad = '0';
    if (operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4' || operacion == '8') {
        id_tra = $("#id_tra").val();
        tra_fecha_elabo = $("#tra_fecha_elabo").val();
        tra_fecha_salida = $("#tra_fecha_salida").val();
        tra_fecha_recep = $("#tra_fecha_recep").val();
        id_sucursal_ori = $("#id_sucursal_ori").val();
        id_sucursal_des = $("#id_sucursal_des").val();
        id_deposito_ori = $("#id_deposito_ori").val();
        id_deposito_des = $("#id_deposito_des").val();
        id_vehiculo = $("#id_vehiculo").val();
        id_chofer = $("#id_chofer").val();
        observacion = $("#observacion").val();
        //console.log(id_tra, tra_fecha_elabo, tra_fecha_salida, tra_fecha_recep, id_sucursal_ori, id_sucursal_des, id_deposito_ori, id_deposito_des, id_vehiculo, id_chofer, observacion);
    }
    if (operacion == '5') {
        id_tra = $("#id_tra").val();
        id_item = $("#agregar_id_item").val();
        cantidad = $("#agregar_cantidad").val();
        //item_precio = 0;$("#agregar_precio").val();
    }
    if (operacion == '6') {
        id_tra = $("#id_tra").val();
        id_item = $("#modificar_id_item").val();
        cantidad = $("#modificar_cantidad").val();
    }
    if (operacion == '7') {
        id_tra = $("#id_tra").val();
        id_item = $("#eliminar_id_item").val();
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data: {
            id_tra: id_tra,
            tra_fecha_elabo: tra_fecha_elabo,
            tra_fecha_salida: tra_fecha_salida,
            tra_fecha_recep: tra_fecha_recep,
            id_sucursal_ori: id_sucursal_ori,
            id_sucursal_des: id_sucursal_des,
            id_deposito_ori: id_deposito_ori,
            id_deposito_des: id_deposito_des,
            id_vehiculo: id_vehiculo,
            id_chofer: id_chofer,
            observacion: observacion,
            id_item: id_item,
            cantidad: cantidad,
            operacion: operacion
        }
    }).done(function(resultado){
        if(verificar_mensaje(resultado)){
            //postgrabar(operacion);
        }
        postgrabar(operacion);
    }).fail(function (a, b, c) {
        //console.error(b);
        console.error("Error:", a, b, c); // Error detallado
    });
}

function postgrabar(operacion) {
    panel_transferencia();
    if (operacion == '1') {
        panel_datos(-2);
    }
    if (operacion == '2' || operacion == '5' || operacion == '6' || operacion == '7') {
        panel_datos($("#id_tra").val());
        if (operacion == '6') {
            $("#btn-panel-modificar-cerrar").click();
        }
    }
    if (operacion == '3' || operacion == '4') {
        panel_datos(-1);
        $("#btn-panel-transferencia").click();
    }
}

// function autoSucursal1() {
//     // Obtener el ID del depósito seleccionado
//     const idDeposito = document.getElementsByName('id_deposito_ori')[0].value; // Usamos [0] para acceder al primer elemento

//     // Buscar la sucursal correspondiente
//     const depositoSeleccionada = datoDeposito.find(d => d.id_sucursal == idDeposito); // Comparar con `==` para evitar problemas de tipo

//     if (depositoSeleccionada) {
//         // Rellenar el select de sucursales
//         const sucursalSelect = document.getElementsByName('id_sucursal_ori')[0]; // También usamos [0]
//         sucursalSelect.innerHTML = ''; // Limpiar opciones previas

//         const option = document.createElement('option');
//         option.value = depositoSeleccionada.id_sucursal;
//         option.textContent = depositoSeleccionada.suc_nombre;
//         option.selected = true; // Seleccionar automáticamente

//         sucursalSelect.appendChild(option);
//     }
// }

// function autoSucursal2() {
//     // Obtener el ID del depósito seleccionado
//     const idDeposito = document.getElementsByName('id_deposito_des')[0].value;

//     // Buscar la sucursal correspondiente
//     const depositoSeleccionada = datoDeposito.find(d => d.id_sucursal == idDeposito);

//     if (depositoSeleccionada) {
//         // Rellenar el select de sucursales
//         const sucursalSelect = document.getElementsByName('id_sucursal_des')[0];
//         sucursalSelect.innerHTML = ''; // Limpiar opciones previas

//         const option = document.createElement('option');
//         option.value = depositoSeleccionada.id_sucursal;
//         option.textContent = depositoSeleccionada.suc_nombre;
//         option.selected = true;

//         sucursalSelect.appendChild(option);
//     }
// }

function llenarStock() { 
    // Obtener el ID del producto seleccionado
    const articuloId = document.getElementById('agregar_id_item').value;

    // Buscar el producto correspondiente en el objeto datoStock
    const itemSeleccionado = datoStock.find(d => d.id_item == articuloId);

    // Actualizar el campo de stock si se encuentra el producto
    const inputStock = document.getElementById('idStock');
    if (itemSeleccionado) {
        inputStock.value = itemSeleccionado.stock_cantidad; // Asignar el valor del stock
    } else {
        inputStock.value = ''; // Limpiar el campo si no se encuentra
    }
}

function autoSucursal1() {
    // Obtener el ID de la factura seleccionada
    const idDeposito = document.getElementById('id_deposito_ori').value;

    // Buscar la factura correspondiente en el objeto datosCompras
    const depositoSeleccionada = datoDeposito.find(d => d.id_sucursal === idDeposito);
    

    if (depositoSeleccionada) {

        // Rellenar el proveedor
        const sucursalSelect = document.getElementById('id_sucursal_ori');
        sucursalSelect.innerHTML = ''; // Limpiar opciones previas
        const option = document.createElement('option');
        
        console.log(option);
        option.value = depositoSeleccionada.id_sucursal;
        option.textContent = depositoSeleccionada.suc_nombre;
        option.selected = true; // Seleccionar automáticamente
        sucursalSelect.appendChild(option);
    }
}

function autoSucursal2() {
    // Obtener el ID de la factura seleccionada
    const idDeposito = document.getElementById('id_deposito_des').value;

    // Buscar la factura correspondiente en el objeto datosCompras
    const depositoSeleccionada = datoDeposito.find(d => d.id_sucursal === idDeposito);

    if (depositoSeleccionada) {

        // Rellenar el proveedor
        const sucursalSelect = document.getElementById('id_sucursal_des');
        sucursalSelect.innerHTML = ''; // Limpiar opciones previas
        const option = document.createElement('option');
        option.value = depositoSeleccionada.id_sucursal;
        option.textContent = depositoSeleccionada.suc_nombre;
        option.selected = true; // Seleccionar automáticamente
        sucursalSelect.appendChild(option);
    }
}


