import 'package:flutter/material.dart';
import 'package:party_view/models/usuarioLogin.dart';
import 'package:party_view/provider/personaProvider.dart';
import 'package:party_view/services/loginService.dart';
import 'package:party_view/widget/customSnackBar.dart';
import 'package:provider/provider.dart';

class Registrovalidacion {
  Future<void> registro(BuildContext context, String nombre, String correo, String contrasena, String confirmarContrasena) async {
    final RegExp _gmailValidacion = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );

    if (nombre.isEmpty || correo.isEmpty || contrasena.isEmpty || confirmarContrasena.isEmpty) {
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

    if (contrasena.length < 6) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          CustomSnackbar.error(
            "🔒 La contraseña debe tener al menos 6 caracteres",
            "",
          ),
        );
      return;
    }

    if (contrasena != confirmarContrasena) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          CustomSnackbar.error(
            "🔑 Las contraseñas no coinciden",
            "",
          ),
        );
      return;
    }
    
    //Creo el objeto UsuarioLogin
    UsuarioLogin _usuarioLogin = UsuarioLogin(
      nombre: nombre,
      correo: correo,
      contrasena: contrasena,
    );
    
    //Creo el provider de Persona
    final personaProvider = Provider.of<PersonaProvider>(
    context,
    listen: false,
    );

    //Llamo al servicio de registro, al cual le paso el objeto UsuarioLogin
    try {
        int estadoRegistro = await Loginservice(
          personaProvider, context,
        ).registro(_usuarioLogin);

        if (estadoRegistro == 0) {
          Navigator.pushNamed(context, "/principal");
          print("Registro exitoso");
        } else if (estadoRegistro == 3) {
          print("El correo ya está en uso");

          ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            CustomSnackbar.error(
              "📧 El correo ya está en uso",
              "",
            ),
          );
          return;
        } else if (estadoRegistro == 1) {
          print("Error en el registro");

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              CustomSnackbar.error(
                "❌ Error en el registro",
                "Reinicia la app y vuelve a intentarlo",
              ),
            );
          return;
        } else if (estadoRegistro == 2) {
          print("Error en la contraseña o @");

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              CustomSnackbar.error(
                "🔑 Error en la contraseña o gmail",
                "",
              ),
            );
          return;
        } else {
          print("Error desconocido");

          ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            CustomSnackbar.error(
              "❓ Error desconocido",
              "Se recomienda reiniciar la app y actualizarla",
            ),
          );
        }
      } catch (e) {
        print(e);
      }
  }
}