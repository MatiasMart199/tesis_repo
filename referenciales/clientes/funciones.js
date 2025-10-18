$(function() {
  datos();
  $('body').on("keydown", function (e) {
    if (e.ctrlKey && e.which === 81) {
      agregar();
    }
    $("#tecla_presionada").val(e.keyCode);
  })
})


function datos() {
  // hace el llamado
  $.ajax({
      type:"POST",
      url:"datos.php"
  // ejecuta el llamado
  }).done(function(resultado){
      $("#div_datos").html(resultado);
      formato_tabla("#tabla_datos",10);
  });
}



function formato_tabla(tabla, cantidad){
  $(tabla).DataTable({
    "lengthChange": false,
    responsive: "true",
    "iDisplayLength": cantidad,
      language: {
        "sSearch":"Buscar: ",
        "sInfo":"Mostrando resultados del _START_ al _END_ de un total de _TOTAL_ registros",
        "sInfoFiltered": "(filtrado de entre _MAX_ registros)",
        "sZeroRecords":"No hay resultados",
        "sInfoEmpty":"No hay resultados",
        "oPaginate":{
        "sNext":"Siguiente",
        "sPrevious":"Anterior"
      }
    }
  });
}

function agregar() {
   // hace el llamado
    $.ajax({
      type:"POST",
      url:"./agregar.php"
  // ejecuta el llamado
  }).done(function(resultado){
      $("#modal-agregar-fisica").html(resultado);
      $("#btn-modal-agregar-fisica").click();
      // $("#modal-agregar-fisica").on("shown.bs.modal", function () {
      //       validarMonto("per_ruc");
      //       validarMonto("per_ci");
      //   });
  });
}



function agregar_grabar() {
  $("#operacion").val(1);
  grabar();
}



function editar(id_cliente) {
  $.ajax({
    type: "POST",
    url: "./editar.php",
    data:{
      id_cliente: id_cliente
    }
  }).done(function(resultado){
    $("#modal-editar-fisica").html(resultado);
    $("#btn-modal-editar-fisica").click();
  });
}

function editar_grabar() {
  $("#operacion").val(2);
  grabar();
}

function activar(id_cliente) {
  $("#id_cliente").val(id_cliente);
  $("#operacion").val(3);
  grabar();
}

function inactivar(id_cliente) {
  $("#id_cliente").val(id_cliente);
  $("#operacion").val(4);
  grabar();
}

// function validarMonto(inputMonto) {
//     const input = document.getElementById(inputMonto);
//     input.addEventListener("input", function () {
//         let max = parseFloat(this.max) || Infinity;
//         let min = parseFloat(this.min) || 0;
//         let val = parseFloat(this.value);

//         //console.log("Valor ingresado:", val, "Min:", min, "Max:", max);

//         if (isNaN(val)) return; // si está vacío, no valida todavía

//         if (val < min) {
//             this.value = min;
//         } else if (val > max) {
//             this.value = max;
//         }
//     });
// }

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
  var id_cliente = '0';
  var per_nombre = 'N/A';
  var per_apellido = 'N/A';
  var per_ruc = '0';
  var per_ci = 'N/A';
  var per_direccion = '0';
  var per_correo = '0';
  var per_fenaci = '2003-03-03';
  var per_telefono = '0';
  var id_ciudad = '0';
  var id_ecivil = '1';
  var id_genero = '3';
  var operacion = $("#operacion").val();
  if (operacion == '1') {                   //INSERTA PERSONA FISICA
    id_cliente = $("#id_cliente").val();
    per_nombre  = $("#agregar_nombre").val();
    per_apellido = $("#agregar_apellido").val();
    per_ruc = $("#agregar_ruc").val();
    per_ci = $("#agregar_ci").val();
    per_direccion = $("#agregar_direccion").val();
    per_correo = $("#agregar_correo").val();
    per_fenaci = $("#agregar_fenaci").val();
    per_telefono = $("#agregar_telefono").val();
    id_ciudad = $("#agregar_ciudad").val();
    id_ecivil = $("#agregar_ecivil").val();
    id_genero = $("#agregar_genero").val();
    if (!validarCampos([
        {id: "#agregar_nombre", nombre: "Nombre"},
        {id: "#agregar_apellido", nombre: "Apellido"},
        {id: "#agregar_ruc", nombre: "RUC"},
        {id: "#agregar_ci", nombre: "CI"},
        {id: "#agregar_direccion", nombre: "Direccion"},
        {id: "#agregar_correo", nombre: "Correo"},
        {id: "#agregar_fenaci", nombre: "Fecha Nacimiento"},
        {id: "#agregar_telefono", nombre: "Telefono"},
        {id: "#agregar_ciudad", nombre: "Ciudad"},
        {id: "#agregar_ecivil", nombre: "Estado Civil"},
        {id: "#agregar_genero", nombre: "Genero"},
    ])) {
        return;
    }
  }
  if (operacion == '2') {   //ACTUALIZAR
    id_cliente = $("#id_cliente").val();
    per_nombre  = $("#editar_nombre").val();
    per_apellido = $("#editar_apellido").val();
    per_ruc = $("#editar_ruc").val();
    per_ci = $("#editar_ci").val();
    per_direccion = $("#editar_direccion").val();
    per_correo = $("#editar_correo").val();
    per_fenaci = $("#editar_fenaci").val();
    per_telefono = $("#editar_telefono").val();
    id_ciudad = $("#editar_ciudad").val();
    id_ecivil = $("#editar_ecivil").val();
    id_genero = $("#editar_genero").val();
    if (!validarCampos([
        {id: "#editar_nombre", nombre: "Nombre"},
        {id: "#editar_apellido", nombre: "Apellido"},
        {id: "#editar_ruc", nombre: "RUC"},
        {id: "#editar_ci", nombre: "CI"},
        {id: "#editar_direccion", nombre: "Direccion"},
        {id: "#editar_correo", nombre: "Correo"},
        {id: "#editar_fenaci", nombre: "Fecha Nacimiento"},
        {id: "#editar_telefono", nombre: "Telefono"},
        {id: "#editar_ciudad", nombre: "Ciudad"},
        {id: "#editar_ecivil", nombre: "Estado Civil"},
        {id: "#editar_genero", nombre: "Genero"},
    ])) {
        return;
    }
  }
  if (operacion == '3' || operacion == '4') {   //ACTIVA E INACTIVA PERSONA
    id_cliente = $("#id_cliente").val();
  }
  $.ajax({
    type: "POST",
    url: "grabar.php",
    data: {
      id_cliente: id_cliente,
      per_nombre: per_nombre,
      per_apellido: per_apellido,
      per_ruc:per_ruc,
      per_ci:per_ci,
      per_direccion:per_direccion,
      per_correo:per_correo,
      per_fenaci:per_fenaci,
      per_telefono:per_telefono,
      id_ciudad:id_ciudad,
      id_ecivil:id_ecivil,
      id_genero:id_genero,
      operacion: operacion
    }
  }).done(function (resultado) {
    let response = JSON.parse(resultado);
    verificar_mensaje(response);
    postgrabar();
  }).fail(function (a, b, c) {
    console.error("Error: ", a, b, c);
  });
}

function postgrabar() {
  var operacion = $("#operacion").val();
  datos();
  if (operacion == '1' || operacion == '2') {
    $("#btn-modal-agregar-cerrar").click();
  }
  if (operacion == '3') {
    $("#btn-modal-editar-cerrar").click();
  }

}

