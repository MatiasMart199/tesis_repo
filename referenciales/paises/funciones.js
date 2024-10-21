$(function () {
    datos();
    $('body').on("keydown", function (e) {
        if (e.ctrlKey && e.which === 81) {
            agregar();
        }
    })
})

function datos() {
    $.ajax({
        type:"POST",
        url:"./datos.php"
    }).done(function (resultado) {
        $("#panel_datos").html(resultado);
        formato_tabla("#tabla_datos",5);
    })
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
      $("#modal-agregar").html(resultado);
      $("#btn-modal-agregar").click();
  });
} 

function agregar_grabar() {
    $("#operacion").val(1);
    grabar();
  }

  function editar(id_pais) {
    $.ajax({
      type: "POST",
      url: "./editar.php",
      data:{
        id_pais: id_pais
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

  function activar(id_pais) {
    $("#id_pais").val(id_pais);
    $("#operacion").val(3);
    grabar();
  }

  function inactivar(id_pais) {
    $("#id_pais").val(id_pais);
    $("#operacion").val(4);
    grabar();
  }

  function grabar() {
    var operacion = $("#operacion").val();
    if (operacion == '1') {
      var id_pais = 0;
      var pais_descrip  = $("#agregar_pais_descrip").val();
      var pais_gentilicio  = $("#agregar_pais_gentilicio").val();
      var pais_codigo  = $("#agregar_pais_codigo").val();
    }

    if (operacion == '2') {
      var id_pais = $("#editar_id_pais").val();
      var pais_descrip  = $("#editar_pais_descrip").val();
      var pais_gentilicio  = $("#editar_pais_gentilicio").val();
      var pais_codigo  = $("#editar_pais_codigo").val();
    }

    if (operacion == '3' || operacion == '4') {
      var id_pais = $("#id_pais").val();
      var pais_descrip = '';
      var pais_gentilicio  = '';
      var pais_codigo  = '';
    }

   
    $.ajax({
      type: "POST",
      url: "grabar.php",
      data: {
          id_pais: id_pais,
          pais_descrip: pais_descrip,
          pais_gentilicio: pais_gentilicio,
          pais_codigo: pais_codigo,
          operacion: operacion
      }
  }).done(function(resultado) {
    if(verificar_mensaje(resultado)){
      //postgrabar(operacion);
  }
      postgrabar();
  }).fail(function(a,b,c){
    console.log('Error:', c);
});
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
