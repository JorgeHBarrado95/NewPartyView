import 'dart:io';

import 'package:flutter/material.dart';
import 'package:party_view/models/persona.dart';

//COMO INICIALIZAR EL PROVIDER
//final personaProvider = Provider.of<PersonaProvider>(
//  context,
//  listen: false,
//);

/// Proveedor de ejemplo para manejar un contador.
class PersonaProvider with ChangeNotifier {
  Persona? _persona; // Define la variable 'persona'.
  String _nombre = ""; // Define la variable 'nombre'.

  // Getter para 'persona'.
  Persona? get getPersona => _persona;

  // Getter para 'nombre'.
  String get getNombre => _nombre;

  // Setter para 'nombre'.
  set setNombre(String nuevoNombre) {
    _nombre = nuevoNombre;
    notifyListeners(); // Notifica a los oyentes sobre el cambio.
  }

  Future<void> crearPersona(String nombre, String uid, String token) async {
    // Cambia a Future para manejar la asincronía.
    _persona = Persona(nombre: nombre, esAnfitrion: false, uid: uid,token: token); // Crea y asigna la persona.
    print("persona creada");
  }

}
