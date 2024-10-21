
$(function() {
  datos();
  $('body').on("keydown", function (e) {
    if (e.ctrlKey && e.which === 81) {
      agregar();
    }
    // $("#tecla_presionada").val(e.keyCode);
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
      url:"agregar.php"
  // ejecuta el llamado
  }).done(function(resultado){
      $("#modal-agregar").html(resultado);
      $("#btn-modal-agregar").click();
  });
}

function agregar_grabar() {
  $("#operacion").val(1);
  grabar();
}

function editar(id_ciudad) {
  $.ajax({
    type: "POST",
    url: "editar.php",
    data:{
      id_ciudad: id_ciudad
    }
  }).done(function(resultado){
    $("#modal-editar").html(resultado);
    $("#btn-modal-editar").click();
  });
}

function editar_grabar() {
  $("#operacion").val(2);
  grabar();
}

function activar(id_ciudad) {
  $("#id_ciudad").val(id_ciudad);
  $("#operacion").val(3);
  grabar();
}

function inactivar(id_ciudad) {
  $("#id_ciudad").val(id_ciudad);
  $("#operacion").val(4);
  grabar();
}

function grabar() {
  var id_ciudad = '0';
  var ciu_descrip = '';
  var id_pais = '0';
  var operacion = $("#operacion").val();
  if (operacion == '1') {
     id_ciudad = 0;
     ciu_descrip  = $("#agregar_descri").val();
     id_pais  = $("#agregar_pais").val();
  }
  if (operacion == '2') {
     id_ciudad = $("#editar_cod_ciudad").val();
     ciu_descrip  = $("#editar_descri").val();
     id_pais  = $("#editar_pais").val();
  }
  if (operacion == '3' || operacion == '4') {
     id_ciudad = $("#id_ciudad").val();
  }
  $.ajax({
    type: "POST",
    url: "grabar.php",
    data: {
      id_ciudad: id_ciudad,
      ciu_descrip: ciu_descrip,
      id_pais: id_pais,
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
  if (operacion == '1') {
     $("#btn-modal-agregar-cerrar").click();
  }
  if (operacion == '2') {
    $("#btn-modal-editar-cerrar").click();
 }
 
}

