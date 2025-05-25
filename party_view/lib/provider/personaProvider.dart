import 'package:flutter/material.dart';
import 'package:party_view/models/persona.dart';
import 'package:party_view/services/loginService.dart';

class PersonaProvider with ChangeNotifier {
  // Instancia de la persona (usuario logueado)
  Persona? _persona; 
  String _token = "";

  Persona? get getPersona => _persona;
  String get getToken => _token;
  bool get esAnfitrion => _persona?.esAnfitrion ?? false;

  // Cambia el nombre del usuario y lo actualiza en el backend
  Future<void> setNombre(String nuevoNombre, BuildContext context) async {
    //print(_token);
    _persona!.nombre = nuevoNombre;
    Loginservice _loginService = Loginservice();
    await _loginService.cambiarNombre(nuevoNombre, _token, false, context); 
    notifyListeners(); 
  }

  // Setter para cambiar el estado de anfitrión
  set esAnfitrion(bool esAnfitrion) {
    _persona!.esAnfitrion = esAnfitrion; 
    notifyListeners(); 
  }

  // Setter para actualizar el token
  set setToken(String token) {
    _token = token;
    notifyListeners(); 
  }

  // Cambia la foto de perfil y la actualiza en el backend
  Future<void> setFotoUrl(String url, BuildContext context) async {
    _persona!.url = url;
    notifyListeners();

    Loginservice _loginService = Loginservice();
    await _loginService.cambiarFoto(url, _token,false,context);
  }

  // Crea una nueva persona (usuario) y guarda el token
  Future<void> crearPersona(String nombre, String uid, String token,String url) async {
    _persona = Persona(nombre: nombre, esAnfitrion: false, uid: uid, url: url); 
    _token = token;
    print("persona creada");
  }
}
