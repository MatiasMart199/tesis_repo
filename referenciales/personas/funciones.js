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

function agregarFisica() {
   // hace el llamado
    $.ajax({
      type:"POST",
      url:"./agregar_fisica.php"
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
  var per_nombre = 'JURIDICA';
  var per_apellido = '---';
  var per_ruc = '0';
  var per_ci = 'JURIDICA';
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
    persona_fisica = $("#tipo_persona_fisica").val();
    id_ciudad = $("#agregar_ciudad").val();
    id_ecivil = $("#agregar_ecivil").val();
    id_genero = $("#agregar_genero").val();
  }
  if (operacion == '2') {                 //INSERTA PERSONA JURIDICA
    id_persona = $("#id_persona").val();
    per_nombre  = $("#agregar_nombre").val();
    per_apellido = $("#agregar_apellido").val();
    per_ruc = $("#agregar_ruc").val();
    per_ci = $("#agregar_ci").val();
    per_direccion = $("#agregar_direccion").val();
    per_correo = $("#agregar_correof").val();
    per_fenaci = $("#agregar_fenaci").val();
    per_telefono = $("#agregar_telefono").val();
    persona_fisica = $("#tipo_persona_jurid").val();
    id_ciudad = $("#agregar_ciudad").val();
    id_ecivil = $("#agregar_ecivil").val();
    id_genero = $("#agregar_genero").val();
  }
  if (operacion == '3') {   //ACTUALIZAR
    id_persona = $("#id_persona").val();
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
  }).done(function(resultado) {
    verificar_mensaje(resultado);
    postgrabar();
})
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

