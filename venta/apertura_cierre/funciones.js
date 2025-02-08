
$(function(){
    panel_aperturas();
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

function panel_aperturas(){
    $.ajax({
        url:"panel_aperturas.php"
    }).done(function(resultado){
        $("#panel-aperturas").html(resultado);
        formato_tabla("#tabla_panel_aperturas", 5);
    });
}

function panel_datos(id_vac){
    $.ajax({
        url:"panel_datos.php",
        type:"POST",
        data:{
            id_vac: id_vac
        }
    }).done(function(resultado){
        $("#panel-datos").html(resultado);
        refrescar_select();
    });
}

function datos(id_vac){
    panel_datos(id_vac);
    $("#btn-panel-datos").click();
}

function generarInforme(id_vac) {
    // Abre una nueva ventana del navegador con la URL que incluye el parámetro id_vac
    //window.open('./reporte.php?id_vac=' + id_vac, '_blank');
    window.open('../../reportes/compra/reporte.php?id_vac=' + id_vac, '_blank');
}


function agregar(){
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function modificar_detalle(id_item){
    var id_vac = $("#id_vac").val();
    $.ajax({
        url:"panel_modificar.php",
        type:"POST",
        data:{
            id_vac: id_vac,
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
    $("#btn-panel-aperturas").click();
    mensaje("CANCELADO","error");
}

function grabar(){
    var operacion = $("#operacion").val();
    var id_vac = '0';
    var vac_fecha_ape = '2021-01-01';
    var vac_fecha_cie = '2021-01-01';
    var vac_monto_efec = '0';
    var vac_monto_cheq = '0';
    var vac_monto_tarj = '0';
    var vac_monto_ape = '0';
    var vac_monto_cie = '0';
    var id_caja = '0';
    if(operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4'){
        id_vac = $("#id_vac").val();
        vac_fecha_ape = $("#vac_fecha_ape").val();
        vac_fecha_cie = $("#vac_fecha_cie").val();
        vac_monto_efec = $("#vac_monto_efec").val();
        vac_monto_cheq = $("#vac_monto_cheq").val();
        vac_monto_tarj = $("#vac_monto_tarj").val();
        vac_monto_ape = $("#vac_monto_ape").val();
        vac_monto_cie = $("#vac_monto_cie").val();
        id_caja = $("#id_caja").val();
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data:{
            id_vac: id_vac,
            vac_fecha_ape: vac_fecha_ape,
            vac_fecha_cie: vac_fecha_cie,
            vac_monto_efec: vac_monto_efec,
            vac_monto_cheq: vac_monto_cheq,
            vac_monto_tarj: vac_monto_tarj,
            vac_monto_ape: vac_monto_ape,
            vac_monto_cie: vac_monto_cie,
            id_caja: id_caja,
            operacion: operacion
        }
    }).done(function(resultado){
        if(verificar_mensaje(resultado)){
            //postgrabar(operacion);
        }
        postgrabar(operacion);
    }).fail(function(a,b,c){
        console.error('Error:',a,b, c);
    });
}

function postgrabar(operacion){
    panel_aperturas();
    if(operacion == '1'){
        panel_datos(-2);
    }
    if(operacion == '2' || operacion == '5' || operacion == '6' || operacion == '7'){
        panel_datos($("#id_vac").val());
        if(operacion == '6'){
            $("#btn-panel-modificar-cerrar").click();
        }
    }
    if(operacion == '3' || operacion == '4'){
        panel_datos(-1);
        $("#btn-panel-aperturas").click();
    }
}

// function calcularTotal() {
//     // Obtener los valores de los campos y convertirlos a número
//     const efectivo = parseFloat(document.getElementById('vac_monto_efec').value) || 0;
//     const cheque = parseFloat(document.getElementById('vac_monto_cheq').value) || 0;
//     const tarjeta = parseFloat(document.getElementById('vac_monto_tarj').value) || 0;

//     // Calcular el total
//     const total = efectivo + cheque + tarjeta;

//     // Asignar el total al campo "Monto Cierre"
//     document.getElementById('vac_monto_cie').value = total.toFixed(2);
// }

// // Agregar evento input a los campos para que se actualicen en tiempo real
// document.addEventListener('DOMContentLoaded', function () {
//     document.getElementById('vac_monto_efec').addEventListener('input', calcularTotal);
//     document.getElementById('vac_monto_cheq').addEventListener('input', calcularTotal);
//     document.getElementById('vac_monto_tarj').addEventListener('input', calcularTotal);

//     // Ejecutar la función una vez al cargar la página para establecer el valor inicial
//     calcularTotal();
// });
