
$(function(){
    panel_presupuestos();
    panel_datos(-1);
});

function refrescar_select(){
    $(".select2").select2();
    $(".select2").attr("style", "width: 100%;");
}

function formato_tabla(tabla, item_cantidad){
    $(tabla).DataTable({
        "lengthChange": false,
        responsive: "true",
        "iDisplayLength": item_cantidad,
        language: {
            "sSearch":"Buscar: ",
            "sInfo":"Mostrando resultados del _START_ al _END_ de un total de _TOTAL_ registros",
            "sInfoFiltered":"(filtrado de entre _MAX_ registros)",
            "sInfoEmpty":"No hay resultados",
            "oPaginate":{
                "sNext":"Siguiente",
                "sPrevious":"Anterior"
            }
        }
    });
}

function panel_presupuestos(){
    $.ajax({
        url:"panel_presupuestos.php"
    }).done(function(resultado){
        $("#panel-presupuestos").html(resultado);
        formato_tabla("#tabla_panel_presupuestos", 5);
    });
}

function panel_datos(id_cpre){
    $.ajax({
        url:"panel_datos.php",
        type:"POST",
        data:{
            id_cpre: id_cpre
        }
    }).done(function(resultado){
        $("#panel-datos").html(resultado);
        panel_pedidos();
        refrescar_select();
    });
}

function panel_pedidos(){
    $.ajax({
        url:"panel_presupuestos.php"
    }).done(function(resultado){
        $("#panel-presupuestos").html(resultado);
        formato_tabla("#tabla_panel_presupuestos", 5);
    });
}

function datos(id_cpre){
    panel_datos(id_cpre);
    $("#btn-panel-datos").click();
}

function agregar(){
    panel_datos(0);
    $("#btn-panel-datos").click();
}

function modificar_detalle(id_item){
    var id_cpre = $("#id_cpre").val();
    $.ajax({
        url:"panel_modificar.php",
        type:"POST",
        data:{
            id_cpre: id_cpre,
            id_item: id_item
        }
    }).done(function(resultado){
        $("#panel-modificar").html(resultado);
        $("#btn-panel-modificar").click();
    });
}

function modificar_detalle_ped(id_cpre, id_item){
    var id_cpre = $("#id_cpre").val();
    $.ajax({
        url:"panel_modificar_ped.php",
        type:"POST",
        data:{
            id_cpre: id_cpre,
            id_item: id_item
        }
    }).done(function(resultado){
        $("#panel-modificar").html(resultado);
        $("#btn-panel-modificar").click();
    });
}

function modalSecund(){
    $.ajax({
        type:"POST",
        url:"./panel_secundario.php"
     // ejecuta el llamado
    }).done(function(resultado){
        $("#panel-secund").html(resultado);
        $("#btn-panel-secund").click();
    }).fail(function(a,b,c){
        console.log(c);
    });
}

function modalConsolidacion(id_cpre){
    $.ajax({
        type:"POST",
        url:"./panel_consolidacion.php",
        data:{
            id_cpre: id_cpre
        }
     // ejecuta el llamado
    }).done(function(resultado){
        $("#panel-consolidacion").html(resultado);
        $("#btn-panel-consolidacion").click();
    });
}

function generarInforme(id_cpre) {
    window.open('documento.php?id_cpre=' + id_cpre, '_blank');
}

function agregar_presupuesto_pedido(id_cp){
    $("#id_cp").val(id_cp);
    $("#operacion").val(8);
    grabar();
    $("html, body").animate({ scrollTop: 0}, "slow");
}

function agregar_grabar(){
    $("#operacion").val(1);
    grabar();
}

function modificar(){
    $("#operacion").val(2);
    grabar();
}

function confirmar(){
    $("#operacion").val(3);
    grabar();
}

function anular(){
    $("#operacion").val(4);
    grabar();
}

function agregar_detalles(){
    $("#operacion").val(5);
    grabar();
}

function modificar_detalle_grabar(){
    $("#operacion").val(6);
    grabar();
}

function modificar_detalle_ped_grabar(){
    $("#operacion").val(9);
    grabar();
}

function eliminar_detalle(id_item){
    $("#eliminar_id_item").val(id_item);
    $("#operacion").val(7);
    grabar();
}

function eliminar_presupuesto_pedido(id_item){
    $("#eliminar_id_item").val(id_item);
    $("#operacion").val(11);
    grabar();
}

