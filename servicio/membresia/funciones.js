
$(function(){
    panel_membresia();
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

function panel_membresia(){
    $.ajax({
        url:"panel_membresia.php"
    }).done(function(resultado){
        $("#panel-membresias").html(resultado);
        formato_tabla("#tabla_panel_presupuestos", 5);
    });
}

function panel_datos(id_mem){
    $.ajax({
        url:"panel_datos.php",
        type:"POST",
        data:{
            id_mem: id_mem
        }
    }).done(function(resultado){
        $("#panel-datos").html(resultado);
        refrescar_select();
    });
}

// function panel_pedidos(){
//     $.ajax({
//         url:"panel_presupuestos.php"
//     }).done(function(resultado){
//         $("#panel-presupuestos").html(resultado);
//         formato_tabla("#tabla_panel_presupuestos", 5);
//     });
// }

function datos(id_mem){
    panel_datos(id_mem);
    $("#btn-panel-datos").click();
}

function agregar(){
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function modificar_detalle(id_item){
    var id_mem = $("#id_mem").val();
    $.ajax({
        url:"panel_modificar.php",
        type:"POST",
        data:{
            id_mem: id_mem,
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

function modalConsolidacion(id_mem){
    $.ajax({
        type:"POST",
        url:"./panel_consolidacion.php",
        data:{
            id_mem: id_mem
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

function eliminar_detalle(id_item){
    $("#eliminar_id_item").val(id_item);
    $("#operacion").val(7);
    grabar();
}

function eliminar_presupuesto_pedido(id_item){
    $("#eliminar_id_item").val(id_item);
    $("#operacion").val(11);
    grabar();
}

function cancelar(){
    panel_datos(-1);
    $("#btn-panel-membresia").click();
    mensaje("CANCELADO","error");
}

function grabar(){
    var operacion = $("#operacion").val();
    var id_mem = '0';
    var cpre_fecha = '2023-03-03';
    var cpre_validez = '2023-03-03';
    var cpre_numero = '0';
    var cpre_observacion = '0';
    var id_proveedor = '0';
    var id_item = '0';
    var cantidad = '0';
    var precio = '0';
    var id_cp = '0';
    if(operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4'){
        id_mem = $("#id_mem").val();
        cpre_fecha = $("#cpre_fecha").val();
        cpre_validez = $("#cpre_validez").val();
        cpre_numero = $("#cpre_numero").val();
        cpre_observacion = $("#cpre_observacion").val();
        id_proveedor = $("#id_proveedor").val();
    }
    if(operacion == '5'){
        id_mem = $("#id_mem").val();
        id_item = $("#agregar_id_item").val();
        cantidad = $("#agregar_cantidad").val();
        precio = $("#agregar_precio").val();
    }
    if(operacion == '6'){
        id_mem = $("#id_mem").val();
        id_item = $("#modificar_id_item").val();
        cantidad = $("#modificar_cantidad").val();
        precio = $().val("#modificar_precio");
    }
    if(operacion == '7'){
        id_mem = $("#id_mem").val();
        id_item = $("#eliminar_id_item").val();
    }
    if(operacion == '8'){
        id_mem = $("#id_mem").val();
        id_cp = $("#id_cp").val();
    }
    if(operacion == '9'){
        id_mem = $("#id_mem").val();
        id_cp = $("#id_cp").val();
        id_item = $("#modificar_id_item").val();
        cantidad = $("#modificar_cantidad").val();
        precio = $().val("#modificar_precio");
    }
    if(operacion == '10'){
        id_cp = $("#id_cp").val();
        id_item = $("#eliminar_id_item").val();
    }
    if(operacion == '11'){
        id_mem = $("#id_mem").val();
        id_cp = $("#id_cp").val();
        id_item = $("#eliminar_id_item").val();
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data:{
            id_mem: id_mem,
            cpre_fecha: cpre_fecha,
            cpre_validez: cpre_validez,
            cpre_numero: cpre_numero,
            cpre_observacion: cpre_observacion,
            id_proveedor: id_proveedor,
            id_item: id_item,
            cantidad: cantidad,
            precio: precio,
            id_cp: id_cp,
            operacion: operacion
        }
    }).done(function(resultado){
        if(verificar_mensaje(resultado)){
            //postgrabar(operacion);
        }
        postgrabar(operacion);
    }).fail(function(a,b,c){
        console.log('Error:', c);
    });
}

function postgrabar(operacion){
    panel_membresia();
    if(operacion == '1'){
        panel_datos(-2);
        //$('#btn-panel-pedidos').click ();
    }
    if(operacion == '2'|| operacion == '5' || operacion == '6' || operacion == '7' || operacion == '8'|| operacion == '9'|| operacion == '10'|| operacion == '11'){
        panel_datos($("#id_mem").val());
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