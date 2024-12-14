
$(function(){
    pane_planes();
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

function pane_planes(){
    $.ajax({
        url:"pane_planes.php"
    }).done(function(resultado){
        $("#pane-planes").html(resultado);
        formato_tabla("#tabla_pane_planes", 5);
    });
}

function panel_datos(id_ali){
    $.ajax({
        url:"panel_datos.php",
        type:"POST",
        data:{
            id_ali: id_ali
        }
    }).done(function(resultado){
        $("#panel-datos").html(resultado);
        refrescar_select();
    });
}


function datos(id_ali){
    panel_datos(id_ali);
    $("#btn-panel-datos").click();
}

function agregar(){
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function modificar_detalle(id_item){
    var id_ali = $("#id_ali").val();
    $.ajax({
        url:"panel_modificar.php",
        type:"POST",
        data:{
            id_ali: id_ali,
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

function modalConsolidacion(id_ali){
    $.ajax({
        type:"POST",
        url:"./panel_consolidacion.php",
        data:{
            id_ali: id_ali
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
    var id_ali = '0';
    var ali_fecha = '2023-03-03';
    var ali_fecha_fin = '2023-03-03';
    var ali_objetivo = '0';
    var ali_dias = '0';
    var ali_observacion = '0';
    var id_plan_servi = '0';
    var id_cliente = '0';
    var id_nutriologo = '0';
    var id_act = '0';
    var alimento = '0';
    var cantidad = '0';
    var calorias = '0';
    var carbohidratos = '0';
    var proteinas = '0';
    if(operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4'){
        id_ali = $("#id_ali").val();
        ali_fecha = $("#ali_fecha").val();
        ali_fecha_fin = $("#ali_fecha_fin").val();
        ali_objetivo = $("#ali_objetivo").val();
        ali_dias = $("#ali_dias").val();
        ali_observacion = $("#ali_observacion").val();
        id_plan_servi = $("#id_plan_servi").val();
        id_cliente = $("#id_cliente").val();
        id_nutriologo = $("#id_nutriologo").val();
        console.log(id_ali);
        console.log(ali_fecha);
        console.log(ali_fecha_fin);
        console.log(ali_objetivo);
        console.log(ali_dias);
        console.log(ali_observacion);
        console.log(id_plan_servi);
        console.log(id_cliente);
        console.log(id_nutriologo);
    }
    if(operacion == '5'){
        id_ali = $("#id_ali").val();
        id_act = $("#agregar_id_act").val();
        alimento = $("#agregar_alimento").val();
        cantidad = $("#agregar_cantidad").val();
        calorias = $("#agregar_calorias").val();
        carbohidratos = $("#agregar_carbohidratos").val();
        proteinas = $("#agregar_proteinas").val();

    }
    if(operacion == '6'){
        id_ali = $("#id_ali").val();
        id_act = $("#mod_id_act").val();
        alimento = $("#mod_alimento").val();
        cantidad = $("#mod_cantidad").val();
        calorias = $("#mod_calorias").val();
        carbohidratos = $("#mod_carbohidratos").val();
        proteinas = $("#mod_proteinas").val();
    }
    if(operacion == '7'){
        id_ali = $("#id_ali").val();
        id_act = $("#eliminar_id_act").val();
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data:{
            id_ali: id_ali,
            ali_fecha: ali_fecha,
            ali_fecha_fin: ali_fecha_fin,
            ali_objetivo: ali_objetivo,
            ali_dias: ali_dias,
            ali_observacion: ali_observacion,
            id_plan_servi: id_plan_servi,
            id_cliente: id_cliente,
            id_nutriologo: id_nutriologo,    
            id_act: id_act,
            alimento: alimento,
            cantidad: cantidad,
            calorias: calorias,
            carbohidratos: carbohidratos,
            proteinas: proteinas,
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
    pane_planes();
    if(operacion == '1'){
        panel_datos(-2);
        //$('#btn-panel-pedidos').click ();
    }
    if(operacion == '2'|| operacion == '5' || operacion == '6' || operacion == '7' || operacion == '8'|| operacion == '9'|| operacion == '10'|| operacion == '11'){
        panel_datos($("#id_ali").val());
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
        llenarDatosAct();
    });
});

// Función para llenar datos
function llenarDatos() {
    const idCliente = document.getElementById('id_cliente').value;
    console.log('ID Cliente seleccionado:', idCliente);

    const clienteSeleccionada = datoCliente.find(d => d.id_cliente == idCliente);
    console.log('Cliente encontrado:', clienteSeleccionada);

    
    const generoSelect = document.getElementById('id_genero');
    const selectServicio = document.getElementById('id_plan_servi');

    // Limpiar campos
    
    generoSelect.innerHTML = '<option value="">Seleccione...</option>';
    selectServicio.innerHTML = '<option value="">Seleccione un servicio</option>';

    if (clienteSeleccionada) {
        

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

function llenarDatosAct() {
    // Obtener el ID de la factura seleccionada
    const idAccion = document.getElementById('agregar_id_act').value;

    // Buscar la factura correspondiente en el objeto datosCompras
    const actSeleccionada = datoAct.find(d => d.id_act === idAccion);

    const unidad = document.getElementById('unidad');

    if (actSeleccionada) {
        unidad.value = actSeleccionada.act_unidad;
    }else{
        unidad.value = '';

    }
}
