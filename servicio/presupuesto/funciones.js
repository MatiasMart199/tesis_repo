
$(function(){
    panel_presupuesto();
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

function panel_presupuesto(){
    $.ajax({
        url:"panel_presupuesto.php"
    }).done(function(resultado){
        $("#panel-presupuesto").html(resultado);
        formato_tabla("#tabla_panel_presupuesto", 5);
    });
}

function panel_datos(id_pre){
    $.ajax({
        url:"panel_datos.php",
        type:"POST",
        data:{
            id_pre: id_pre
        }
    }).done(function(resultado){
        $("#panel-datos").html(resultado);  
        refrescar_select();
    });
}


function datos(id_pre){
    panel_datos(id_pre);
    $("#btn-panel-datos").click();
}

function agregar(){
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function modificar_detalle(id_item){
    var id_pre = $("#id_pre").val();
    $.ajax({
        url:"panel_modificar.php",
        type:"POST",
        data:{
            id_pre: id_pre,
            id_item: id_item
        }
    }).done(function(resultado){
        $("#panel-modificar").html(resultado);
        $("#btn-panel-modificar").click();
    });
}

function modalSecund(){
    $.ajax({
        type:"POST",
        url:"./panel_secundario.php"
     // ejecuta el llamado
    }).done(function(resultado){
        $("#panel-secund").html(resultado);
        $("#btn-panel-secund").click();
    }).fail(function(a,b,c){
        console.log(c);
    });
}

function modalConsolidacion(id_pre){
    $.ajax({
        type:"POST",
        url:"./panel_consolidacion.php",
        data:{
            id_pre: id_pre
        }
     // ejecuta el llamado
    }).done(function(resultado){
        $("#panel-consolidacion").html(resultado);
        $("#btn-panel-consolidacion").click();
    });
}

function agregar_presupuesto_pedido(id_cp){
    $("#id_cp").val(id_cp);
    $("#operacion").val(8);
    grabar();
    $("html, body").animate({ scrollTop: 0}, "slow");
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

function eliminar_detalle(id_act){
    $("#eliminar_id_act").val(id_act);
    $("#operacion").val(7);
    grabar();
}


function cancelar(){
    panel_datos(-1);
    $("#btn-panel-membresia").click();
    mensaje("CANCELADO","error");
}

function grabar(){
    var operacion = $("#operacion").val();
    var id_pre = '0';
    var pre_fecha = '2023-03-03';
    var pre_observacion = '0';
    var id_cliente = '0';
    var id_personal = '0';
    var id_act = '0';
    var descrip = '0';
    var costo = '0';
    if(operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4'){
        id_pre = $("#id_pre").val();
        pre_fecha = $("#pre_fecha").val();
        pre_observacion = $("#pre_observacion").val();
        id_cliente = $("#id_cliente").val();
        id_personal = $("#id_personal").val();
    }
    if(operacion == '5'){
        id_pre = $("#id_pre").val();
        id_act = $("#agregar_id_act").val();
        descrip = $("#agregar_descrip").val();
        costo = $("#agregar_costo").val();
        console.log(id_pre);
        console.log(id_act);
        console.log(descrip);
        console.log(costo);
    }
    if(operacion == '6'){
        id_pre = $("#id_pre").val();
        id_act = $("#modificar_id_act").val();
        descrip = $("#modificar_descrip").val();
        costo = $("#modificar_costo").val();
    }
    if(operacion == '7'){
        id_pre = $("#id_pre").val();
        id_act = $("#eliminar_id_act").val();
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data:{
            id_pre: id_pre,
            pre_fecha: pre_fecha,
            pre_observacion: pre_observacion,
            id_cliente: id_cliente,
            id_personal: id_personal,
            id_act: id_act,
            descrip: descrip,
            costo: costo,
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
    panel_presupuesto();
    if(operacion == '1'){
        panel_datos(-2);
        //$('#btn-panel-pedidos').click ();
    }
    if(operacion == '2'|| operacion == '5' || operacion == '6' || operacion == '7' || operacion == '8'|| operacion == '9'|| operacion == '10'|| operacion == '11'){
        panel_datos($("#id_pre").val());
        if(operacion == '6'){
            $("#btn-panel-modificar-cerrar").click();
        }
    }
    if (operacion == '8') {
        $("#btn-modal-secund-cerrar").click();
    }
    if(operacion == '3' || operacion == '4'){
        panel_datos(-1);
    
    }
}



