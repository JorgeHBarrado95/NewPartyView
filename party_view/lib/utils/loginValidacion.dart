import 'package:flutter/material.dart';
import 'package:party_view/models/usuarioLogin.dart';
import 'package:party_view/provider/personaProvider.dart';
import 'package:party_view/services/loginService.dart';
import 'package:party_view/widget/customSnackBar.dart';
import 'package:provider/provider.dart';

class LoginValidacion {
  ///[iniciarSeseion] inicia el procedimiento para iniciar sesion
  Future<void> iniciarSeseion(BuildContext context, String correo, String contrasena) async {
    final RegExp _gmailValidacion = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );

    if (correo.isEmpty || contrasena.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          CustomSnackbar.error(
            "❗ ¡Faltan campos por rellenar!",
            "",
          ),
        );
      return;
    }

    if (!_gmailValidacion.hasMatch(correo)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          CustomSnackbar.error(
            "📧 ¡Pon un correo valido!",
            "",
          ),
        );
      return;
    }

    //Creo el objeto UsuarioLogin
    UsuarioLogin _usuarioLogin = UsuarioLogin(
      correo: correo,
      contrasena: contrasena,
    );
    
    //Creo el provider de Persona
    final personaProvider = Provider.of<PersonaProvider>(
    context,
    listen: false,
    );

   //Llamo al servicio de login, al cual le paso el objeto UsuarioLogin
    try {
      int estadoLogin = await Loginservice().login(_usuarioLogin,personaProvider);

      if (estadoLogin == 0) {
        print("iniciado sesion");
        Navigator.pushNamed(context, "/principal");
      } else if (estadoLogin == 1) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            CustomSnackbar.error(
              "🔑 ¡Error en la contraseña o gmail!",
              "",
            ),
          );
        print("Error en la contraseña o @");

        return;
      } else if(estadoLogin == 3) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            CustomSnackbar.error(
              "❗¡El correo no ha sido verificado!",
              "Por favor verifica tu correo",
            ),
          );
        print("El correo no ha sido verificado");
        return;
      } else if(estadoLogin == 4) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            CustomSnackbar.error(
              "❗¡El correo no ha sido verificado!",
              "Por favor verifica tu correo",
            ),
          );
        print("El correo no ha sido verificado");
        return;
      }else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            CustomSnackbar.error(
              "❓¡Error desconocido!",
              "Se recomienda reiniciar la app y actualizarla",
            ),
          );
        print("Error desconocido");
      }
    } catch (e) {
      print("Excepción capturada: $e");
    }


  }
}

