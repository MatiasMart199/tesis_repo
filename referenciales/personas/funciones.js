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
  });
}

function agregarJuridica() {
  // hace el llamado
  $.ajax({
    type:"POST",
    url:"./agregar_juridica.php"
 // ejecuta el llamado
}).done(function(resultado){
  $("#modal-agregar-juridica").html(resultado);
  $("#btn-modal-agregar-juridica").click();
});
}

function agregar_grabarFisica() {
  $("#operacion").val(1);
  grabar();
}

function agregar_grabarJuridica() {
  $("#operacion").val(2);
  grabar();
}

function editar(id_persona) {
  $.ajax({
    type: "POST",
    url: "./editar.php",
    data:{
      id_persona: id_persona
    }
  }).done(function(resultado){
    $("#modal-editar-fisica").html(resultado);
    $("#btn-modal-editar-fisica").click();
  });
}

function editar_grabar() {
  $("#operacion").val(3);
  grabar();
}

function activar(id_persona) {
  $("#id_persona").val(id_persona);
  $("#operacion").val(4);
  grabar();
}

function inactivar(id_persona) {
  $("#id_persona").val(id_persona);
  $("#operacion").val(5);
  grabar();
}



function grabar() {
  var id_persona = '0';
  var per_nombre = 'N/A';
  var per_apellido = 'N/A';
  var per_ruc = '0';
  var per_ci = 'N/A';
  var per_direccion = '0';
  var per_correo = '0';
  var per_fenaci = '2003-03-03';
  var per_telefono = '0';
  var persona_fisica = '0';
  var id_ciudad = '0';
  var id_ecivil = '1';
  var id_genero = '3';
  var operacion = $("#operacion").val();
  if (operacion == '1') {                   //INSERTA PERSONA FISICA
    id_persona = $("#id_persona").val();
    per_nombre  = $("#agregar_nombre").val();
    per_apellido = $("#agregar_apellido").val();
    per_ruc = $("#agregar_ruc").val();
    per_ci = $("#agregar_ci").val();
    per_direccion = $("#agregar_direccion").val();
    per_correo = $("#agregar_correo").val();
    per_fenaci = $("#agregar_fenaci").val();
    per_telefono = $("#agregar_telefono").val();
    persona_fisica = $("#persona_fisica").val();
    id_ciudad = $("#agregar_ciudad").val();
    id_ecivil = $("#agregar_ecivil").val();
    id_genero = $("#agregar_genero").val();
  }
  if (operacion == '3') {   //ACTUALIZAR
    id_persona = $("#id_persona").val();
    per_nombre  = $("#editar_nombre").val();
    per_apellido = $("#editar_apellido").val();
    per_ruc = $("#editar_ruc").val();
    per_ci = $("#editar_ci").val();
    per_direccion = $("#editar_direccion").val();
    per_correo = $("#editar_correo").val();
    per_fenaci = $("#editar_fenaci").val();
    per_telefono = $("#editar_telefono").val();
    persona_fisica = $("#editar_persona_fisica").val();
    id_ciudad = $("#editar_ciudad").val();
    id_ecivil = $("#editar_ecivil").val();
    id_genero = $("#editar_genero").val();
    console.log(id_persona);
    console.log(per_nombre);
    console.log(per_apellido);
    console.log(per_ruc);
    console.log(per_ci);
    console.log(per_direccion);
    console.log(per_correo);
    console.log(per_fenaci);
    console.log(per_telefono);
    console.log(persona_fisica);
    console.log(id_ciudad);
    console.log(id_ecivil);
    console.log(id_genero);
  }
  if (operacion == '4' || operacion == '5') {   //ACTIVA E INACTIVA PERSONA
    id_persona = $("#id_persona").val();
  }
  $.ajax({
    type: "POST",
    url: "grabar.php",
    data: {
      id_persona: id_persona,
      per_nombre: per_nombre,
      per_apellido: per_apellido,
      per_ruc:per_ruc,
      per_ci:per_ci,
      per_direccion:per_direccion,
      per_correo:per_correo,
      per_fenaci:per_fenaci,
      per_telefono:per_telefono,
      persona_fisica:persona_fisica,
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


$(document).ready(function () {
  $(document).on('change', '#persona_fisica', function() {
    if ($("#persona_fisica").val() === "false") {
      // Oculta los grupos completos
      $("#agregar_apellido").closest('.form-group').attr("hidden", true);
      $("#agregar_ci").closest('.form-group').attr("hidden", true);
      $("#agregar_fenaci").closest('.form-group').attr("hidden", true);
      $("#agregar_ecivil").closest('.form-group').attr("hidden", true);
      $("#agregar_genero").closest('.form-group').attr("hidden", true);
    } else {
      // Muestra los grupos completos
      $("#agregar_apellido").closest('.form-group').removeAttr("hidden");
      $("#agregar_ci").closest('.form-group').removeAttr("hidden");
      $("#agregar_fenaci").closest('.form-group').removeAttr("hidden");
      $("#agregar_ecivil").closest('.form-group').removeAttr("hidden");
      $("#agregar_genero").closest('.form-group').removeAttr("hidden");
    }
  });
});

