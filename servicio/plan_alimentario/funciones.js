
$(function () {
    pane_planes();
    panel_datos(-1);
});

function refrescar_select() {
    $(".select2").select2();
    $(".select2").attr("style", "width: 100%;");
}

function formato_tabla(tabla, item_cantidad) {
    $(tabla).DataTable({
        "lengthChange": false,
        responsive: "true",
        "iDisplayLength": item_cantidad,
        language: {
            "sSearch": "Buscar: ",
            "sInfo": "Mostrando resultados del _START_ al _END_ de un total de _TOTAL_ registros",
            "sInfoFiltered": "(filtrado de entre _MAX_ registros)",
            "sInfoEmpty": "No hay resultados",
            "oPaginate": {
                "sNext": "Siguiente",
                "sPrevious": "Anterior"
            }
        }
    });
}

function pane_planes() {
    $.ajax({
        url: "pane_planes.php"
    }).done(function (resultado) {
        $("#pane-planes").html(resultado);
        formato_tabla("#tabla_pane_planes", 5);
    });
}

function panel_datos(id_ali) {
    $.ajax({
        url: "panel_datos.php",
        type: "POST",
        data: {
            id_ali: id_ali
        }
    }).done(function (resultado) {
        $("#panel-datos").html(resultado);
        refrescar_select();
    });
}


function datos(id_ali) {
    panel_datos(id_ali);
    $("#btn-panel-datos").click();
}

