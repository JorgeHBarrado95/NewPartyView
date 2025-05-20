import 'package:flutter/material.dart';
import 'package:party_view/models/persona.dart';
import 'package:party_view/services/loginService.dart';

//COMO INICIALIZAR EL PROVIDER
//final personaProvider = Provider.of<PersonaProvider>(
//  context,
//  listen: false,
//);

/// Proveedor de ejemplo para manejar un contador.
class PersonaProvider with ChangeNotifier {
  Persona? _persona; 
  String _nombre = ""; 
  String _token = "";

  Persona? get getPersona => _persona;
  String get getNombre => _nombre;
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

  void setFotoUrl(String url) {
    if (_persona != null) {
      _persona!.fotoUrl = url;
    }
    notifyListeners();
  }

  Future<void> crearPersona(String nombre, String uid, String token) async {
    _persona = Persona(nombre: nombre, esAnfitrion: false, uid: uid); 
    _token = token;
    print("persona creada");
  }

}
