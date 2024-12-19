
$(function(){
    panel_mediciones();
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

function panel_mediciones(){
    $.ajax({
        url:"panel_mediciones.php"
    }).done(function(resultado){
        $("#panel-membresias").html(resultado);
        formato_tabla("#tabla_panel_mediciones", 5);
    });
}

function panel_datos(id_med){
    $.ajax({
        url:"panel_datos.php",
        type:"POST",
        data:{
            id_med: id_med
        }
    }).done(function(resultado){
        $("#panel-datos").html(resultado);  
        refrescar_select();
    });
}


function datos(id_med){
    panel_datos(id_med);
    $("#btn-panel-datos").click();
}

function agregar(){
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function modificar_detalle(id_item){
    var id_med = $("#id_med").val();
    $.ajax({
        url:"panel_modificar.php",
        type:"POST",
        data:{
            id_med: id_med,
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

function modalConsolidacion(id_med){
    $.ajax({
        type:"POST",
        url:"./panel_consolidacion.php",
        data:{
            id_med: id_med
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

function eliminar_detalle(id_tip_med){
    $("#eliminar_id_tip_med").val(id_tip_med);
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
    var id_med = '0';
    var med_fecha = '2023-03-03';
    var med_edad = '0';
    var med_observacion = '0';
    var id_cliente = '0';
    var id_personal = '0';
    var id_tip_med = '0';
    var valor = '0';
    if(operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4'){
        id_med = $("#id_med").val();
        med_fecha = $("#med_fecha").val();
        med_edad = $("#med_edad").val();
        med_observacion = $("#med_observacion").val();
        id_cliente = $("#id_cliente").val();
        id_personal = $("#id_personal").val();
    }
    if(operacion == '5'){
        id_med = $("#id_med").val();
        id_tip_med = $("#agregar_id_tip_med").val();
        valor = $("#agregar_valor").val();
        console.log(id_med);
        console.log(id_tip_med);
        console.log(valor);
    }
    if(operacion == '6'){
        id_med = $("#id_med").val();
        id_tip_med = $("#modificar_id_tip_med").val();
        valor = $("#modificar_valor").val();
    }
    if(operacion == '7'){
        id_med = $("#id_med").val();
        id_tip_med = $("#eliminar_id_tip_med").val();
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data:{
            id_med: id_med,
            med_fecha: med_fecha,
            med_edad: med_edad,
            med_observacion: med_observacion,
            id_cliente: id_cliente,
            id_personal: id_personal,
            id_tip_med: id_tip_med,
            valor: valor,
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
    panel_mediciones();
    if(operacion == '1'){
        panel_datos(-2);
        //$('#btn-panel-pedidos').click ();
    }
    if(operacion == '2'|| operacion == '5' || operacion == '6' || operacion == '7' || operacion == '8'|| operacion == '9'|| operacion == '10'|| operacion == '11'){
        panel_datos($("#id_med").val());
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

function llenarDatos() {
    // Obtener el ID de la factura seleccionada
    const idCliente = document.getElementById('id_cliente').value;

    // Buscar la factura correspondiente en el objeto datosCompras
    const clienteSeleccionada = datoCliente.find(d => d.id_cliente === idCliente);
    
       

    if (clienteSeleccionada) {
        const edad = document.getElementById('med_edad');

        const generoSelect = document.getElementById('id_genero');
        // Rellenar 
        const optionGenero = document.createElement('option');
        
        generoSelect.innerHTML = ''; // Limpiar opciones previas
        edad.value = clienteSeleccionada.per_edad;

        optionGenero.value = clienteSeleccionada.id_genero;
        optionGenero.textContent = clienteSeleccionada.gen_descrip;
        optionGenero.selected = true; // Seleccionar automáticamente
        generoSelect.appendChild(optionGenero);
    }else{
        edad.value = '';
        
    }
}

function llenarDatosMed() {
    // Obtener el ID de la factura seleccionada
    const idMedicion = document.getElementById('agregar_id_tip_med').value;

    // Buscar la factura correspondiente en el objeto datosCompras
    const medicionSeleccionada = datoMed.find(d => d.id_act === idMedicion);
    
       

    if (medicionSeleccionada) {
        const unidad = document.getElementById('unidad');
        
        unidad.value = medicionSeleccionada.act_unidad;

    }else{
        unidad.value = '';
        
    }
}