function cancelar(){
    panel_datos(-1);
    $("#btn-panel-presupuestos").click();
    mensaje("CANCELADO","error");
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

function grabar(){
    let operacion = $("#operacion").val();
    let id_cpre = '0';
    let cpre_fecha = '2023-03-03';
    let cpre_validez = '2023-03-03';
    let cpre_numero = '0';
    let cpre_observacion = '0';
    let id_proveedor = '0';
    let id_item = '0';
    let cantidad = '0';
    let precio = '0';
    let id_cp = '0';
    if(operacion == '1' || operacion == '2' || operacion == '3' || operacion == '4'){
        id_cpre = $("#id_cpre").val();
        cpre_fecha = $("#cpre_fecha").val();
        cpre_validez = $("#cpre_validez").val();
        cpre_numero = $("#cpre_numero").val();
        cpre_observacion = $("#cpre_observacion").val();
        id_proveedor = $("#id_proveedor").val();
         // Solo asignamos id_cp si el input tiene un valor válido y operacion == 3
         if (operacion == '3' && $("#id_cp").val().trim() !== '') {
            id_cp = $("#id_cp").val();
        }
        
        if(!validarCampos([
            {id: "#cpre_fecha", nombre: "Fecha"},
            {id: "#cpre_validez", nombre: "fecha de Validez"},
            {id: "#cpre_numero", nombre: "Número de proveedor"},
            {id: "#id_proveedor", nombre: "Proveedor"}
        ])){
            return; // Salimos de la función si la validación falla
        }
        // console.log("id_cp "+id_cp);
    }
    if(operacion == '5'){
        id_cpre = $("#id_cpre").val();
        id_item = $("#agregar_id_item").val();
        cantidad = $("#agregar_cantidad").val();
        precio = $("#agregar_precio").val();
        
        if (!validarCampos([
            {id: "#agregar_id_item", nombre: "Item"},
            {id: "#agregar_cantidad", nombre: "Cantidad"},
            {id: "#agregar_precio", nombre: "Precio"}
        ]))
        {
            return; // ❌ corta si falta un campo
        }
    }
    if(operacion == '6'){
        id_cpre = $("#id_cpre").val();
        id_item = $("#modificar_id_item").val();
        cantidad = $("#modificar_cantidad").val();
        precio = $("#modificar_precio").val();
        if(!validarCampos([
            {id: "#modificar_id_item", nombre: "Item"},
            {id: "#modificar_cantidad", nombre: "Cantidad"},
            {id: "#modificar_precio", nombre: "Precio"}
        ]))
        {
            return; // ❌ corta si falta un campo
        }
    }
    if(operacion == '7'){
        id_cpre = $("#id_cpre").val();
        id_item = $("#eliminar_id_item").val();
    }
    if(operacion == '8'){
        id_cpre = $("#id_cpre").val();
        id_cp = $("#id_cp").val();
    }
    if(operacion == '9'){
        id_cpre = $("#id_cpre").val();
        //id_cp = $("#id_cp").val();
        id_item = $("#modificar_id_item").val();
        cantidad = $("#modificar_cantidad").val();
        precio = $("#modificar_precio").val();
        if(!validarCampos([
            {id: "#modificar_id_item", nombre: "Item"},
            {id: "#modificar_cantidad", nombre: "Cantidad"},
            {id: "#modificar_precio", nombre: "Precio"}
        ]))
        {
            return; // ❌ corta si falta un campo
        }
        
    }
    if(operacion == '10'){
        id_cp = $("#id_cp").val();
        id_item = $("#eliminar_id_item").val();
    }
    if(operacion == '11'){
        id_cpre = $("#id_cpre").val();
        id_cp = $("#id_cp").val();
        id_item = $("#eliminar_id_item").val();
    }
    $.ajax({
        url: "grabar.php",
        type: "POST",
        data:{
            id_cpre: id_cpre,
            cpre_fecha: cpre_fecha,
            cpre_validez: cpre_validez,
            cpre_numero: cpre_numero,
            cpre_observacion: cpre_observacion,
            id_proveedor: id_proveedor,
            id_item: id_item,
            cantidad: cantidad,
            precio: precio,
            id_cp: id_cp,
            operacion: operacion
        }
    }).done(function(resultado){
        if(verificar_mensaje(resultado)){
            //postgrabar(operacion);
        }
        postgrabar(operacion);
    }).fail(function(a,b,c){
        console.error('Error:',a,b,c);
    });
}

function postgrabar(operacion){
    panel_presupuestos();
    if(operacion == '1'){
        panel_datos(-2);
        //$('#btn-panel-pedidos').click ();
    }
    if(operacion == '2'|| operacion == '5' || operacion == '6' || operacion == '7' || operacion == '8'|| operacion == '9'|| operacion == '10'|| operacion == '11'){
        panel_datos($("#id_cpre").val());
        if(operacion == '6' || operacion == '9'){
            $("#btn-panel-modificar-cerrar").click();
        }
    }
    if (operacion == '8') {
        $("#btn-modal-secund-cerrar").click();
    }
    if(operacion == '3' || operacion == '4'){
        panel_datos(-1);
    
    }
}

function llenarPrecio() { 
    // Obtener el ID del producto seleccionado
    const articuloId = document.getElementById('agregar_id_item').value;
    const precio = document.getElementById('agregar_precio');
    // Buscar el producto correspondiente en el objeto datoStock
    const itemSeleccionado = artuculos.find(d => d.id_item == articuloId);

    if (itemSeleccionado) {
        precio.value = itemSeleccionado.precio_compra; // Asignar el valor del stock
    } else {
        precio.value = ''; // Limpiar el campo si no se encuentra
    }
}

$(document).ready(function() {
    $(document).on('change', '#agregar_id_item', function() {
        llenarPrecio();
        stock_actual();
    });
});

function stock_actual(){
    const item = document.getElementById('agregar_id_item');
    const stockInput = document.getElementById('stock_actual');
    const selectedItemId = parseInt(item.value);
    const itemStock = stock.find(s => parseInt(s.id_item) === selectedItemId);
    if (itemStock) {
        stockInput.value = itemStock.stock_cantidad;
    } else {
        stockInput.value = '0';
    }
 }
 