import 'dart:io';

import 'package:flutter/material.dart';
import 'package:party_view/provider/SalaProvider.dart';
import 'package:party_view/provider/personaProvider.dart';
import 'package:party_view/screen/Registro/verificarCorreo.dart';
import 'package:party_view/screen/Reproduccion/reproduccionAnfitrion.dart';
import 'package:party_view/screen/Reproduccion/reproduccionInvitado.dart';
import 'package:party_view/screen/perfil.dart';
import 'package:party_view/screen/principal.dart';
import 'package:party_view/screen/Registro/login.dart';
import 'package:party_view/screen/Registro/registro.dart';
import 'package:party_view/screen/salaEspera.dart';


import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isWindows || Platform.isLinux) {
      setWindowTitle('Party View');
      setWindowMinSize(const Size(1280, 730)); 
      setWindowMaxSize(const Size(1280, 730)); 
    }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SalaProvider()),
        ChangeNotifierProvider(create: (context) => PersonaProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Ruta de la aplicación
      initialRoute: "/login",
      routes: {
        "/login": (context) => LoginScreen(),
        "/registro": (context) => RegistroScreen(),
        "/verificarCorreo": (context) => VerificarCorreoScreen(),
         "/salaEspera": (context) => SalaEspera(),
         "/principal": (context) => Principal(),
         "/perfil": (context) => PerfilScreen(),
         "/reproduccion": (context) => ReproduccionAnfitrion(),
         "/reproduccionInvitado": (context) => ReproduccionInvitado(),

      },
    );
  }
}
