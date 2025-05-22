import 'package:flutter/material.dart';
import 'package:party_view/models/persona.dart';
import 'package:party_view/services/loginService.dart';

class PersonaProvider with ChangeNotifier {
  Persona? _persona; 
  String _nombre = ""; 
  String _token = "";

  Persona? get getPersona => _persona;
  String get getNombre => _nombre;
  String get getToken => _token;
  bool get esAnfitrion => _persona?.esAnfitrion ?? false;

  Future<void> setNombre(String nuevoNombre, BuildContext context) async {
    print(_token);
    _nombre = nuevoNombre;
    _persona!.nombre = nuevoNombre;
    Loginservice _loginService = Loginservice();
    await _loginService.cambiarNombre(nuevoNombre, _token, false, context); 
    notifyListeners(); 
  }

  set esAnfitrion(bool esAnfitrion) {
    _persona!.esAnfitrion = esAnfitrion; 
    notifyListeners(); 
  }

  set setToken(String token) {
    _token = token;
    notifyListeners(); 
  }

  Future<void> setFotoUrl(String url, BuildContext context) async {
    _persona!.url = url;
    notifyListeners();

    Loginservice _loginService = Loginservice();
    await _loginService.cambiarFoto(url, _token,false,context);
   
  }

  Future<void> crearPersona(String nombre, String uid, String token,String url) async {
    _persona = Persona(nombre: nombre, esAnfitrion: false, uid: uid, url: url); 
    _token = token;
    print("persona creada");
  }
}
