$(function () {
    panel_ventas();
    panel_datos(-1);
});


function refrescar_select() {
    $(".select2").select2();
    $(".select2").attr("style", "width: 100%;");
}


function verificar_mensaje_intern(resultado) {
    var operacion = $("#operacion").val();
    //var response = JSON.parse(resultado);


    swal.fire({
        text: resultado.success ? resultado.message.replace("NOTICE: ", "") : resultado.message.replace("ERROR: ", ""),
        type: resultado.success ? 'success' : 'error',
        //timer: 5000
    });
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

function panel_ventas() {
    $.ajax({
        url: "./panel_ventas.php"
    }).done(function (resultado) {
        $("#panel-ventas").html(resultado);
        formato_tabla("#tabla_panel_ventas", 5);
        //tipoFactura.addEventListener("change", validarTipoFactura);
    });
}

function panel_datos(id_vc) {
    $.ajax({
        url: "panel_datos.php",
        type: "POST",
        data: {
            id_vc: id_vc
        }
    }).done(function (resultado) {
        $("#panel-datos").html(resultado);
        panel_ventas();
        refrescar_select();
        //tipoFactura.addEventListener("change", validarTipoFactura);
    });
}

// function panel_ordenes(){
//     $.ajax({
//         url:"./panel_ventas.php"
//     }).done(function(resultado){
//         $("#panel-ordenes").html(resultado);
//         formato_tabla("#tabla_panel_ventas", 5);
//     });
// }

function datos(id_vc) {
    panel_datos(id_vc);
    $("#btn-panel-datos").click();
}

function generarInforme(id_vc) {
    // Abre una nueva ventana del navegador con la URL que incluye el parámetro id_cp
    //window.open('./reporte.php?id_cp=' + id_cp, '_blank');
    window.open('reporte.php?id_vc=' + id_vc, '_blank');
}

function agregar() {
    panel_datos(0);
    $("#btn-panel-datos").click();
    //console.log('agregar() ejecutado');
}

function modificar_detalle(id_vc, id_item) {
    //var id_vc = $("#id_vc").val();
    $.ajax({
        url: "panel_modificar.php",
        type: "POST",
        data: {
            id_vc: id_vc,
            id_item: id_item
        }
    }).done(function (resultado) {
        $("#panel-modificar").html(resultado);
        $("#btn-panel-modificar").click();
    });
}

function modificar_detalle_ord(id_vc, id_item) {
    //var id_vc = $("#id_vc").val();
    $.ajax({
        url: "panel_modificar_ord.php",
        type: "POST",
        data: {
            id_vc: id_vc,
            id_item: id_item
        }
    }).done(function (resultado) {
        $("#panel-modificar").html(resultado);
        $("#btn-panel-modificar").click();
    });
}

function modalSecund() {
    $.ajax({
        type: "POST",
        url: "./panel_secundario.php"
        // ejecuta el llamado
    }).done(function (resultado) {
        $("#panel-secund").html(resultado);
        $("#btn-panel-secund").click();
    }).fail(function (a, b, c) {
        console.log(c);
    });
}

function modalConsolidacion(id_vc) {
    $.ajax({
        type: "POST",
        url: "./panel_consolidacion.php",
        data: {
            id_vc: id_vc
        }
        // ejecuta el llamado
    }).done(function (resultado) {
        $("#panel-consolidacion").html(resultado);
        $("#btn-panel-consolidacion").click();
    });
}

function modalLibro(id_vc) {
    $.ajax({
        type: "POST",
        url: "./panel_libro.php",
        data: {
            id_vc: id_vc
        }
        // ejecuta el llamado
    }).done(function (resultado) {
        $("#panel-libro").html(resultado);
        $("#btn-panel-libro").click();
    });
}

function modalCuenta(id_vc) {
    $.ajax({
        type: "POST",
        url: "./panel_cuenta.php",
        data: {
            id_vc: id_vc
        }
        // ejecuta el llamado
    }).done(function (resultado) {
        $("#panel-cuenta").html(resultado);
        $("#btn-panel-cuenta").click();
    });
}

function agregar_compra_orden(id_vped) {
    $("#id_vped").val(id_vped);
    $("#operacion").val(8);
    grabar();
    //$("html, body").animate({ scrollTop: 0}, "slow");
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

function modificar_detalle_ord_grabar() {
    $("#operacion").val(9);
    grabar();
}


function eliminar_detalle(id_item) {
    $("#eliminar_id_item").val(id_item);
    $("#operacion").val(7);
    grabar();
}

function eliminar_presupuesto_pedido(id_item) {
    $("#eliminar_id_item").val(id_item);
    $("#operacion").val(11);
    grabar();
}

function generarLibroCuenta() {
    $("#operacion").val(12);
    grabar();
}

function cancelar() {
    panel_datos(-1);
    $("#btn-panel-ordenes").click();
    mensaje("CANCELADO", "error");
}

function grabar() {
    var operacion = $("#operacion").val();
    var id_vc = '0';
    var vc_fecha = '2023-03-03';
    var vc_intervalo = '0';
    var vc_nro_factura = '0';
    var vc_tipo_factura = '0';
    var vc_cuota = '0';
    var iva5 = '0';
    var iva10 = '0';
    var exenta = '0';
    var monto = '0';
    var saldo = '0';
    var id_tim = '0';
    var id_cliente = '0';
    var id_item = '0';
    var cantidad = '0';
    var precio = '0';
    var id_vped = '0';
    if (operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4') {
        id_vc = $("#id_vc").val();
        vc_fecha = $("#vc_fecha").val();
        vc_intervalo = $("#vc_intervalo").val();
        vc_nro_factura = $("#vc_nro_factura").val();
        id_tim = $("#id_tim").val();
        vc_tipo_factura = $("#vc_tipo_factura").val();
        vc_cuota = $("#vc_cuota").val();
        id_cliente = $("#id_cliente").val();
        id_vped = $("#id_vped").val() || 0;

        // iva5 = $("#total_iva5").val();
        // iva10 = $("#total_iva10").val();
        // exenta = $("#total_exenta").val();
        // monto = $("#total_pagar").val();
        // saldo = $("#total_pagar").val(); // SE RESTATA EL MONTO MENOS EL SALDO

        // Solo asignamos id_cp si el input tiene un valor válido y operacion == 3
        // if (operacion == '3' && $("#id_vped").val().trim() !== '') {
        //     id_vped = $("#id_vped").val();
        // }
        if (operacion == '3' && $("#total_iva5").val().trim() !== '') {
            iva5 = $("#total_iva5").val();
        }
        if (operacion == '3' && $("#total_iva10").val().trim() !== '') {
            iva10 = $("#total_iva10").val();
        }
        if (operacion == '3' && $("#total_exenta").val().trim() !== '') {
            exenta = $("#total_exenta").val();
        }
        if (operacion == '3' && $("#total_pagar").val().trim() !== '') {
            monto = $("#total_pagar").val();
            saldo = $("#total_pagar").val();
        }
        // console.log("id_vc " + id_vc);
        // console.log("vc_fecha " + vc_fecha);
        // console.log("vc_intervalo " + vc_intervalo);
        // console.log("vc_nro_factura " + vc_nro_factura);
        // console.log("id_tim " + id_tim);
        // console.log("vc_tipo_factura " + vc_tipo_factura);
        // console.log("vc_cuota " + vc_cuota);
        // console.log("id_cliente " + id_cliente);
        // console.log("id_vped " + id_vped);
        // console.log("iva5 " + iva5);
        // console.log("iva10 " + iva10);
        // console.log("exenta " + exenta);
        // console.log("monto " + monto);
        // console.log("saldo " + saldo);
    }
    if (operacion == '5') {
        id_vc = $("#id_vc").val();
        id_item = $("#agregar_id_item").val();
        cantidad = $("#agregar_cantidad").val();
        precio = $("#agregar_precio").val();
        id_deposito = $("#ag_id_deposito").val();

    }
    if (operacion == '6') {
        id_vc = $("#id_vc").val();
        id_item = $("#modificar_id_item").val();
        cantidad = $("#modificar_cantidad").val();
        precio = $("#modificar_precio").val();
        console.log(id_vc);
        console.log(id_item);
        console.log(cantidad);
        console.log(precio);
    }
    if (operacion == '7') {
        id_vc = $("#id_vc").val();
        id_item = $("#eliminar_id_item").val();
    }
    if (operacion == '8') {
        id_vc = $("#id_vc").val();
        id_vped = $("#id_vped").val();
        //id_deposito = $("#id_deposito").val();
    }
    if (operacion == '9') {
        id_vc = $("#id_vc").val();
        id_vped = $("#id_vped").val();
        id_item = $("#modificar_id_item").val();
        cantidad = $("#modificar_cantidad").val();
        precio = $("#modificar_precio").val();
    }
    if (operacion == '10') {
        id_vc = $("#id_vc").val();
        id_vped = $("#id_vped").val();
        id_item = $("#eliminar_id_item").val();
    }
    if (operacion == '11') {
        id_vc = $("#id_vc").val();
        id_vped = $("#id_vped").val();
        id_item = $("#eliminar_id_item").val();
    }
    if (operacion == '12') {// INSERTAR LIBRO DE COMPRAS Y CUENTA A PAGAR
        id_vc = $("#id_vc").val();
        cc_fecha = $("#cc_fecha").val();
        
        
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data: {
            id_vc: id_vc,
            vc_fecha: vc_fecha,
            vc_intervalo: vc_intervalo,
            vc_nro_factura: vc_nro_factura,
            vc_tipo_factura: vc_tipo_factura,
            vc_cuota: vc_cuota,
            iva5: iva5,
            iva10: iva10,
            exenta: exenta,
            monto: monto,
            saldo: saldo,
            id_cliente: id_cliente,
            id_tim: id_tim,
            id_item: id_item,
            cantidad: cantidad,
            precio: precio,
            id_vped: id_vped,
            operacion: operacion
        }
    }).done(function (resultado) {
        console.log(resultado); // Agregado para verificar la respuesta del servidor
        //let result = JSON.parse(resultado);
        if (verificar_mensaje(resultado)) {
              
        }
        postgrabar(operacion); 
    }).fail(function (a, b, c) {
        //console.error(b);
        console.error("Error:", a, b, c); // Error detallado
    });
}

function postgrabar(operacion) {
    panel_ventas();
    if (operacion == '1') {
        panel_datos(-2);
        //$('#btn-panel-pedidos').click ();
    }
    if (operacion == '2' || operacion == '5' || operacion == '6' || operacion == '7' || operacion == '8' || operacion == '9' || operacion == '10' || operacion == '11' || operacion == '12') {
        panel_datos($("#id_vc").val());
        if (operacion == '6' || operacion == '9') {
            $("#btn-panel-modificar-cerrar").click();
        }
    }
    if (operacion == '8') {
        $("#btn-modal-secund-cerrar").click();
    }
    if (operacion == '3' || operacion == '4') {
        panel_datos(-1);
        //location.reload();

    }
}

function validarTipoFactura() {
    $(document).ready(function () {
        $('#vc_tipo_factura').change(function () {
            const tipoFactura = $(this).val(); // Obtenemos el valor del tipo de factura

            if (tipoFactura === 'CREDITO') {
                $('#vc_cuota').prop('disabled', false).val(''); // Habilita el campo cuota
                $('#vc_intervalo').prop('disabled', false).val(''); // Habilita el campo
            } else {
                $('#vc_cuota').prop('disabled', true).val('0'); // Deshabilita y limpia el campo cuota
                $('#vc_intervalo').prop('disabled', true).val('0');
            }
        });
    });

}

function llenarPrecio() { 
    // Obtener el ID del producto seleccionado
    const articuloId = document.getElementById('agregar_id_item').value;
    const precio = document.getElementById('agregar_precio');
    // Buscar el producto correspondiente en el objeto datoStock
    const itemSeleccionado = artuculos.find(d => d.id_item == articuloId);

    if (itemSeleccionado) {
        precio.value = itemSeleccionado.precio_compra; // Asignar el valor del stock
    } else {
        precio.value = ''; // Limpiar el campo si no se encuentra
    }
}

$(document).ready(function() {
    $(document).on('change', '#agregar_id_item', function() {
        llenarPrecio();
    });
});

function llenarNroFactura() { 
    // Obtener el ID del producto seleccionado
    const timId = document.getElementById('id_tim').value;
    const nroFactura = document.getElementById('vc_nro_factura');
    // Buscar el producto correspondiente en el objeto datoStock
    const timbradoSelect = timbrados.find(d => d.id_tim == timId);

    if (timbradoSelect) {
        nroFactura.value = timbradoSelect.numero_factura; // Asignar el valor del stock
    } else {
        nroFactura.value = ''; // Limpiar el campo si no se encuentra
    }
}

$(document).ready(function() {
    $(document).on('change', '#id_tim', function() {
        llenarNroFactura();
    });
});

function filtrarTimbrado() {
    const tipoDocumento = document.getElementById('tip_doc').value;
    const selectTimbrado = document.getElementById('id_tim');

    // Limpiar las opciones actuales
    selectTimbrado.innerHTML = '<option selected disabled>SELECCIONE EL TIMBRADO</option>';

    // Filtrar timbrados según el tipo de documento seleccionado
    timbrados
        .filter(timbrado => timbrado.tim_documento == tipoDocumento)
        .forEach(timbrado => {
            const option = document.createElement('option');
            option.value = timbrado.id_tim;
            option.textContent = timbrado.tim_num_timbrado;
            selectTimbrado.appendChild(option);
        });

    // Actualizar select2 si está en uso
    //console.log(timbrados);
}

$(document).ready(function () {
    $(document).on('change', '#tip_doc', function () {
        filtrarTimbrado();
    });
});