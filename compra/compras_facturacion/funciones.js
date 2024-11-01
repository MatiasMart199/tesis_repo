
$(function () {
    panel_compras();
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

function panel_compras() {
    $.ajax({
        url: "./panel_compras.php"
    }).done(function (resultado) {
        $("#panel-compras").html(resultado);
        formato_tabla("#tabla_panel_compras", 5);
        //tipoFactura.addEventListener("change", validarTipoFactura);
    });
}

function panel_datos(id_cc) {
    $.ajax({
        url: "panel_datos.php",
        type: "POST",
        data: {
            id_cc: id_cc
        }
    }).done(function (resultado) {
        $("#panel-datos").html(resultado);
        panel_compras();
        refrescar_select();
        //tipoFactura.addEventListener("change", validarTipoFactura);
    });
}

// function panel_ordenes(){
//     $.ajax({
//         url:"./panel_compras.php"
//     }).done(function(resultado){
//         $("#panel-ordenes").html(resultado);
//         formato_tabla("#tabla_panel_compras", 5);
//     });
// }

function datos(id_cc) {
    panel_datos(id_cc);
    $("#btn-panel-datos").click();
}

function agregar() {
    panel_datos(0);
    $("#btn-panel-datos").click();
    //console.log('agregar() ejecutado');
}

function modificar_detalle(id_item) {
    var id_cc = $("#id_cc").val();
    $.ajax({
        url: "panel_modificar.php",
        type: "POST",
        data: {
            id_cc: id_cc,
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

function modalConsolidacion(id_cc) {
    $.ajax({
        type: "POST",
        url: "./panel_consolidacion.php",
        data: {
            id_cc: id_cc
        }
        // ejecuta el llamado
    }).done(function (resultado) {
        $("#panel-consolidacion").html(resultado);
        $("#btn-panel-consolidacion").click();
    });
}

function agregar_compra_orden(id_corden) {
    $("#id_corden").val(id_corden);
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

function generarLibroCuenta(id_cc) {
    $("#id_cc").val(id_cc);
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
    var id_cc = '0';
    var cc_fecha = '2023-03-03';
    var cc_intervalo = '0';
    var cc_nro_factura = '0';
    var cc_timbrado = '0';
    var cc_tipo_factura = '0';
    var cc_cuota = '0';
    var iva5 = '0';
    var iva10 = '0';
    var exenta = '0';
    var monto = '0';
    var saldo = '0';
    var id_proveedor = '0';
    var id_item = '0';
    var cantidad = '0';
    var precio = '0';
    var id_corden = '0';
    var id_deposito = '0';
    if (operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4') {
        id_cc = $("#id_cc").val();
        cc_fecha = $("#cc_fecha").val();
        cc_intervalo = $("#cc_intervalo").val();
        cc_nro_factura = $("#cc_nro_factura").val();
        cc_timbrado = $("#cc_timbrado").val();
        cc_tipo_factura = $("#cc_tipo_factura").val();
        cc_cuota = $("#cc_cuota").val();
        id_proveedor = $("#id_proveedor").val();
    }
    if (operacion == '5') {
        id_cc = $("#id_cc").val();
        id_item = $("#agregar_id_item").val();
        cantidad = $("#agregar_cantidad").val();
        precio = $("#agregar_precio").val();
        id_deposito = $("#ag_id_deposito").val();

    }
    if (operacion == '6') {
        id_cc = $("#id_cc").val();
        id_item = $("#modificar_id_item").val();
        cantidad = $("#modificar_cantidad").val();
        precio = $().val("#modificar_precio");
    }
    if (operacion == '7') {
        id_cc = $("#id_cc").val();
        id_item = $("#eliminar_id_item").val();
    }
    if (operacion == '8') {
        id_cc = $("#id_cc").val();
        id_corden = $("#id_corden").val();
        id_deposito = $("#id_deposito").val();
    }
    if (operacion == '9') {
        id_cc = $("#id_cc").val();
        id_corden = $("#id_corden").val();
        id_item = $("#modificar_id_item").val();
        cantidad = $("#modificar_cantidad").val();
        precio = $("#modificar_precio").val();
    }
    if (operacion == '10') {
        id_cc = $("#id_cc").val();
        id_corden = $("#id_corden").val();
        id_item = $("#eliminar_id_item").val();
    }
    if (operacion == '11') {
        id_cc = $("#id_cc").val();
        id_corden = $("#id_corden").val();
        id_item = $("#eliminar_id_item").val();
    }
    if (operacion == '12') {// INSERTAR LIBRO DE COMPRAS Y CUENTA A PAGAR
        id_cc = $("#id_cc").val();
        id_corden = $("#id_corden").val();
        cc_fecha = $("#fecha_cuenta").val();
        id_item = $("#eliminar_id_item").val();
        iva5 = $("#total_iva5").val();
        iva10 = $("#total_iva10").val();
        exenta = $("#total_exenta").val();
        monto = $("#total_pagar").val();
        saldo = $("#total_pagar").val(); // SE RESTATA EL MONTO MENOS EL SALDO

    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data: {
            id_cc: id_cc,
            cc_fecha: cc_fecha,
            cc_intervalo: cc_intervalo,
            cc_nro_factura: cc_nro_factura,
            cc_timbrado: cc_timbrado,
            cc_tipo_factura: cc_tipo_factura,
            cc_cuota: cc_cuota,
            iva5: iva5,
            iva10: iva10,
            exenta: exenta,
            monto: monto,
            saldo: saldo,
            id_proveedor: id_proveedor,
            id_deposito: id_deposito,
            id_item: id_item,
            cantidad: cantidad,
            precio: precio,
            id_corden: id_corden,
            operacion: operacion
        }
    }).done(function (resultado) {
        console.log(resultado); // Agregado para verificar la respuesta del servidor
        if (verificar_mensaje(resultado)) {
            postgrabar(operacion);
        }
    }).fail(function (a, b, c) {
        console.error("Error:", a, b, c); // Error detallado
    });
}

function postgrabar(operacion) {
    panel_compras();
    if (operacion == '1') {
        panel_datos(-2);
        //$('#btn-panel-pedidos').click ();
    }
    if (operacion == '2' || operacion == '5' || operacion == '6' || operacion == '7' || operacion == '8' || operacion == '9' || operacion == '10' || operacion == '11' || operacion == '12') {
        panel_datos($("#id_cc").val());
        if (operacion == '6') {
            $("#btn-panel-modificar-cerrar").click();
        }
    }
    if (operacion == '8') {
        $("#btn-modal-secund-cerrar").click();
    }
    if (operacion == '3' || operacion == '4') {
        panel_datos(-1);

    }
}

function validarTipoFactura() {
    $(document).ready(function () {
        $('#cc_tipo_factura').change(function () {
            const tipoFactura = $(this).val(); // Obtenemos el valor del tipo de factura

            if (tipoFactura === 'CREDITO') {
                $('#cc_cuota').prop('disabled', false); // Habilita el campo cuota
                $('#cc_intervalo').prop('disabled', false); // Habilita el campo
            } else {
                $('#cc_cuota').prop('disabled', true).val(''); // Deshabilita y limpia el campo cuota
                $('#cc_intervalo').prop('disabled', true).val('');
            }
        });
    });

}


