
$(function(){
    panel_notas();
    panel_datos(-1);
});

function refrescar_select(){
    $(".select2").select2();
    $(".select2").attr("style", "width: 100%;");
}

function formato_tabla(tabla, item_cantidad){
    $(tabla).DataTable({
        "lengthChange": false,
        responsive: "true",
        "iDisplayLength": item_cantidad,
        language: {
            "sSearch":"Buscar: ",
            "sInfo":"Mostrando resultados del _START_ al _END_ de un total de _TOTAL_ registros",
            "sInfoFiltered":"(filtrado de entre _MAX_ registros)",
            "sInfoEmpty":"No hay resultados",
            "oPaginate":{
                "sNext":"Siguiente",
                "sPrevious":"Anterior"
            }
        }
    });
}

function panel_notas(){
    $.ajax({
        url:"panel_notas.php"
    }).done(function(resultado){
        $("#panel-notas").html(resultado);
        formato_tabla("#tabla_panel_notas", 5);
    });
}

function panel_datos(id_not){
    $.ajax({
        url:"panel_datos.php",
        type:"POST",
        data:{
            id_not: id_not
        }
    }).done(function(resultado){
        $("#panel-datos").html(resultado);
        refrescar_select();
    });
}

function datos(id_not){
    panel_datos(id_not);
    $("#btn-panel-datos").click();
}

function generarInforme(id_not) {
    // Abre una nueva ventana del navegador con la URL que incluye el parámetro id_not
    //window.open('./reporte.php?id_not=' + id_not, '_blank');
    window.open('../../reportes/compra/reporte.php?id_not=' + id_not, '_blank');
}


function agregar(){
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function modificar_detalle(id_item){
    var id_not = $("#id_not").val();
    $.ajax({
        url:"panel_modificar.php",
        type:"POST",
        data:{
            id_not: id_not,
            id_item: id_item
        }
    }).done(function(resultado){
        $("#panel-modificar").html(resultado);
        $("#btn-panel-modificar").click();
    });
}

function agregar_grabar(){
    $("#operacion").val(1);
    grabar();
}

function modificar(){
    $("#operacion").val(2);
    grabar();
}

function confirmar(){
    $("#operacion").val(3);
    grabar();
}

function anular(){
    $("#operacion").val(4);
    grabar();
}

function agregar_detalles(){
    $("#operacion").val(5);
    grabar();
}

function modificar_detalle_grabar(){
    $("#operacion").val(6);
    grabar();
}

function eliminar_detalle(cod_item){
    $("#eliminar_id_item").val(cod_item);
    $("#operacion").val(7);
    grabar();
}

function cancelar(){
    panel_datos(-1);
    $("#btn-panel-notas").click();
    mensaje("CANCELADO","error");
}

function grabar(){
    var operacion = $("#operacion").val();
    var id_not = '0';
    var not_fecha = '2021-01-01';
    var not_fecha_docu = '2021-01-01';
    var not_tipo_nota = '0';
    var id_cc = '0';
    var id_proveedor = '0';
    var id_item = '0';
    var cantidad = '0';
    var monto = '0';
    if(operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4'){
        id_not = $("#id_not").val();
        not_fecha = $("#not_fecha").val();
        not_fecha_docu = $("#not_fecha_docu").val();
        not_tipo_nota = $("#not_tipo_nota").val();
        id_cc = $("#id_cc").val();
        id_proveedor = $("#id_proveedor").val();
        console.log(id_not, not_fecha, not_fecha_docu, not_tipo_nota, id_cc, id_proveedor);
    }
    if(operacion == '5'){
        id_not = $("#id_not").val();
        id_item = $("#agregar_id_item").val();
        cantidad = $("#agregar_cantidad").val();
        monto = $("#agregar_monto").val();
        console.log(id_not, id_item, cantidad, monto);
    }
    if(operacion == '6'){
        id_not = $("#id_not").val();
        id_item = $("#modificar_id_item").val();
        cantidad = $("#modificar_cantidad").val();
    }
    if(operacion == '7'){
        id_not = $("#id_not").val();
        id_item = $("#eliminar_id_item").val();
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data:{
            id_not: id_not,
            not_fecha: not_fecha,
            not_fecha_docu: not_fecha_docu,
            not_tipo_nota: not_tipo_nota,
            id_cc: id_cc,
            id_proveedor: id_proveedor,
            id_item: id_item,
            cantidad: cantidad,
            monto: monto,
            operacion: operacion
        }
    }).done(function(resultado){
        if(verificar_mensajeSinJson(resultado)){
            //postgrabar(operacion);
        }
        postgrabar(operacion);
    }).fail(function (a, b, c) {
        //console.error(b);
        console.error("Error:", a, b, c); // Error detallado
    });
}

function postgrabar(operacion){
    panel_notas();
    if(operacion == '1'){
        panel_datos(-2);
    }
    if(operacion == '2' || operacion == '5' || operacion == '6' || operacion == '7'){
        panel_datos($("#id_not").val());
        if(operacion == '6'){
            $("#btn-panel-modificar-cerrar").click();
        }
    }
    if(operacion == '3' || operacion == '4'){
        panel_datos(-1);
        $("#btn-panel-notas").click();
    }
}


function autollenar() {
    // Obtener el ID de la factura seleccionada
    const idFactura = document.getElementById('id_cc').value;

    // Buscar la factura correspondiente en el objeto datosCompras
    const facturaSeleccionada = datosCompras.find(compra => compra.id_cc === idFactura);

    if (facturaSeleccionada) {
        // Rellenar la fecha del documento
        document.getElementById('not_fecha_docu').value = facturaSeleccionada.cc_fecha;

        // Rellenar el proveedor
        const proveedorSelect = document.getElementById('id_proveedor');
        proveedorSelect.innerHTML = ''; // Limpiar opciones previas
        const option = document.createElement('option');
        option.value = facturaSeleccionada.id_proveedor;
        option.textContent = facturaSeleccionada.proveedor;
        option.selected = true; // Seleccionar automáticamente
        proveedorSelect.appendChild(option);
    }
}