function agregar() {
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function modificar_detalle(id_act) {
    var id_ali = $("#id_ali").val();
    $.ajax({
        url: "panel_modificar.php",
        type: "POST",
        data: {
            id_ali: id_ali,
            id_act: id_act
        }
    }).done(function (resultado) {
        $("#panel-modificar").html(resultado);
        $("#btn-panel-modificar").click();
    });
}

function modalSecund() {
    $.ajax({
        type: "POST",
        url: "./panel_secundario.php"
        // ejecuta el llamado
    }).done(function (resultado) {
        $("#panel-secund").html(resultado);
        $("#btn-panel-secund").click();
    }).fail(function (a, b, c) {
        console.log(c);
    });
}

function modalConsolidacion(id_ali) {
    $.ajax({
        type: "POST",
        url: "./panel_consolidacion.php",
        data: {
            id_ali: id_ali
        }
        // ejecuta el llamado
    }).done(function (resultado) {
        $("#panel-consolidacion").html(resultado);
        $("#btn-panel-consolidacion").click();
    });
}


function generarInformes(id_ali) {
    window.open('recetas.php?id_ali=' + id_ali, '_blank');
}

function agregar_presupuesto_pedido(id_cp) {
    $("#id_cp").val(id_cp);
    $("#operacion").val(8);
    grabar();
    $("html, body").animate({ scrollTop: 0 }, "slow");
}

function agregar_grabar() {
    $("#operacion").val(1);
    grabar();
}

function modificar() {
    $("#operacion").val(2);
    grabar();
}

function confirmar() {
    $("#operacion").val(3);
    grabar();
}

function anular() {
    $("#operacion").val(4);
    grabar();
}

function agregar_detalles() {
    $("#operacion").val(5);
    grabar();
}

function modificar_detalle_grabar() {
    $("#operacion").val(6);
    grabar();
}

function eliminar_detalle(id_act) {
    $("#eliminar_id_act").val(id_act);
    $("#operacion").val(7);
    grabar();
}


function cancelar() {
    panel_datos(-1);
    $("#btn-panel-membresia").click();
    mensaje("CANCELADO", "error");
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


function grabar() {
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
    var id_res = '0';
    var cantidad = '0';
    var calorias = '0';
    var carbohidratos = '0';
    var proteinas = '0';
    if (operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4') {
        id_ali = $("#id_ali").val();
        ali_fecha = $("#ali_fecha").val();
        ali_fecha_fin = $("#ali_fecha_fin").val();
        ali_objetivo = $("#ali_objetivo").val();
        ali_dias = $("#ali_dias").val();
        ali_observacion = $("#ali_observacion").val();
        //id_plan_servi = $("#id_plan_servi").val();
        id_cliente = $("#id_cliente").val();
        if (!validarCampos([
            { id: '#ali_fecha', nombre: 'Fecha Inicio' },
            { id: '#ali_fecha_fin', nombre: 'Fecha Fin' },
            { id: '#ali_objetivo', nombre: 'Objetivo' },
            { id: '#ali_dias', nombre: 'Días de la semana' },
            { id: '#id_cliente', nombre: 'Cliente' }
        ])) {
            return;
        }
    }
    if (operacion == '5') {
        id_ali = $("#id_ali").val();
        id_act = $("#agregar_id_act").val();
        id_res = $("#agregar_id_res").val();
        cantidad = $("#agregar_cantidad").val();
        calorias = $("#agregar_calorias").val();
        carbohidratos = $("#agregar_carbohidratos").val();
        proteinas = $("#agregar_proteinas").val();
        if (!validarCampos([
            { id: '#agregar_id_act', nombre: 'Tipo de Comida' },
            { id: '#agregar_id_res', nombre: 'Comida' },
            { id: '#agregar_cantidad', nombre: 'Cantidad' },
            { id: '#agregar_calorias', nombre: 'Calorías' },
            { id: '#agregar_carbohidratos', nombre: 'Carbohidratos' },
            { id: '#agregar_proteinas', nombre: 'Proteínas' }
        ])) {
            return;
        }

    }
    if (operacion == '6') {
        id_ali = $("#id_ali").val();
        id_act = $("#id_act").val();
        //alimento = $("#mod_alimento").val();
        cantidad = $("#mod_cantidad").val();
        calorias = $("#mod_calorias").val();
        carbohidratos = $("#mod_carbohidratos").val();
        proteinas = $("#mod_proteinas").val();
        if (!validarCampos([
            { id: '#mod_cantidad', nombre: 'Cantidad' },
            { id: '#mod_calorias', nombre: 'Calorías' },
            { id: '#mod_carbohidratos', nombre: 'Carbohidratos' },
            { id: '#mod_proteinas', nombre: 'Proteínas' }
        ])) {
            return;
        }
    }
    if (operacion == '7') {
        id_ali = $("#id_ali").val();
        id_act = $("#eliminar_id_act").val();
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data: {
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
            id_res: id_res,
            cantidad: cantidad,
            calorias: calorias,
            carbohidratos: carbohidratos,
            proteinas: proteinas,
            operacion: operacion
        }
    }).done(function (resultado) {
        if (verificar_mensaje(resultado)) {
            //postgrabar(operacion);
        }
        postgrabar(operacion);
    }).fail(function (a, b, c) {
        console.error('Error:', a, b, c);
    });
}

function postgrabar(operacion) {
    pane_planes();
    if (operacion == '1') {
        panel_datos(-2);
        //$('#btn-panel-pedidos').click ();
    }
    if (operacion == '2' || operacion == '5' || operacion == '6' || operacion == '7' || operacion == '8' || operacion == '9' || operacion == '10' || operacion == '11') {
        panel_datos($("#id_ali").val());
        if (operacion == '6') {
            $("#btn-panel-modificar-cerrar").click();
        }
    }
    if (operacion == '8') {
        $("#btn-modal-secund-cerrar").click();
    }
    if (operacion == '3' || operacion == '4') {
        panel_datos(-1);

    }
}


$(document).ready(function () {
    $(document).on('change', '#id_cliente', function () {
        llenarDatos();
    });
});

$(document).ready(function () {
    $(document).on('change', '#agregar_id_act', function () {
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
    } else {
        unidad.value = '';

    }
}

function autoCompletaComida() {
    const idRes = document.getElementById('agregar_id_res').value;
    const calorias = document.getElementById('agregar_calorias');
    const carbohidratos = document.getElementById('agregar_carbohidratos');
    const proteinas = document.getElementById('agregar_proteinas');

    // Buscar la factura correspondiente en el objeto datosCompras
    const resSeleccionada = datoRes.find(d => d.id_res === idRes);

    if (resSeleccionada) {
        calorias.value = resSeleccionada.res_calorias;
        carbohidratos.value = resSeleccionada.res_carbohidratos;
        proteinas.value = resSeleccionada.res_proteinas;
    } else {
        calorias.value = '0';
        carbohidratos.value = '0';
        proteinas.value = '0';

    }
}

$(document).ready(function () {
    $(document).on('change', '#agregar_id_res', function () {
        autoCompletaComida();
    });
});