<script>

    // function verificar_mensaje(resultado) {
    //     const Toast = Swal.mixin({
    //         toast: true,
    //         position: 'top-end',
    //         showConfirmButton: false,
    //         timer: 3000
    //     });

    //     //var response = JSON.parse(resultado);

    //     Toast.fire({
    //         type: resultado.success ? 'success' : 'error',
    //         title: resultado.message.replace(/_\/_/g, ' ')
    //     });
    // }


    // function verificar_mensaje_prueba(resultado) {
    //     const Toast = Swal.mixin({
    //         toast: true,
    //         position: 'top-end',
    //         showConfirmButton: false,
    //         timer: 3000
    //     });

    //     //var response = JSON.parse(resultado);

    //     Toast.fire({
    //         type: resultado.success ? 'success' : 'error',
    //         title: resultado.message.replace(/_\/_/g, ' ')
    //     });
    // }


/**************************************EL MENSAJE A PRODUCCION******************/ 

    function verificar_mensaje(resultado) {
    var operacion = $("#operacion").val();
    var response = JSON.parse(resultado);
    var mensajeSinContexto = response.message.replace(/CONTEXT:.*$/g, "");

    swal.fire({
        title: response.success ? mensajeSinContexto.replace("NOTICE: ", "") : mensajeSinContexto.replace("ERROR: ", ""),
        type: response.success ? 'success' : 'error',
        
    }, function (isConfirm) {
        if (isConfirm) {
            // Puedes hacer algo aquí si el usuario hace clic en "Sí"
            // Por ejemplo, redirigir a otra página o realizar alguna acción adicional.
            // resultado contiene la información que podrías necesitar.
            console.log("Usuario hizo clic en Sí");
        } else {
            // Puedes hacer algo aquí si el usuario hace clic en "No"
            console.log("Usuario hizo clic en No");
        }
    });
}

function verificar_mensajeSinJson(resultado) {
    var operacion = $("#operacion").val();
    var mensajeSinContexto = resultado.message.replace(/CONTEXT:.*$/g, "");

    swal.fire({
        title: resultado.success ? mensajeSinContexto.replace("NOTICE: ", "") : mensajeSinContexto.replace("ERROR: ", ""),
        type: resultado.success ? 'success' : 'error',
        
    }, function (isConfirm) {
        if (isConfirm) {
            // Puedes hacer algo aquí si el usuario hace clic en "Sí"
            // Por ejemplo, redirigir a otra página o realizar alguna acción adicional.
            // resultado contiene la información que podrías necesitar.
            console.log("Usuario hizo clic en Sí");
        } else {
            // Puedes hacer algo aquí si el usuario hace clic en "No"
            console.log("Usuario hizo clic en No");
        }
    });
}




//     function verificar_mensaje(resultado) {
//     var operacion = $("#operacion").val();
//     var response = JSON.parse(resultado);


//     swal.fire({
//         text: response.success ? response.message.replace("NOTICE: ", "") : response.message.replace("ERROR: ", ""),
//         type: response.success ? 'success' : 'error',
//         //timer: 5000
//     });
// }


/*********************************************************************************************************/ 

    // function verificar_mensaje(resultado) {
    //     const Toast = Swal.mixin({
    //         toast: true,
    //         position: 'top-end',
    //         showConfirmButton: false,
    //         timer: 3000
    //     });

    //     let response;
    //     try {
    //         response = JSON.parse(resultado);
    //     } catch (e) {
    //         console.error("Error al parsear JSON: ", e);
    //         console.error("Respuesta del servidor: ", resultado);

    //         Toast.fire({
    //             icon: 'error',  // Cambiado 'type' por 'icon'
    //             title: 'Respuesta inválida del servidor'
    //         });
    //         return;
    //     }

    //     Toast.fire({
    //         icon: response.success ? 'success' : 'error',  // Cambiado 'type' por 'icon'
    //         title: response.message.replace(/_\/_/g, ' ')
    //     });
    // }


/*********************************************************************************************************/

//     function verificar_mensaje(resultado) {
//   const Toast = Swal.mixin({
//     toast: true,
//     position: 'top-end',
//     showConfirmButton: false,
//     timer: 3000
//   });

//   try {
//     // Attempt to parse JSON, handling potential errors
//     var response = JSON.parse(resultado);
//     Toast.fire({
//       type: response.success ? 'success' : 'error',
//       title: response.message.replace(/_\/_/g, ' ')
//     });
//   } catch (error) {
//     console.error("Error parsing JSON:", error);
//     // Handle parsing error gracefully (e.g., display a generic error message)
//   }
// }

</script>
