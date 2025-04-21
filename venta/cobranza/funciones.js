
$(function(){
    panel_cobros();
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

function panel_cobros(){
    $.ajax({
        url:"panel_cobros.php"
    }).done(function(resultado){
        $("#panel-cobros").html(resultado);
        formato_tabla("#tabla_panel_cobros", 5);
    });
}

function panel_datos(id_cob){
    $.ajax({
        url:"panel_datos.php",
        type:"POST",
        data:{
            id_cob: id_cob
        }
    }).done(function(resultado){
        $("#panel-datos").html(resultado);
        refrescar_select();
    });
}

function datos(id_cob){
    panel_datos(id_cob);
    $("#btn-panel-datos").click();
}

function generarInforme(id_cob) {
    // Abre una nueva ventana del navegador con la URL que incluye el parámetro id_cob
    //window.open('./reporte.php?id_cob=' + id_cob, '_blank');
    window.open('../../reportes/compra/reporte.php?id_cob=' + id_cob, '_blank');
}


function agregar(){
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function agregar_cuenta(id_vc,id_cue){
    $.ajax({
        url:"./paneles_cobro/panel_detalle.php",
        type:"POST",
        data:{
            id_vc: id_vc,
            id_cue: id_cue
        }
    }).done(function(resultado){
        $("#panel-detalle").html(resultado);
        $("#btn-panel-detalle").click();
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

// function agregar_detalles(){
//     $("#operacion").val(5);
//     grabar();
// }

function agregar_detalle_grabar(){
    $("#operacion").val(5);
    grabar();
}

function eliminar_detalle(id_cue){
    $("#eliminar_id_cue").val(id_cue);
    $("#operacion").val(7);
    grabar();
}

function cancelar(){
    panel_datos(-1);
    $("#btn-panel-cobros").click();
    mensaje("CANCELADO","error");
}

function grabar(){
    var operacion = $("#operacion").val();
    var id_cob = '0';
    var cob_fecha = '2021-01-01';
    var id_vac = '0';
    var id_caja = '0';
    var id_vc = '0';
    var id_cue = '0';
    var id_fc = '0';
    var cob_monto_efe = '0';
    var monto = '0';
    var che_nro_cheque = '0';
    var che_vencimiento = '2021-01-01';
    var che_monto = '0';
    var che_tipo_cheque = '0';
    var id_ee = '0';
    var id_ee_des = '0';
    var tar_nro_tarjeta = '0';
    var tar_vencimiento = '2021-01-01';
    var tar_monto = '0';
    var id_mt = '0';
    var tra_nro_cuenta = '0';
    var tra_monto = '0';
    var tra_motivo = '0';
    if(operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4'){
        id_cob = $("#id_cob").val();
        cob_fecha = $("#cob_fecha").val();
        id_vac = $("#id_vac").val();
        id_caja = $("#id_caja").val();
        id_vc = $("#id_vc").val();
    }
    if(operacion == '5'){
        id_cob = $("#id_cob").val();
        id_cue = $("#id_cue").val();
        id_fc = $("#id_fc").val();
        cob_monto_efe = $("#cob_monto_efe").val();
        monto = $("#monto").val();
        console.log(id_cob);
        console.log(id_cue);
        console.log(id_fc);
        console.log(cob_monto_efe);
        console.log(monto);
    }
    if(operacion == '6'){
        id_cob = $("#id_cob").val();
        id_cue = $("#modificar_id_cue").val();
        id_fc = $("#modificar_id_fc").val();
        cob_monto_efe = $("#modificar_cob_monto_efe").val();
        monto = $("#modificar_monto").val();
    }
    if(operacion == '7'){
        id_cob = $("#id_cob").val();
        id_cue = $("#id_cue").val();
    }
    if(operacion == '8'){
        id_ee = $("#id_ee").val();
        che_nro_cheque = $("#che_nro_cheque").val();
        che_vencimiento = $("#che_vencimiento").val();
        che_monto = $("#che_monto").val();
        che_tipo_cheque = $("#che_tipo_cheque").val();
        
    }
    if(operacion == '9'){
        id_ee = $("#id_ee").val();
        tar_nro_tarjeta = $("#tar_nro_tarjeta").val();
        tar_vencimiento = $("#tar_vencimiento").val();
        tar_monto = $("#tar_monto").val();
        id_mt = $("#id_mt").val();
    }
    if(operacion == '10'){
        id_ee = $("#id_ee").val();
        id_ee_des = $("#id_ee_des").val();
        tra_nro_cuenta = $("#tra_nro_cuenta").val();
        tra_monto = $("#tra_monto").val();
        tra_motivo = $("#tra_motivo").val();
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data:{
            id_cob: id_cob,
            cob_fecha: cob_fecha,
            id_vac: id_vac,
            id_caja: id_caja,
            id_vc: id_vc,
            id_cue: id_cue,
            id_fc: id_fc,
            cob_monto_efe: cob_monto_efe,
            monto: monto,
            che_nro_cheque: che_nro_cheque,
            che_vencimiento: che_vencimiento,
            che_monto: che_monto,
            che_tipo_cheque: che_tipo_cheque,
            id_ee: id_ee,
            id_ee_des: id_ee_des,
            tar_nro_tarjeta: tar_nro_tarjeta,
            tar_vencimiento: tar_vencimiento,
            tar_monto: tar_monto,
            id_mt: id_mt,
            tra_nro_cuenta: tra_nro_cuenta,
            tra_monto: tra_monto,
            tra_motivo: tra_motivo,
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
    panel_cobros();
    if(operacion == '1'){
        panel_datos(-2);
    }
    if(operacion == '2' || operacion == '5' || operacion == '6' || operacion == '7'){
        panel_datos($("#id_cob").val());
        if(operacion == '6'){
            $("#btn-panel-modificar-cerrar").click();
        }
    }
    if(operacion == '3' || operacion == '4'){
        panel_datos(-1);
        $("#btn-panel-cobros").click();
    }
}

function autoCompCaja(){
    const idVac = document.getElementById("id_vac").value;
    const idCaja = document.getElementById("id_caja");

    const selecttedOption = apertura.find(a => a.id_vac == idVac);
    if (selecttedOption) {
        idCaja.value = selecttedOption.id_caja;
    } else {
        idCaja.value = "";
    }
    
}

$(document).ready(function() {
    $(document).on('change', '#id_vac', function() {
        autoCompCaja();
    });
});