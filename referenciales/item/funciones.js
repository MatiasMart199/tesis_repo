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
    type: "POST",
    url: "./datos.php"
  }).done(function (resultado) {
    $("#panel_datos").html(resultado);
    formato_tabla("#tabla_datos", 5);
  })
}

function formato_tabla(tabla, cantidad) {
  $(tabla).DataTable({
    "lengthChange": false,
    responsive: "true",
    "iDisplayLength": cantidad,
    language: {
      "sSearch": "Buscar: ",
      "sInfo": "Mostrando resultados del _START_ al _END_ de un total de _TOTAL_ registros",
      "sInfoFiltered": "(filtrado de entre _MAX_ registros)",
      "sZeroRecords": "No hay resultados",
      "sInfoEmpty": "No hay resultados",
      "oPaginate": {
        "sNext": "Siguiente",
        "sPrevious": "Anterior"
      }
    }
  });
}

function agregar() {
  // hace el llamado
  $.ajax({
    type: "POST",
    url: "./agregar.php"
    // ejecuta el llamado
  }).done(function (resultado) {
    $("#modal-agregar").html(resultado);
    $("#btn-modal-agregar").click();
  });
}

function agregar_grabar() {
  $("#operacion").val(1);
  grabar();
}

function editar(id_item) {
  $.ajax({
    type: "POST",
    url: "./editar.php",
    data: {
      id_item: id_item
    }
  }).done(function (resultado) {
    $("#modal-editar").html(resultado);
    $("#btn-modal-editar").click();
  });
}

function editar_grabar() {
  $("#operacion").val(2);
  grabar();
}

function activar(id_item) {
  $("#id_item").val(id_item);
  $("#operacion").val(3);
  grabar();
}

function inactivar(id_item) {
  $("#id_item").val(id_item);
  $("#operacion").val(4);
  grabar();
}

function grabar() {
  let operacion = $("#operacion").val();
  let id_item = "0";
  let item_descrip = "0";
  let precio_compra = "0";
  let precio_venta = "0";
  let id_mar = "0";
  let id_tip_item = "0";
  let id_tip_impuesto = "0";
  let item_concepto = "0";
  if (operacion == '1') {
    id_item = $("#id_item").val();
    item_descrip = $("#add_item_descrip").val();
    precio_compra = $("#add_precio_compra").val();
    precio_venta = $("#add_precio_venta").val();
    id_mar = $("#add_id_mar").val();
    id_tip_item = $("#add_id_tip_item").val();
    id_tip_impuesto = $("#add_id_tip_impuesto").val();
    item_concepto = $("#add_item_concepto").val();
  }
  if (operacion == '2') {
    id_item = $("#edit_id_item").val();
    item_descrip = $("#edit_item_descrip").val();
    precio_compra = $("#edit_precio_compra").val();
    precio_venta = $("#edit_precio_venta").val();
    id_mar = $("#edit_id_mar").val();
    id_tip_item = $("#edit_id_tip_item").val();
    id_tip_impuesto = $("#edit_id_tip_impuesto").val();
    item_concepto = $("#edit_item_concepto").val();
    console.log("Item "+item_concepto," id "+id_item," descrip "+item_descrip," compra "+precio_compra," venta "+precio_venta," marca "+id_mar," categoria "+id_tip_item," impuesto "+id_tip_impuesto);
  }
  if (operacion == '3' || operacion == '4') {
    id_item = $("#id_item").val();

  }
  $.ajax({
    type: "POST",
    url: "grabar.php",
    data: {
      operacion: operacion,
      id_item: id_item,
      item_descrip: item_descrip,
      precio_compra: precio_compra,
      precio_venta: precio_venta,
      id_mar: id_mar,
      id_tip_item: id_tip_item,
      id_tip_impuesto: id_tip_impuesto,
      item_concepto: item_concepto
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
