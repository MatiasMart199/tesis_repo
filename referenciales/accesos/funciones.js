// $(function () {
//     datos();
//     $('body').on("keydown", function (e) {
//         if (e.ctrlKey && e.which === 81) {
//             agregar();
//         }
//     })
// })

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



function agregar_grabar() {
    grabar();
  }


  function grabar() {
    let acc_login = $("input[name=usuario]").val();
    let acc_contrasena = $("input[name=contrasena]").val();
    console.log(acc_login);
    console.log(acc_contrasena);
   
    $.ajax({
      type: "POST",
      url: "grabar.php",
      data: {
        acc_login: acc_login,
        acc_contrasena: acc_contrasena
      }
  }).done(function(resultado) {
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

