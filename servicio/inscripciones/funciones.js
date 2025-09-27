
$(function(){
    panel_inscripcion();
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

function panel_inscripcion(){
    $.ajax({
        url:"panel_inscripcion.php"
    }).done(function(resultado){
        $("#panel-pedidos").html(resultado);
        formato_tabla("#tabla_panel_inscripcion", 5);
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

function panel_estado_salud(id_cliente){
    //var id_es = $('#id_es').val();
    $.ajax({
        url:"panel_estado_salud.php",
        type:"POST",
        data:{
            id_cliente: id_cliente
            //id_es: id_es
        }
    }).done(function(resultado){
        $("#panel-estado-salud").html(resultado);
        $("#btn-panel-estado_salud").click();
        refrescar_select();
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

function agregar_estado_salud(){
    $("#operacion").val(8);
    grabar();
    $("#panel-estado-salud").modal('hide');
}

function cancelar(){
    panel_datos(-1);
    $("#btn-panel-pedidos").click();
    mensaje("CANCELADO","error");
}

function validarCampos(campos) {
    for (let i = 0; i < campos.length; i++) {
        let valor = $(campos[i].id).val();
        if (valor === "" || valor === null || valor === undefined) {
            Swal.fire({
                toast: true,
                position: 'top-end',
                type: 'error',
                title: "El campo '" + campos[i].nombre + "' está vacío",
                showConfirmButton: false,
                timer: 2500,
                timerProgressBar: true
            });
            $(campos[i].id).focus();
            return false;
        }
    }
    return true;
}

function grabar(){
    var operacion = $("#operacion").val();
    var id_inscrip = '0';
    var ins_aprobacion = '2021-01-01';
    var ins_edad = '0';
    var ins_peso = '0';
    var ins_altura = '0';
    var ins_seguro_medico = false;
    var id_cliente = "0";
    var id_es = '0';
    var id_plan_servi  = '0';
    var dia  = '0';
    if(operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4'){
        id_inscrip = $("#id_inscrip").val();
        id_cliente = $('#id_cliente').val();
        ins_aprobacion = $("#ins_aprobacion").val();
        ins_edad = $("#ins_edad").val();
        ins_peso = $("#ins_peso").val();
        ins_altura = $("#ins_altura").val();
        ins_seguro_medico = $("#ins_seguro_medico").val();
        if (!validarCampos([
            {id: '#id_cliente', nombre: 'Cliente'},
            {id: '#ins_aprobacion', nombre: 'Fecha de Vencimiento'},
            {id: '#ins_edad', nombre: 'Edad'},
            {id: '#ins_peso', nombre: 'Peso'},
            {id: '#ins_altura', nombre: 'Altura'},
            {id: '#ins_seguro_medico', nombre: 'Seguro Médico'}
        ])){return;}
    }
    if(operacion == '5'){
        id_inscrip = $("#id_inscrip").val();
        id_plan_servi  = $("#agregar_id_plan_servi").val();
        dia  = $("#agregar_dia ").val();
        if (!validarCampos([
            {id: '#agregar_id_plan_servi', nombre: 'Plan de Servicio'},
            {id: '#agregar_dia', nombre: 'Día'}
        ])){return;}
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
    if(operacion == '8'){
        id_cliente = $("#id_cliente").val();
        id_es = $('#id_es').val();
        if (!validarCampos([
            {id: '#id_es', nombre: 'Estado de Salud'}
        ])){return;}
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data:{
            id_inscrip: id_inscrip,
            ins_aprobacion: ins_aprobacion,
            ins_edad: ins_edad,
            ins_peso: ins_peso,
            ins_altura: ins_altura,
            ins_seguro_medico: ins_seguro_medico,
            id_cliente: id_cliente,
            id_es: id_es,
            id_plan_servi: id_plan_servi,
            dia: dia,
            operacion: operacion
        }
    }).done(function(resultado){
        if(verificar_mensaje(resultado)){
            postgrabar(operacion);
        }
        //postgrabar(operacion);
    }).fail(function (a, b, c) {
        //console.error(b);
        console.error("Error:", a, b, c); // Error detallado
    });
}

function postgrabar(operacion){
    panel_inscripcion();
    if(operacion == '1'){
        panel_datos(-2);
    }
    if(operacion == '2' || operacion == '5' || operacion == '6' || operacion == '7' || operacion == '8'){
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
function calcularEdad(fechaNacimiento) {
    // fechaNacimiento debe estar en formato YYYY-MM-DD
    fechaNacimiento = new Date(fechaNacimiento);
    const hoy = new Date();
    let edad = hoy.getFullYear() - fechaNacimiento.getFullYear();
    const mes = hoy.getMonth() - fechaNacimiento.getMonth();
    if (mes < 0 || (mes === 0 && hoy.getDate() < fechaNacimiento.getDate())) {
        edad--;
    }
    return edad;
}

function autCompletaEdad(){
    let id_cliente = document.getElementById('id_cliente').value;
    let ins_edad = document.getElementById('ins_edad');
    let fecha_nac = cliente.find(c => c.id_cliente == id_cliente).per_fenaci;
    console.log(fecha_nac);
    if (fecha_nac){
        let edad = calcularEdad(fecha_nac);
        ins_edad.value = edad;
    }else{
        ins_edad.value = '0';
    }
}

$(document).ready(function(){
    $(document).on('change', '#id_cliente', function() {
        autCompletaEdad();
    });
});

function generarContrato(id_inscrip) {
    // Abre una nueva ventana del navegador con la URL que incluye el parámetro id_cp
    window.open('./contrato.php?id_inscrip=' + id_inscrip, '_blank');
}

function autCompletaPromo(){
    let id_plan_servi = document.getElementById('agregar_id_plan_servi').value;
    let promociones = document.getElementById('promociones');
    let plan = articulos.find(p => p.id_plan_servi == id_plan_servi).pro_nombre;
    if (plan) {
        promociones.value = plan;
    } else {
        promociones.value = 'SIN PROMOCIÓN';
    }
}

function autCompletaDuracion(){
    let id_plan_servi = document.getElementById('agregar_id_plan_servi').value;
    let dia = document.getElementById('agregar_dia');
    let duracion = articulos.find(p => p.id_plan_servi == id_plan_servi).td_duracion;
    if (duracion) {
        dia.value = duracion;
    } else {
        dia.value = '0';
    }
}

$(document).ready(function(){
    $(document).on('change', '#agregar_id_plan_servi', function() {
        autCompletaPromo();
        autCompletaDuracion();
    });
});