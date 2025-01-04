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

  function editar(id_tip_impuesto) {
    $.ajax({
      type: "POST",
      url: "./editar.php",
      data:{
        id_tip_impuesto: id_tip_impuesto
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

  function activar(id_tip_impuesto) {
    $("#id_tip_impuesto").val(id_tip_impuesto);
    $("#operacion").val(3);
    grabar();
  }

  function inactivar(id_tip_impuesto) {
    $("#id_tip_impuesto").val(id_tip_impuesto);
    $("#operacion").val(4);
    grabar();
  }

  function grabar() {
    var operacion = $("#operacion").val();
    if (operacion == '1') {
      var id_tip_impuesto = 0;
      var tip_imp_descrip  = $("#agregar_tip_imp_descrip").val();
      var tip_imp_tasa  = $("#agregar_tip_imp_tasa").val();
      var tip_imp_tasa2  = $("#agregar_tip_imp_tasa2").val();
    }

    if (operacion == '2') {
      var id_tip_impuesto = $("#editar_id_tip_impuesto").val();
      var tip_imp_descrip  = $("#editar_tip_imp_descrip").val();
      var tip_imp_tasa  = $("#editar_tip_imp_tasa").val();
      var tip_imp_tasa2  = $("#editar_tip_imp_tasa2").val();
    }

    if (operacion == '3' || operacion == '4') {
      var id_tip_impuesto = $("#id_tip_impuesto").val();
      var tip_imp_descrip = '';
      var tip_imp_tasa  = '';
      var tip_imp_tasa2  = '';
      console.log("ID: "+id_tip_impuesto ," OP: "+operacion);
    }
    $.ajax({
      type: "POST",
      url: "grabar.php",
      data: {
          id_tip_impuesto: id_tip_impuesto,
          tip_imp_descrip: tip_imp_descrip,
          tip_imp_tasa: tip_imp_tasa,
          tip_imp_tasa2: tip_imp_tasa2,
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
    if (operacion == '1') {
      $("#btn-modal-agregar-cerrar").click();
    }
    if (operacion == '2') {
      $("#btn-modal-editar-cerrar").click();
  }
  
  }
