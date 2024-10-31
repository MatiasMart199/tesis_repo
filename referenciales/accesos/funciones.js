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

  function editar(id_acceso) {
    $.ajax({
      type: "POST",
      url: "./editar.php",
      data:{
        id_acceso: id_acceso
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
    $("#id_acceso").val(id_pais);
    $("#operacion").val(3);
    grabar();
  }

  function inactivar(id_pais) {
    $("#id_acceso").val(id_pais);
    $("#operacion").val(4);
    grabar();
  }

  function grabar() {
    var operacion = $("#operacion").val();
    if (operacion == '1') {
      var id_acceso = 0;
      var id_usuario  = 0;
    }

    if (operacion == '2') {
      var id_acceso = $("#editar_id_acceso").val();
      var id_usuario  = $("#editar_id_usuario").val();
    }

    if (operacion == '3' || operacion == '4') {
      var id_acceso = $("#id_acceso").val();
      var id_usuario  = 0;
    }

   
    $.ajax({
      type: "POST",
      url: "grabar.php",
      data: {
          id_acceso: id_acceso,
          id_usuario: id_usuario,
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
