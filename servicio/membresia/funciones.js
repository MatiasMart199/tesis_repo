
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

function modificar_detalle(id_mem, id_plan_servi){
    //var id_mem = $("#id_mem").val();
    $.ajax({
        url:"panel_modificar.php",
        type:"POST",
        data:{
            id_mem: id_mem,
            id_plan_servi: id_plan_servi
        }
    }).done(function(resultado){
        $("#panel-modificar").html(resultado);
        $("#btn-panel-modificar").click();
    });
}

function modificar_detalle_ins(id_mem, id_plan_servi){
    //var id_mem = $("#id_mem").val();
    $.ajax({
        url:"panel_modificar_ins.php",
        type:"POST",
        data:{
            id_mem: id_mem,
            id_plan_servi: id_plan_servi
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

function modificar_detalle_ins_grabar(){
    $("#operacion").val(9);
    grabar();
}

function eliminar_detalle(id_plan_servi){
    $("#eliminar_id_plan_servi").val(id_plan_servi);
    $("#operacion").val(7);
    grabar();
}

function agregar_membresia_inscripcion(id_inscrip){
    $("#id_inscrip").val(id_inscrip);
    $("#operacion").val(8);
    grabar();
    $("html, body").animate({ scrollTop: 0}, "slow");
}

function eliminar_membresia_inscripcion(id_plan_servi){
    $("#eliminar_id_plan_servi").val(id_plan_servi);
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
    var mem_fecha = '2023-03-03';
    var mem_vence = '2023-03-03';
    var mem_observacion = '0';
    var id_cliente = '0';
    var id_plan_servi = '0';
    var dias = '0';
    var precio = '0';
    var id_inscrip = '0';
    if(operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4'){
        id_mem = $("#id_mem").val();
        mem_fecha = $("#mem_fecha").val();
        mem_vence = $("#mem_vence").val();
        mem_observacion = $("#mem_observacion").val();
        id_cliente = $("#id_cliente").val();
        
    }
    if(operacion == '5'){
        id_mem = $("#id_mem").val();
        id_plan_servi = $("#agregar_id_plan_servi").val();
        dias = $("#agregar_dias").val();
        precio = $("#agregar_precio").val();
    }
    if(operacion == '6'){
        id_mem = $("#id_mem").val();
        id_plan_servi = $("#modificar_id_plan_servi").val();
        dias = $("#modificar_dias").val();
        precio = $().val("#modificar_precio");
    }
    if(operacion == '7'){
        id_mem = $("#id_mem").val();
        id_plan_servi = $("#eliminar_id_plan_servi").val();
    }
    if(operacion == '8'){
        id_mem = $("#id_mem").val();
        id_inscrip = $("#id_inscrip").val();
    }
    if(operacion == '9'){
        id_mem = $("#id_mem").val();
        //id_inscrip = $("#id_inscrip").val();
        id_plan_servi = $("#modificar_id_plan_servi").val();
        dias = $("#modificar_dias").val();
        precio = $("#modificar_precio").val();

    }
    if(operacion == '10'){
        id_inscrip = $("#id_inscrip").val();
        id_plan_servi = $("#id_plan_servi").val();
    }
    if(operacion == '11'){
        id_inscrip = $("#id_inscrip").val();
        id_plan_servi = $("#eliminar_id_plan_servi").val();
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data:{
            id_mem: id_mem,
            mem_fecha: mem_fecha,
            mem_vence: mem_vence,
            mem_observacion: mem_observacion,
            id_cliente: id_cliente,
            id_plan_servi: id_plan_servi,
            dias: dias,
            precio: precio,
            id_inscrip: id_inscrip,
            operacion: operacion
        }
    }).done(function(resultado){
        if(verificar_mensaje(resultado)){
            //postgrabar(operacion);
        }
        postgrabar(operacion);
    }).fail(function(a,b,c){
        console.error("Error:", a, b, c);
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
        if(operacion == '6' || operacion == '9'){
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

function autoCompletePrecio(){
    $(document).ready(function() {
        $('#agregar_id_plan_servi').on('change', function() {
            const selectOption = this.options[this.selectedIndex];
            const precio = selectOption.getAttribute('data_precio');
            document.getElementById('agregar_precio').value = precio;
        });
    });
}

    // document.getElementById('agregar_id_plan_servi').addEventListener('change', function() {
    //     const selectOption = this.options[this.selectedIndex];
    //     const precio = selectOption.getAttribute('data-precio');
    //     document.getElementById('agregar_precio').value = precio;
    // });    

