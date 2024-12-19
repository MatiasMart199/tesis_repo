
$(function(){
    panel_evoluciones();
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

function panel_evoluciones(){
    $.ajax({
        url:"panel_evoluciones.php"
    }).done(function(resultado){
        $("#panel-evoluciones").html(resultado);
        formato_tabla("#tabla_panel_evoluciones", 5);
    });
}

function panel_datos(id_evo){
    $.ajax({
        url:"panel_datos.php",
        type:"POST",
        data:{
            id_evo: id_evo
        }
    }).done(function(resultado){
        $("#panel-datos").html(resultado);  
        refrescar_select();
    });
}


function datos(id_evo){
    panel_datos(id_evo);
    $("#btn-panel-datos").click();
}

function agregar(){
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function modificar_detalle(id_item){
    var id_evo = $("#id_evo").val();
    $.ajax({
        url:"panel_modificar.php",
        type:"POST",
        data:{
            id_evo: id_evo,
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

function modalConsolidacion(id_evo){
    $.ajax({
        type:"POST",
        url:"./panel_consolidacion.php",
        data:{
            id_evo: id_evo
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
    var id_evo = '0';
    var evo_fecha = '2023-03-03';
    var evo_edad = '0';
    var evo_observacion = '0';
    var evo_imc = '0';
    var evo_pgc = '0';
    var id_cliente = '0';
    var id_personal = '0';
    var id_med = '0';
    var id_act = '0';
    var valor = '0';
    if(operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4'){
        id_evo = $("#id_evo").val();
        evo_fecha = $("#evo_fecha").val();
        evo_edad = $("#evo_edad").val();
        evo_observacion = $("#evo_observacion").val();
        evo_imc = $("#evo_imc").val();
        evo_pgc = $("#evo_pgc").val();
        id_cliente = $("#id_cliente").val();
        id_personal = $("#id_personal").val();
        id_med = $("#id_med").val();
    }
    if(operacion == '5'){
        id_evo = $("#id_evo").val();
        id_act = $("#agregar_id_act").val();
        valor = $("#agregar_valor").val();
        console.log(id_evo);
        console.log(id_act);
        console.log(valor);
    }
    if(operacion == '6'){
        id_evo = $("#id_evo").val();
        id_act = $("#modificar_id_act").val();
        valor = $("#modificar_valor").val();
    }
    if(operacion == '7'){
        id_evo = $("#id_evo").val();
        id_act = $("#eliminar_id_act").val();
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data:{
            id_evo: id_evo,
            evo_fecha: evo_fecha,
            evo_edad: evo_edad,
            evo_observacion: evo_observacion,
            evo_imc: evo_imc,
            evo_pgc: evo_pgc,
            id_cliente: id_cliente,
            id_personal: id_personal,
            id_med: id_med,
            id_act: id_act,
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
    panel_evoluciones();
    if(operacion == '1'){
        panel_datos(-2);
        //$('#btn-panel-pedidos').click ();
    }
    if(operacion == '2'|| operacion == '5' || operacion == '6' || operacion == '7' || operacion == '8'|| operacion == '9'|| operacion == '10'|| operacion == '11'){
        panel_datos($("#id_evo").val());
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

$(document).ready(function() {
    $(document).on('change', '#id_cliente', function() {
        llenarDatos();
    });
});

$(document).ready(function() {
    $(document).on('change', '#agregar_id_act', function() {
        llenarDatosMed();
    });
});

function llenarDatos() {
    // Obtener el ID de la factura seleccionada
    const idCliente = document.getElementById('id_cliente').value;
    const idMed = document.getElementById('id_med');

    // Buscar la factura correspondiente en el objeto datosCompras
    const clienteSeleccionada = datoCliente.find(d => d.id_cliente === idCliente);
    const medicionSeleccionada = datoMedicion.find(d => d.id_cliente === idCliente);
    
     

    if (clienteSeleccionada && medicionSeleccionada) {
        const edad = document.getElementById('evo_edad');

        

        const imc = document.getElementById('evo_imc');

        const pgc = document.getElementById('evo_pgc');

        const generoSelect = document.getElementById('id_genero');
        // Rellenar 
        const optionGenero = document.createElement('option');
        
        generoSelect.innerHTML = ''; // Limpiar opciones previas
        edad.value = clienteSeleccionada.per_edad;


        // Redondear IMC y Porcentaje de Grasa Corporal a 2 decimales
        imc.value = parseFloat(medicionSeleccionada.imc).toFixed(2);
        pgc.value = parseFloat(medicionSeleccionada.grasa_corporal).toFixed(2);

        idMed.value = medicionSeleccionada.id_med;

        optionGenero.value = clienteSeleccionada.id_genero;
        optionGenero.textContent = clienteSeleccionada.gen_descrip;
        optionGenero.selected = true; // Seleccionar automáticamente
        generoSelect.appendChild(optionGenero);
    }else{
        edad.value = '';

        idMed.value = 'No se encuentra medicion';
        
        imc.value = '';
        pgc.value = '';
        
    }
}

function llenarDatosMed() {
    // Obtener el ID de la factura seleccionada
    const idMedicion = document.getElementById('agregar_id_act').value;

    // Buscar la factura correspondiente en el objeto datosCompras
    const medicionSeleccionada = datoMed.find(d => d.id_act === idMedicion);
    
       

    if (medicionSeleccionada) {
        const unidad = document.getElementById('unidad');
        
        unidad.value = medicionSeleccionada.act_unidad;

    }else{
        unidad.value = '';
        
    }
}


