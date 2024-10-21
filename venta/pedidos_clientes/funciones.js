
$(function(){
    panel_pedidos();
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

function panel_pedidos(){
    $.ajax({
        url:"panel_pedidos.php"
    }).done(function(resultado){
        $("#panel-pedidos").html(resultado);
        formato_tabla("#tabla_panel_pedidos", 5);
    });
}

function panel_datos(id_vped){
    $.ajax({
        url:"panel_datos.php",
        type:"POST",
        data:{
            id_vped: id_vped
        }
    }).done(function(resultado){
        $("#panel-datos").html(resultado);
        refrescar_select();
    });
}

function datos(id_vped){
    panel_datos(id_vped);
    $("#btn-panel-datos").click();
}

function agregar(){
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function modificar_detalle(id_item){
    var id_vped = $("#id_vped").val();
    $.ajax({
        url:"panel_modificar.php",
        type:"POST",
        data:{
            id_vped: id_vped,
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

function eliminar_detalle(id_item){
    $("#eliminar_id_item").val(id_item);
    $("#operacion").val(7);
    grabar();
}

function cancelar(){
    panel_datos(-1);
    $("#btn-panel-pedidos").click();
    mensaje("CANCELADO","error");
}

function grabar(){
    var operacion = $("#operacion").val();
    var id_vped = '0';
    var vped_aprobacion = '2021-01-01';
    var vped_observacion= "O";
    var id_cliente = "0";
    var id_item = '0';
    var cantidad = '0';
    if(operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4'){
        id_vped = $("#id_vped").val();
        id_cliente = $('#id_cliente').val();
        vped_aprobacion = $("#vped_aprobacion").val();
        vped_observacion = $('#vped_observacion').val();

    }
    if(operacion == '5'){
        id_vped = $("#id_vped").val();
        id_item = $("#agregar_id_item").val();
        cantidad = $("#agregar_cantidad").val();
        //item_precio = 0;$("#agregar_precio").val();
    }
    if(operacion == '6'){
        id_vped = $("#id_vped").val();
        id_item = $("#modificar_id_item").val();
        cantidad = $("#modificar_cantidad").val();
    }
    if(operacion == '7'){
        id_vped = $("#id_vped").val();
        id_item = $("#eliminar_id_item").val();
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data:{
            id_vped: id_vped,
            vped_aprobacion: vped_aprobacion,
            vped_observacion: vped_observacion,
            id_cliente: id_cliente,
            id_item: id_item,
            cantidad: cantidad,
            operacion: operacion
        }
    }).done(function(resultado){
        if(verificar_mensaje(resultado)){
            //postgrabar(operacion);
        }
        postgrabar(operacion);
    });
}

function postgrabar(operacion){
    panel_pedidos();
    if(operacion == '1'){
        panel_datos(-2);
    }
    if(operacion == '2' || operacion == '5' || operacion == '6' || operacion == '7'){
        panel_datos($("#id_vped").val());
        if(operacion == '6'){
            $("#btn-panel-modificar-cerrar").click();
        }
    }
    if(operacion == '3' || operacion == '4'){
        panel_datos(-1);
        $("#btn-panel-pedidos").click();
    }
}