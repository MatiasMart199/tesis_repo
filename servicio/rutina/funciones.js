
$(function(){
    pane_rutinas();
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

function pane_rutinas(){
    $.ajax({
        url:"pane_rutinas.php"
    }).done(function(resultado){
        $("#panel-rutinas").html(resultado);
        formato_tabla("#tabla_pane_rutinas", 5);
    });
}

function panel_datos(id_rut){
    $.ajax({
        url:"panel_datos.php",
        type:"POST",
        data:{
            id_rut: id_rut
        }
    }).done(function(resultado){
        $("#panel-datos").html(resultado);
        refrescar_select();
    });
}


function datos(id_rut){
    panel_datos(id_rut);
    $("#btn-panel-datos").click();
}

function agregar(){
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function modificar_detalle(id_item){
    var id_rut = $("#id_rut").val();
    $.ajax({
        url:"panel_modificar.php",
        type:"POST",
        data:{
            id_rut: id_rut,
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

function modalConsolidacion(id_rut){
    $.ajax({
        type:"POST",
        url:"./panel_consolidacion.php",
        data:{
            id_rut: id_rut
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
    var id_rut = '0';
    var rut_fecha = '2023-03-03';
    var rut_edad = '0';
    var rut_observacion = '0';
    var id_plan_servi = '0';
    var id_cliente = '0';
    var id_personal = '0';
    var id_act = '0';
    var serie = '0';
    var repeticion = '0';
    var peso = '0';
    var ejercicio = '0';
    if(operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4'){
        id_rut = $("#id_rut").val();
        rut_fecha = $("#rut_fecha").val();
        rut_edad = $("#rut_edad").val();
        rut_observacion = $("#rut_observacion").val();
        id_plan_servi = $("#id_plan_servi").val();
        id_cliente = $("#id_cliente").val();
        id_personal = $("#id_personal").val();
    }
    if(operacion == '5'){
        id_rut = $("#id_rut").val();
        id_act = $("#agregar_id_act").val();
        serie = $("#agregar_serie").val();
        repeticion = $("#agregar_repeticion").val();
        peso = $("#agregar_peso").val();
        ejercicio = $("#agregar_ejercicio").val();

    }
    if(operacion == '6'){
        id_rut = $("#id_rut").val();
        id_act = $("#agregar_id_act").val();
        serie = $("#agregar_serie").val();
        repeticion = $("#agregar_repeticion").val();
        peso = $("#agregar_peso").val();
        ejercicio = $("#agregar_ejercicio").val();
    }
    if(operacion == '7'){
        id_rut = $("#id_rut").val();
        id_act = $("#eliminar_id_act").val();
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data:{
            id_rut: id_rut,
            rut_fecha: rut_fecha,
            rut_edad: rut_edad,
            rut_observacion: rut_observacion,
            id_plan_servi: id_plan_servi,
            id_cliente: id_cliente,
            id_personal: id_personal,
            id_act: id_act,
            serie: serie,
            repeticion: repeticion,
            peso: peso,
            ejercicio: ejercicio,
            operacion: operacion
        }
    }).done(function(resultado){
        if(verificar_mensajeSinJson(resultado)){
            //postgrabar(operacion);
        }
        postgrabar(operacion);
    }).fail(function(a,b,c){
        console.error('Error:',a,b, c);
    });
}

function postgrabar(operacion){
    pane_rutinas();
    if(operacion == '1'){
        panel_datos(-2);
        //$('#btn-panel-pedidos').click ();
    }
    if(operacion == '2'|| operacion == '5' || operacion == '6' || operacion == '7' || operacion == '8'|| operacion == '9'|| operacion == '10'|| operacion == '11'){
        panel_datos($("#id_rut").val());
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

// Función para llenar datos
function llenarDatos() {
    const idCliente = document.getElementById('id_cliente').value;
    console.log('ID Cliente seleccionado:', idCliente);

    const clienteSeleccionada = datoCliente.find(d => d.id_cliente == idCliente);
    console.log('Cliente encontrado:', clienteSeleccionada);

    const edad = document.getElementById('rut_edad');
    const generoSelect = document.getElementById('id_genero');
    const selectServicio = document.getElementById('id_plan_servi');

    // Limpiar campos
    edad.value = '';
    generoSelect.innerHTML = '<option value="">Seleccione...</option>';
    selectServicio.innerHTML = '<option value="">Seleccione un servicio</option>';

    if (clienteSeleccionada) {
        edad.value = clienteSeleccionada.per_edad;

        const optionGenero = document.createElement('option');
        optionGenero.value = clienteSeleccionada.id_genero;
        optionGenero.textContent = clienteSeleccionada.gen_descrip;
        optionGenero.selected = true;
        generoSelect.appendChild(optionGenero);

        const serviciosCliente = datoServicio.filter(s => s.id_cliente == idCliente);
        console.log('Servicios del cliente:', serviciosCliente);

        serviciosCliente.forEach(s => {
            const optionServ = document.createElement('option');
            optionServ.value = s.id_plan_servi;
            optionServ.textContent = s.ps_descrip;
            selectServicio.appendChild(optionServ);
        });
    }
}





// function llenarDatosMed() {
//     // Obtener el ID de la factura seleccionada
//     const idMedicion = document.getElementById('agregar_id_tip_med').value;

//     // Buscar la factura correspondiente en el objeto datosCompras
//     const medicionSeleccionada = datoMed.find(d => d.id_act === idMedicion);



//     if (medicionSeleccionada) {
//         const unidad = document.getElementById('unidad');

//         unidad.value = medicionSeleccionada.act_unidad;

//     }else{
//         unidad.value = '';

//     }
// }
