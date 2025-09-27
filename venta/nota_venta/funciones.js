
$(function(){
    panel_notas();
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

function panel_notas(){
    $.ajax({
        url:"panel_notas.php"
    }).done(function(resultado){
        $("#panel-notas").html(resultado);
        formato_tabla("#tabla_panel_notas", 5);
    });
}

function panel_datos(id_not){
    $.ajax({
        url:"panel_datos.php",
        type:"POST",
        data:{
            id_not: id_not
        }
    }).done(function(resultado){
        $("#panel-datos").html(resultado);
        refrescar_select();
            $(document).ready(function () {
                filtrarMotivos();
            });
    });
}


function datos(id_not){
    panel_datos(id_not);
    $("#btn-panel-datos").click();
}

function generarInforme(id_not) {
    // Abre una nueva ventana del navegador con la URL que incluye el parámetro id_not
    //window.open('./reporte.php?id_not=' + id_not, '_blank');
    window.open('../../reportes/compra/reporte.php?id_not=' + id_not, '_blank');
}


function agregar(){
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function modificar_detalle(id_not,id_item){
    var id_not = $("#id_not").val();
    console.log(id_not);
    console.log(id_item);
    $.ajax({
        url:"panel_modificar.php",
        type:"POST",
        data:{
            id_not: id_not,
            id_item: id_item
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

function eliminar_detalle(cod_item){
    $("#eliminar_id_item").val(cod_item);
    $("#operacion").val(7);
    grabar();
}

function cancelar(){
    panel_datos(-1);
    $("#btn-panel-notas").click();
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
    var id_not = '0';
    var not_fecha_elab = '2021-01-01';
    var not_fecha_emis = '2021-01-01';
    var not_tipo_nota = '0';
    var not_observacion = '';
    var not_nro_documento = '';
    var id_vc = '0';
    var id_tm = '0';
    var id_tim = '0';
    var id_cliente = '0';
    var id_item = '0';
    var cantidad = '0';
    var monto = '0';
    if(operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4'){
        id_not = $("#id_not").val();
        not_fecha_elab = $("#not_fecha_elab").val();
        not_fecha_emis = $("#not_fecha_emis").val();
        not_tipo_nota = $("#not_tipo_nota").val();
        not_observacion = $("#not_observacion").val();
        not_nro_documento = $("#not_nro_documento").val();
        id_vc = $("#id_vc").val();
        id_tm = $("#id_tm").val();
        id_tim = $("#id_tim").val();
        id_cliente = $("#id_cliente").val();
        if(!validarCampos([
            {id: "#not_fecha_elab", nombre: "Fecha de Emisión"},
            {id: "#not_fecha_emis", nombre: "Fecha de la Factura"},
            {id: "#not_tipo_nota", nombre: "Tipo de Nota"},
            {id: "#id_vc", nombre: "Factura"},
            {id: "#id_tm", nombre: "Motivo"},
            {id: "#id_cliente", nombre: "Cliente"}
        ])){
            return;
        }
    }
    if(operacion == '5'){
        id_not = $("#id_not").val();
        id_item = $("#agregar_id_item").val();
        cantidad = $("#agregar_cantidad").val();
        monto = $("#agregar_monto").val();
        if(!validarCampos([
            {id: "#agregar_id_item", nombre: "Concepto"},
            {id: "#agregar_cantidad", nombre: "Cantidad"},
            {id: "#agregar_monto", nombre: "Monto"}
        ])){
            return;
        }
    }
    if(operacion == '6'){
        id_not = $("#id_not").val();
        id_item = $("#modificar_id_item").val();
        cantidad = $("#modificar_cantidad").val();
        monto = $("#modificar_precio").val();
        if(!validarCampos([
            {id: "#modificar_cantidad", nombre: "Cantidad"},
            {id: "#modificar_precio", nombre: "Monto"}
        ])){
            return;
        }
    }
    if(operacion == '7'){
        id_not = $("#id_not").val();
        id_item = $("#eliminar_id_item").val();
        console.log(id_not, id_item);
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data:{
            id_not: id_not,
            not_fecha_elab: not_fecha_elab,
            not_fecha_emis: not_fecha_emis,
            not_tipo_nota: not_tipo_nota,
            not_observacion: not_observacion,
            not_nro_documento: not_nro_documento,
            id_vc: id_vc,
            id_tm: id_tm,
            id_tim: id_tim,
            id_cliente: id_cliente,
            id_item: id_item,
            cantidad: cantidad,
            monto: monto,
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
    panel_notas();
    if(operacion == '1'){
        panel_datos(-2);
    }
    if(operacion == '2' || operacion == '5' || operacion == '6' || operacion == '7'){
        panel_datos($("#id_not").val());
        if(operacion == '6'){
            $("#btn-panel-modificar-cerrar").click();
        }
    }
    if(operacion == '3' || operacion == '4'){
        panel_datos(-1);
        $("#btn-panel-notas").click();
    }
}


function autollenar() {
    // Obtener el ID de la factura seleccionada
    const idFactura = document.getElementById('id_vc').value;

    // Buscar la factura correspondiente en el objeto datosCompras
    const facturaSeleccionada = datosVentas.find(venta => venta.id_vc === idFactura);

    if (facturaSeleccionada) {
        // Rellenar la fecha del documento
        document.getElementById('not_fecha_emis').value = facturaSeleccionada.vc_fecha;

        // Rellenar el proveedor
        const clieteSelect = document.getElementById('id_cliente');
        clieteSelect.innerHTML = ''; // Limpiar opciones previas
        const option = document.createElement('option');
        option.value = facturaSeleccionada.id_cliente;
        option.textContent = facturaSeleccionada.cliente;
        option.selected = true; // Seleccionar automáticamente
        clieteSelect.appendChild(option);
    }
}

function filtrarMotivos() {
    // Cuando cambie el select de tipo de nota
    // $('#not_tipo_nota').on('change', function () {
    //     let tipoNota = $(this).val(); // CREDITO, DEBITO, REMISION
    //     let codigoFiltro = '';
    //     let timbrados = 0;

    //     // Relación entre el valor del select y el código que viene en tm_codigo
    //     if (tipoNota === 'CREDITO') codigoFiltro = 'NC';
    //     if (tipoNota === 'DEBITO') codigoFiltro = 'ND';
    //     //if (tipoNota === 'REMISION') codigoFiltro = 'RM';

    //     // Limpiar el select de motivos
    //     $('#id_tm').empty().append('<option value="" selected="true" disabled="disabled">Seleccione un motivo</option>');

    //     // Filtrar los motivos por el código
    //     let motivosFiltrados = motivosFiltro.filter(m => m.tm_codigo === codigoFiltro);

    //     // Cargar los motivos filtrados en el select
    //     motivosFiltrados.forEach(m => {
    //         $('#id_tm').append(`<option value="${m.id_tm}">${m.tm_descrip}</option>`);
    //     });

    //     // Refrescar el select2 si lo estás usando
    //     $('#id_tm').trigger('change');
    // });
    $('#not_tipo_nota').on('change', function () {
        let tipoNota = $(this).val(); // CREDITO, DEBITO, REMISION
        let codigoFiltro = '';
        let idTimbrado = null;

        // Relación entre tipo de nota y código de motivo + timbrado
        if (tipoNota === 'CREDITO') {
            codigoFiltro = 'NC';
            idTimbrado = 4; // el timbrado para crédito
        }
        if (tipoNota === 'DEBITO') {
            codigoFiltro = 'ND';
            idTimbrado = 5; // el timbrado para débito
        }
        if (tipoNota === 'REMISION') {
            codigoFiltro = 'RM';
            idTimbrado = null; // si no hay timbrado para remisión
        }

        // --- 1) Filtrar motivos ---
        $('#id_tm').empty().append('<option value="">Seleccione un motivo</option>');
        let motivosFiltrados = motivosFiltro.filter(m => m.tm_codigo === codigoFiltro);
        motivosFiltrados.forEach(m => {
            $('#id_tm').append(`<option value="${m.id_tm}">${m.tm_descrip}</option>`);
        });
        $('#id_tm').trigger('change');

        // --- 2) Asignar timbrado ---
        if (idTimbrado) {
            let timbrado = timbradoFiltro.find(t => t.id_tim == idTimbrado);
            if (timbrado) {
                $('#not_nro_documento').val(timbrado.numero_factura);
                $('#id_tim').val(timbrado.id_tim);
            } else {
                $('#not_nro_documento').val('');
                $('#id_tim').val('');
            }
        } else {
            $('#not_nro_documento').val('');
            $('#id_tim').val('');
        }
    });
}


