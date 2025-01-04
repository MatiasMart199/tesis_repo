
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

function panel_datos(id_inscrip){
    $.ajax({
        url:"panel_datos.php",
        type:"POST",
        data:{
            id_inscrip: id_inscrip
        }
    }).done(function(resultado){
        $("#panel-datos").html(resultado);
        refrescar_select();
    });
}

function datos(id_inscrip){
    panel_datos(id_inscrip);
    $("#btn-panel-datos").click();
}

function agregar(){
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function modificar_detalle(id_plan_servi ){
    var id_inscrip = $("#id_inscrip").val();
    $.ajax({
        url:"panel_modificar.php",
        type:"POST",
        data:{
            id_inscrip: id_inscrip,
            id_plan_servi : id_plan_servi 
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

function eliminar_detalle(id_plan_servi ){
    $("#eliminar_id_plan_servi ").val(id_plan_servi );
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
    var id_inscrip = '0';
    var ins_aprobacion = '2021-01-01';
    var ins_estad_salud= "0";
    var id_cliente = "0";
    var id_plan_servi  = '0';
    var dia  = '0';
    if(operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4'){
        id_inscrip = $("#id_inscrip").val();
        id_cliente = $('#id_cliente').val();
        ins_aprobacion = $("#ins_aprobacion").val();
        ins_estad_salud = $('#ins_estad_salud').val();

        console.log(id_inscrip);
        console.log(id_cliente);
        console.log(ins_aprobacion);
        console.log(ins_estad_salud);
        console.log(operacion);

    }
    if(operacion == '5'){
        id_inscrip = $("#id_inscrip").val();
        id_plan_servi  = $("#agregar_id_plan_servi").val();
        dia  = $("#agregar_dia ").val();
        //item_precio = 0;$("#agregar_precio").val();
    }
    if(operacion == '6'){
        id_inscrip = $("#id_inscrip").val();
        id_plan_servi  = $("#modificar_id_plan_servi").val();
        dia  = $("#modificar_dia ").val();
    }
    if(operacion == '7'){
        id_inscrip = $("#id_inscrip").val();
        id_plan_servi  = $("#eliminar_id_plan_servi ").val();
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data:{
            id_inscrip: id_inscrip,
            ins_aprobacion: ins_aprobacion,
            ins_estad_salud: ins_estad_salud,
            id_cliente: id_cliente,
            id_plan_servi: id_plan_servi,
            dia: dia,
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

function postgrabar(operacion){
    panel_pedidos();
    if(operacion == '1'){
        panel_datos(-2);
    }
    if(operacion == '2' || operacion == '5' || operacion == '6' || operacion == '7'){
        panel_datos($("#id_inscrip").val());
        if(operacion == '6'){
            $("#btn-panel-modificar-cerrar").click();
        }
    }
    if(operacion == '3' || operacion == '4'){
        panel_datos(-1);
        $("#btn-panel-pedidos").click();
    }
}