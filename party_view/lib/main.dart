import 'package:flutter/material.dart';
import 'package:party_view/provider/SalaProvider.dart';
import 'package:party_view/provider/personaProvider.dart';
import 'package:party_view/screen/principal.dart';
import 'package:party_view/screen/Registro/login.dart';
import 'package:party_view/screen/Registro/registro.dart';
import 'package:party_view/screen/salaEspera.dart';


import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SalaProvider()),
        ChangeNotifierProvider(create: (_) => PersonaProvider()),
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
         "/principal": (context) => Principal(),
         "/salaEspera": (context) => SalaEspera(),
        // "/reproduccion": (context) => ReproduccionAnfitrion(),
      },
    );
  }
}
