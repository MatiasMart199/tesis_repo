
$(function () {
    panel_cobros();
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


function panel_cobros() {
    $.ajax({
        url: "panel_cobros.php"
    }).done(function (resultado) {
        $("#panel-cobros").html(resultado);
        formato_tabla("#tabla_panel_cobros", 5);
    });
}

function panel_datos(id_cob) {
    $.ajax({
        url: "panel_datos.php",
        type: "POST",
        data: {
            id_cob: id_cob
        }
    }).done(function (resultado) {
        $("#panel-datos").html(resultado);
        refrescar_select();
        //$(document).on("change", "#id_vac", function() {
        autoCompCaja();
        //});
        //formato_tabla("#tabla_cuentas", 2);
    });
}

function datos(id_cob) {
    panel_datos(id_cob);
    $("#btn-panel-datos").click();
}

function generarInforme(id_cob) {
    // Abre una nueva ventana del navegador con la URL que incluye el parámetro id_cob
    //window.open('./reporte.php?id_cob=' + id_cob, '_blank');
    window.open('../../reportes/compra/reporte.php?id_cob=' + id_cob, '_blank');
}


function agregar() {
    panel_datos(0);
    $("#btn-panel-datos").click();
}

//*******************************************   */
function cuentas(id_vc, id_cob) {
    // console.log(id_vc);
    // console.log(id_cob);
    $.ajax({
        url: "./paneles_cobro/panel_cuentas.php",
        type: "POST",
        data: {
            id_vc: id_vc,
            id_cob: id_cob
        }
    }).done(function (resultado) {
        $("#panel-cuentas").html(resultado);
        $("#btn-panel-cuentas").click();
        formato_tabla("#tabla_cuentas", 5);
    });
}

// function agregar_cuenta(id_vc,id_cue){

//     $.ajax({
//         url:"./paneles_cobro/panel_detalle.php",
//         type:"POST",
//         data:{
//             id_vc: id_vc,
//             id_cue: id_cue
//         }
//     }).done(function(resultado){
//         $("#panel-cuentas").modal("hide");
//         $("#panel-detalle").html(resultado);
//         $("#btn-panel-detalle").click();
//         agregar_detalle_grabar();
//         $("#panel-detalle").modal("hide"); 

//     });
// }

function agregar_cuenta(id_vc, id_cue) {
    $.ajax({
        url: "./paneles_cobro/panel_detalle.php",
        type: "POST",
        data: {
            id_vc: id_vc,
            id_cue: id_cue
        }
    }).done(function (resultado) {
        $("#panel-cuentas").modal("hide");
        // Cargo el formulario dentro del div oculto
        $("#panel-detalle").html(resultado);

        // Si igual necesitás que se "dispare" la apertura antes de ocultarlo
        // $("#btn-panel-detalle").click();

        // Ahora que ya está cargado el HTML, llamo a mi función que lee los inputs
        agregar_detalle_grabar();

        // Cierro la modal en caso de que se haya abierto
        $("#panel-detalle").modal("hide");
    });
}

function panel_modificar(id_cob, id_cue) {
    $.ajax({
        url: "./paneles_cobro/panel_modificar.php",
        type: "POST",
        data: {
            id_cob: id_cob,
            id_cue: id_cue
        }
    }).done(function (resultado) {
        $("#panel-modificar").html(resultado);
        $("#btn-panel-modificar").click();
        refrescar_select();

        // Por ejemplo al abrir la modal
        $("#panel-modificar").on("shown.bs.modal", function () {
            validarMonto("modificar_cob_monto_efe");
        });

    });
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

function agregar_detalle_grabar() {
    $("#operacion").val(5);
    grabar();
    //$("#panel-detalle").modal("hide");
}

function modificar_detalle() {
    $("#operacion").val(6);
    grabar();
    $('#panel-modificar').modal('hide');
}

function eliminar_detalle(id_cue) {
    $("#eliminar_id_cue").val(id_cue);
    $("#operacion").val(7);
    grabar();
}

function cancelar() {
    panel_datos(-1);
    $("#btn-panel-cobros").click();
    mensaje("CANCELADO", "error");
}

//AGREGAR LOS DIFERENTES TIPOS DE COBROS
function agregar_cheque_grabar() {
    $("#operacion").val(8);
    grabar();
    $('#panel-cheque').modal('hide');
}

function agregar_tarjeta_grabar() {
    $("#operacion").val(9);
    grabar();
    $('#panel-tarjeta').modal('hide');
}
function agregar_transferencia_grabar() {
    $("#operacion").val(10);
    grabar();
    $('#panel-transferencia').modal('hide');
}

//***************************************** */
function agregar_cobro(id_cob, id_fc) {
    let id_cue = $("#id_cue_f").val();
    //FORMA COBRO CHEQUE
    if (id_fc == 1) {
        $.ajax({
            url: "./paneles_cobro/panel_cheque.php",
            type: "POST",
            data: {
                id_cob: id_cob,
                id_fc: id_fc,
                id_cue: id_cue
            }
        }).done(function (resultado) {
            $("#panel-cheque").html(resultado);
            $("#btn-panel-cheque").click();

            // Por ejemplo al abrir la modal
            $("#panel-cheque").on("shown.bs.modal", function () {
                validarMonto("che_monto");
            });

        });

        //FORMA COBRO TARJETA
    } else if (id_fc == 2) {
        $.ajax({
            url: "./paneles_cobro/panel_tarjeta.php",
            type: "POST",
            data: {
                id_cob: id_cob,
                id_fc: id_fc,
                id_cue: id_cue
            }
        }).done(function (resultado) {
            $("#panel-tarjeta").html(resultado);
            $("#btn-panel-tarjeta").click();

            // Por ejemplo al abrir la modal
            $("#panel-tarjeta").on("shown.bs.modal", function () {
                validarMonto("tar_monto");
            });
        });

        //FORMA COBRO TRANSFERENCIA
    } else if (id_fc == 3) {
        $.ajax({
            url: "./paneles_cobro/panel_transferencia.php",
            type: "POST",
            data: {
                id_cob: id_cob,
                id_fc: id_fc,
                id_cue: id_cue
            }
        }).done(function (resultado) {
            $("#panel-transferencia").html(resultado);
            $("#btn-panel-transferencia").click();
            refrescar_select();

            // Por ejemplo al abrir la modal
            $("#panel-transferencia").on("shown.bs.modal", function () {
                validarMonto("tra_monto");
            });
        });
    }
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
function validarApertura(campos) {
    for (let i = 0; i < campos.length; i++) {
        let valor = $(campos[i].id).val();
        if (valor === "" || valor === null || valor === undefined) {
            Swal.fire({
                toast: true,
                position: 'top-end',
                type: 'error',
                title: "El cajero no tiene una'" + campos[i].nombre + "' activo",
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
function validarMonto(inputMonto) {
    const input = document.getElementById(inputMonto);

    if (!input) {
        console.error("No se encontró el input con id:", inputMonto);
        return;
    }

    input.addEventListener("input", function () {
        let max = parseFloat(this.max) || Infinity;
        let min = parseFloat(this.min) || 0;
        let val = parseFloat(this.value);

        //console.log("Valor ingresado:", val, "Min:", min, "Max:", max);

        if (isNaN(val)) return; // si está vacío, no valida todavía

        if (val < min) {
            this.value = min;
        } else if (val > max) {
            this.value = max;
        }
    });

    // dispara la validación inicial
    input.dispatchEvent(new Event("input"));
}




function grabar() {
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
    if (operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4') {
        id_cob = $("#id_cob").val();
        cob_fecha = $("#cob_fecha").val();
        id_vac = $("#id_vac").val();
        id_caja = $("#id_caja").val();
        id_vc = $("#id_vc").val();
        if (!validarApertura([
            { id: "#id_vac", nombre: "apertura y cierre" }
        ])) {
            return; // ❌ corta si falta un campo
        }
        if (!validarCampos([
            { id: "#id_cob", nombre: "Codigo" },
            { id: "#cob_fecha", nombre: "Fecha" },
            { id: "#id_caja", nombre: "Caja" },
            { id: "#id_vc", nombre: "Nro Factura" }
        ])) {
            return; // ❌ corta si falta un campo
        }

    }
    if (operacion == '5') {
        id_cob = $("#id_cob").val();
        id_cue = $("#id_cue").val();
        //id_fc = $("#id_fc").val();
        cob_monto_efe = $("#cob_monto_efe").val() || 0;
        monto = $("#monto").val();
        console.log("Monto "+cob_monto_efe);
        //validarMonto("cob_monto_efe");
    }
    if (operacion == '6') {
        id_cob = $("#id_cob").val();
        id_cue = $("#id_cue").val();
        id_fc = $("#modificar_id_fc").val();
        cob_monto_efe = $("#modificar_cob_monto_efe").val(); // ya corregido
    }
    if (operacion == '7') {
        id_cob = $("#id_cob").val();
        id_cue = $("#id_cue").val();
    }
    if (operacion == '8') {
        id_cob = $("#id_cob").val();
        id_cue = $("#id_cue").val();
        id_fc = $("#id_fc_f").val();
        id_ee = $("#id_ee").val();
        che_nro_cheque = $("#che_nro_cheque").val();
        che_vencimiento = $("#che_vencimiento").val();
        che_monto = $("#che_monto").val();
        che_tipo_cheque = $("#che_tipo_cheque").val();
        //console.log(id_cob, id_cue, id_fc, id_ee, che_nro_cheque, che_vencimiento, che_monto, che_tipo_cheque);

    }
    if (operacion == '9') {
        id_cob = $("#id_cob").val();
        id_cue = $("#id_cue").val();
        id_ee = $("#id_ee").val();
        tar_nro_tarjeta = $("#tar_nro_tarjeta").val();
        tar_vencimiento = $("#tar_vencimiento").val();
        tar_monto = $("#tar_monto").val();
        id_mt = $("#id_mt").val();
        id_fc = $("#id_fc_f").val();
    }
    // cobro tranferencia
    if (operacion == '10') {
        id_cob = $("#id_cob").val();
        id_cue = $("#id_cue").val();
        id_ee = $("#id_ee_ori").val();
        id_ee_des = $("#id_ee_des").val();
        tra_nro_cuenta = $("#tra_nro_cuenta").val();
        tra_monto = $("#tra_monto").val();
        tra_motivo = $("#tra_motivo").val();
        id_fc = $("#id_fc_f").val();
        console.log(id_cob, id_cue, id_ee, id_ee_des, tra_nro_cuenta, tra_monto, tra_motivo, id_fc);

    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data: {
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
    }).done(function (resultado) {
        if (verificar_mensaje(resultado)) {
            postgrabar(operacion);
        }
        //postgrabar(operacion);
    }).fail(function (a, b, c) {
        console.error('Error:', a, b, c);
    });
}

function postgrabar(operacion) {
    panel_cobros();
    if (operacion == '1') {
        panel_datos(-2);
    }
    if (operacion == '2' || operacion == '5' || operacion == '6' || operacion == '7' || operacion == '8' || operacion == '9' || operacion == '10') {
        panel_datos($("#id_cob").val());
        if (operacion == '6') {
            $("#btn-panel-modificar-cerrar").click();
        }
    }
    if (operacion == '3' || operacion == '4') {
        panel_datos(-1);
        $("#btn-panel-cobros").click();
    }
}

// function autoCompCaja(){
//     const idVac = document.getElementById("id_vac").value;
//     const idCaja = document.getElementById("id_caja");

//     const selecttedOption = apertura.find(a => a.id_vac == idVac);
//     if (selecttedOption) {
//         idCaja.value = selecttedOption.id_caja;
//     } else {
//         idCaja.value = "";
//     }  
// }

function autoCompCaja() {
    const select = document.getElementById('id_vac');
    let option = select.options[select.selectedIndex];

    // Recuperar los atributos con dataset
    let id_vac = option.value;
    let id_funcionario = option.dataset.id_funcionario;
    let funcionario = option.dataset.funcionario;
    let id_caja = option.dataset.id_caja;
    let caj_descrip = option.dataset.caj_descrip;

    // Asignar valores
    document.getElementById('id_funcionario').innerHTML = `<option value="${id_funcionario}" selected>${funcionario}</option>`;
    document.getElementById('id_caja').innerHTML = `<option value="${id_caja}" selected>${caj_descrip}</option>`;

    // Opcional: setear tooltip (title)
    document.getElementById('id_funcionario').setAttribute("title", funcionario);
    document.getElementById('id_caja').setAttribute("title", caj_descrip);
    console.log(id_funcionario, funcionario, id_caja, caj_descrip);
}


function autoCompAdherida() {
    const id_ee = document.getElementById("id_ee").value;
    const id_mt = document.getElementById("id_mt");
    const selecttedOption = adheridas.find(a => a.id_ee == id_ee);
    if (selecttedOption) {
        id_mt.value = selecttedOption.id_mt;
    }
    else {
        id_mt.value = "";
    }
}

// Se ejecuta cuando el DOM está completamente cargado
$(document).ready(function () {
    $(document).on('change', '#id_vac', function () {
        autoCompCaja();
    });
});

$(document).ready(function () {
    $(document).on('change', '#id_ee', function () {
        autoCompAdherida();
    });
});

function habilitar_monto() {
    let id_fc = $("#modificar_id_fc").val();
    if (id_fc != 4) {
        $("#modificar_cob_monto_efe").prop("disabled", true);
        //$("#monto_f").val($("#cob_monto_efe").val());
    } else {
        $("#modificar_cob_monto_efe").prop("disabled", false);
        //$("#monto_f").val(0);
    }
}
$(document).ready(function () {
    $(document).on('change', '#modificar_id_fc', function () {
        habilitar_monto();
    });
});