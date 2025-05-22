import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:party_view/models/persona.dart';
import 'package:party_view/models/sala.dart';
import 'package:party_view/services/gestorSalasService.dart';
import 'package:party_view/services/webSocketService.dart';


/// Proveedor que gestiona el estado de una sala y su sincronización con la base de datos.
class SalaProvider with ChangeNotifier {
  final GestorSalasService _gestorSalasService = GestorSalasService();
  Sala? _sala; // Sala actual gestionada por el proveedor.

  /// Obtiene la sala actual.
  Sala? get sala => _sala;

  /// Establece una nueva sala y notifica a los widgets que el estado ha cambiado.
  ///
  /// [sala] La nueva sala a establecer.
  void setSala(Sala sala) {
    _sala = sala;
    notifyListeners();
  }

  /// Limpia la sala actual y notifica a los widgets.
  void clearSala() {
    _sala = null;
    notifyListeners();
  }

  /// Incrementa la capacidad de la sala en 1 y sincroniza con la base de datos.
  void incrementarCapacidad() {
    _sala!.capacidad++;
    notifyListeners();
    WebSocketServicio _webSocketServicio = WebSocketServicio();
    _webSocketServicio.incrementarCapacidad(_sala!.id);
  }

  /// Disminuye la capacidad de la sala en 1 si es mayor a 2 y sincroniza con la base de datos.
  void disminuirCapacidad() {
    if (_sala!.capacidad > 2) {
      _sala!.capacidad--;
      notifyListeners();
      WebSocketServicio _webSocketServicio = WebSocketServicio();
      _webSocketServicio.disminuirCapacidad(_sala!.id);
    }
  }

  /// Cambia el estado de la sala y sincroniza con la base de datos.
  ///
  /// [estado] El nuevo estado de la sala.
  void estado(String estado) {
    _sala!.estado = estado;
    notifyListeners();
    WebSocketServicio _webSocketServicio = WebSocketServicio();
    _webSocketServicio.cambiarEstado(_sala!.id, estado);
  }

  /// Crea una nueva sala con un ID aleatorio y configura sus valores iniciales.
  Future<void> crearSala(Persona persona) async {
    _sala = Sala(
      id: await idSalaComp(), // Genera un ID único para la sala.
      capacidad: 5,
      video: true,
      estado: "Abierto",
      anfitrion: persona,
      invitados: [],
      bloqueados: [],
    );
    notifyListeners();
  }

  /// Genera un ID aleatorio para la sala y verifica que no exista en la base de datos.
  ///
  /// Retorna un [String] con el ID generado.
  Future<String> idSalaComp() async {
    final random = Random();
    bool _idMal = true;
    String _randIdString = "";
    while (_idMal) {
      int _randId = random.nextInt(100000);
      _randIdString = _randId.toString().padLeft(
        5,
        "0",
      ); // Asegura que el ID tenga 5 dígitos.

      if (await _gestorSalasService.comprobarSiExiste(_randIdString) !=
          "null") {
        _idMal = false; // Si el ID no existe, sale del bucle.
      }
    }
    return _randIdString;
  }

  Future<void> eliminarInvitado(Persona persona) async {
    _sala!.invitados.removeWhere((invitado) => invitado == persona);
    await _gestorSalasService.actualizarSala(_sala!);
    Future.microtask(
      () => notifyListeners(),
    ); // se asegura que se ejecute después

    WebSocketServicio _webSocketServicio = WebSocketServicio();
    _webSocketServicio.expulsarInvitado(_sala!.id, persona.uid);
  }

  Future<void> bloquearPersona(Persona persona) async {
    _sala!.bloqueados.add(persona);
    eliminarInvitado(persona);

    WebSocketServicio _webSocketServicio = WebSocketServicio();
    _webSocketServicio.bloquearInvitado(_sala!.id, persona.uid);
  }

  //Actualizamos invitados cuando se notifica desde el socket
  Future<void> actualizarInvitados() async {
    GestorSalasService _gestorSalasService = GestorSalasService();

    _sala!.invitados =
        await _gestorSalasService.obtenerInvitados(_sala!.id);
    notifyListeners();
  }

  Future<void> actualizarSala() async {
    if (sala == null) return;
    final nuevaSala = await GestorSalasService().obtenerSala(sala!.id);
    setSala(nuevaSala);
  }
}
