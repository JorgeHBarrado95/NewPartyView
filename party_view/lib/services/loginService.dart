import "dart:convert";
import "dart:ffi";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:party_view/models/usuarioLogin.dart";
import "package:party_view/provider/personaProvider.dart";
import "package:party_view/widget/customSnackBar.dart";
import "package:provider/provider.dart";


/// Servicio que gestiona el registro y login de usuarios utilizando Firebase Authentication, enviando y recibiendo peticiones HTTP.
class Loginservice {
  // final PersonaProvider personaProvider;
  // final BuildContext context;
  // Loginservice(this.personaProvider,this.context);

  /// URL para registrar un nuevo usuario.
  final urlRegister = Uri.parse(
    "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCR6r9ZgSdyXUYWmQOzATl2MQYW8EASsoE",
  );

  /// URL para iniciar sesión con un usuario existente.
  final urlLogin = Uri.parse(
    "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCR6r9ZgSdyXUYWmQOzATl2MQYW8EASsoE",
  );

  /// URL para actualizar información del usuario, como el nombre de usuario.
  final urlUpdate = Uri.parse(
    "https://identitytoolkit.googleapis.com/v1/accounts:update?key=AIzaSyCR6r9ZgSdyXUYWmQOzATl2MQYW8EASsoE",
  );

  /// URL para obtener información del usuario, como el nombre de usuario.
  final urlNombre = Uri.parse(
    "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=AIzaSyCR6r9ZgSdyXUYWmQOzATl2MQYW8EASsoE",
  );

  final urlVerificacion = Uri.parse(
    "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=AIzaSyCR6r9ZgSdyXUYWmQOzATl2MQYW8EASsoE",
  );

  /// Registra un nuevo usuario en Firebase Authentication.
  ///
  /// El objeto [_usuarioLogin]  que contiene el email, contraseña y nombre de usuario.
  /// Retorna:
  /// - `0` si el registro fue exitoso.
  /// - `2` si ocurrió un error desconocido.
  /// - `3` si el correo electrónico ya está en uso.
  
  late final String _token;
  Future<int> registro(UsuarioLogin _usuarioLogin, BuildContext context, PersonaProvider personaProvider) async {
    //print(_usuarioLogin.toString());
    final _respuesta = await http.post(
      urlRegister,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": _usuarioLogin.correo,
        "password": _usuarioLogin.contrasena,
        "returnSecureToken": true,
      }),
    );

    //Registro correcto
    if (_respuesta.statusCode == 200) {
      // Obtenermos el uid y el token
      final responseData = jsonDecode(_respuesta.body);
      String _uid = responseData["localId"];
      _token = responseData["idToken"];


      final personaProvider = Provider.of<PersonaProvider>(
      context,
      listen: true,
      );
      //personaProvider.getPersona!.token=_token;
      personaProvider.setToken=_token;

      //Mandamos el correo de verificación
      mandarCorreo();

      Navigator.pushNamed(
        context,
        "/verificarCorreo",
      );

      bool _verificado=false;
      while(_verificado==false){
        _verificado=await comprobarVerificacion();
        await Future.delayed(Duration(seconds: 2));
      }

      // //Actualiza el displayName
      // final _respuesta2 = await http.post(
      //   urlUpdate,
      //   headers: {"Content-Type": "application/json"},
      //   body: jsonEncode({
      //     "idToken": _token,
      //     "displayName": _usuarioLogin.nombre,
      //     "returnSecureToken": true,
      //   }),
      // );

      //Actualiza el displayName
      cambiarNombre(_usuarioLogin.nombre!, _token, false);
      
      if (_respuesta.statusCode == 200) {
        await personaProvider.crearPersona(_usuarioLogin.nombre ?? "usuario",_uid, _token); ///Se crea la persona y se almacena de manera local
        _usuarioLogin.borrarDatos(); // Borra los datos del usuario

        return 0; // Registro exitoso.
      } else {
        return 2; // Error desconocido.
      }
    } else if (_respuesta.statusCode == 400) {
      return 3; // El correo electrónico ya está en uso.
    } else {
      print("error desconocido en el registro");
      return 2; // Error desconocido.
    }
  }

  void mandarCorreo() async {
    final _response = await http.post(
      urlVerificacion,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "requestType": "VERIFY_EMAIL",
        "idToken": _token,
      }),
    );
  }

  Future <bool> comprobarVerificacion() async {
    final _response = await http.post(
      urlNombre,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "idToken": _token,
      }),
    );
    final _respuestaData = jsonDecode(_response.body);

    if (_respuestaData["users"][0]["emailVerified"] == true) {
      print("El correo ha sido verificado");
      return true;
    } else {
      print("El correo no ha sido verificado");
      return false;
    }
  }

  /// Inicia sesión con un usuario existente en Firebase Authentication.
  ///
  /// [_usuarioLogin] El objeto [Usuario] que contiene el email y contraseña.
  /// Retorna:
  /// - `0` si el inicio de sesión fue exitoso.
  /// - `1` si hay un error en la contraseña o correo electrónico.
  /// - `2` si ocurrió un error desconocido.
  Future<int> login(UsuarioLogin _usuarioLogin, PersonaProvider personaProvider) async {
    final _respuesta = await http.post(
      urlLogin,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": _usuarioLogin.correo,
        "password": _usuarioLogin.contrasena,
        "returnSecureToken": true,
      }),
    );

    //print("Response status: ${response.statusCode}");
    //print("Response body: ${response.body}");

    if (_respuesta.statusCode == 400) {
      print("Error: Contraseña o correo incorrecto");
      return 1; // Error en la contraseña o correo electrónico.
    } else if (_respuesta.statusCode == 200) {
      print("Inicio de sesión exitoso");

      // Actualiza el displayName del usuario con el valor recibido del servidor.
      final responseData = jsonDecode(_respuesta.body);
      String _uid = responseData["localId"];
      String _token = responseData["idToken"];
      String _nombre = responseData["displayName"];

      // Usa el provider inyectado.
      await personaProvider.crearPersona(_nombre, _uid, _token); ///Se crea la persona y se almacena de manera local
      _usuarioLogin.borrarDatos(); // Borra los datos del usuario
      return 0; // Inicio de sesión exitoso.
    } else {
      print("Error desconocido");
      return 2; // Error desconocido.
    }
  }
  
  //Actualiza el displayName
  ///[automatico] Si es true, es q el metodo se esta usando al hacer el register, 
  ///pero si es false, es q se esta usando al cambiar el nombre de usuario
  Future <void> cambiarNombre(String nombre, String token, bool automatico, [BuildContext? context]) async {
    final _respuesta = await http.post(
      urlUpdate,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "idToken": token,
        "displayName": nombre,
        "returnSecureToken": true,
      }),
    );

    if (!automatico){
      if(_respuesta.statusCode==200){
        print("Nombre cambiado");
        ScaffoldMessenger.of(context!)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            CustomSnackbar.aprobacion(
              "Nombre actualizado",
              "",
            ),
          );
      }else{
        print("Error al cambiar el nombre");
        ScaffoldMessenger.of(context!)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            CustomSnackbar.error(
              "¡Error al cambiar de nombre!",
              "Reinicia la app o vuelve a intentarlo mas tarde",
            ),
          );
      }
    }
  }
}
