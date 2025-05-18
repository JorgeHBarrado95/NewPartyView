import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:party_view/models/sala.dart';
import 'package:party_view/provider/SalaProvider.dart';
import 'package:party_view/provider/personaProvider.dart';
import 'package:party_view/services/gestorSalasService.dart';
import 'package:party_view/widget/customSnackBar.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketServicio {
  static final WebSocketServicio _instance = WebSocketServicio._internal();
  factory WebSocketServicio() => _instance;
  WebSocketServicio._internal();

  WebSocketChannel? _channel;

  String _url = "ws://localhost:8081"; // Cambia 'https' por 'wss'

  void conexion(BuildContext context) async {
    _channel = WebSocketChannel.connect(Uri.parse(_url));
    _escucha(context);
  }

  void _escucha(BuildContext context) {
    _channel?.stream.listen(
      (message) async {
        final data = jsonDecode(message);
        final type = data['type'];
        final contenido = data["contenido"];
        switch (type) {
          case "error":
            _handleError(context, data);
            break;
          case "invitado-unido":
            _handleInvitadoUnido(context, contenido);
            break;
          case "unido-correctamente":
            _handleUnidoCorrectamente(context, data);
            break;
          case "actualizacion-sala":
            _handleActualizacionSala(context);
            break;
          case "invitado-expulsado-bloqueado":
            _handleInvitadoExpulsadoBloqueado(context, data);
            break;
          case "expulsado":
            _handleExpulsado(context, data);
            break;
          case "sala-creada":
            _handleSalaCreada(context, data);
            break;
          case "videoON":
            _handleVideoON(context, data);
            break;
          case "conexion":
            print("🔔 $data");
            break;
          case "saliste-sala":
            _handleSalisteSala(context, data);
            break;
          case "invitado-salio":
            _handleInvitadoSalio(context, data);
            break;
          case "salio-anfitrion":
            _handleSalioAnfitrion(context, data);
            break;
          default:
            print("🔔 Mensaje recibido: $data");
        }
      },
      onDone: () {
        print("🔌 Conexión cerrada");
      },
      onError: (error) {
        print("❌ Error de conexión: $error");
      },
    );
  }

  void _handleError(BuildContext context, dynamic data) {
    print("⚠️ Error: ");
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.error(
          "Error",
          "${data["message"]}",
        ),
      );
  }

  void _handleInvitadoUnido(BuildContext context, dynamic contenido) {
    print("👤 Nuevo invitado: " + contenido['nombre']);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.info(
          "Nuevo invitado",
          "${contenido['nombre']} esta ahora con nosotros!!",
        ),
      );
    final _salaProvider = Provider.of<SalaProvider>(context, listen: false);
    _salaProvider.actualizarInvitados();
  }

  void _handleUnidoCorrectamente(BuildContext context, dynamic data) async {
    print("👤 Unido correctamente a la sala: #${data['salaId']}");
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.info(
          "Uniendote a la sala...",
          "${data["message"]}",
        ),
      );
    final _salaProvider = Provider.of<SalaProvider>(context, listen: false);
    GestorSalasService _gestorSalasService = GestorSalasService();
    final sala = await _gestorSalasService.obtenerSala(data['salaId']);
    _salaProvider.setSala(sala);
    Navigator.pushNamed(context, "/salaEspera");
  }

  void _handleActualizacionSala(BuildContext context) async {
    print("Se ha actualizado la sala");
    final _salaProvider = Provider.of<SalaProvider>(context, listen: false);
    await _salaProvider.actualizarSala();
  }

  void _handleInvitadoExpulsadoBloqueado(BuildContext context, dynamic data) {
    print("👤 Invitado expulsado");
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.info(
          "Invitado expulsado",
          "${data['message']}",
        ),
      );
    final salaProvider = Provider.of<SalaProvider>(context, listen: false);
    salaProvider.actualizarInvitados();
  }

  void _handleExpulsado(BuildContext context, dynamic data) {
    print("👤 Expulsado de la sala");
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.info(
          "Expulsado",
          "${data['message']}",
        ),
      );
    Navigator.pushNamedAndRemoveUntil(context, "/principal", (route) => false);
    Provider.of<SalaProvider>(context, listen: false).clearSala();
  }

  void _handleSalaCreada(BuildContext context, dynamic data) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.info(
          "Sala creada",
          "${data["message"]}",
        ),
      );
    Navigator.pushNamed(context, "/salaEspera");
  }

  void _handleVideoON(BuildContext context, dynamic data) {
    print("🔔 Video activado");
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.info(
          "Sala iniciada",
          "${data["message"]}",
        ),
      );
    // Navigator.pushNamed(context, "/reproduccion");
  }

  void _handleSalisteSala(BuildContext context, dynamic data) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.info(
          "Abandonaste la sala",
          "${data['message']}",
        ),
      );
    Navigator.pushNamedAndRemoveUntil(context, "/principal", (route) => false);
    final personaProvider = Provider.of<PersonaProvider>(context, listen: false);
    personaProvider.esAnfitrion = false;
    Provider.of<SalaProvider>(context, listen: false).clearSala();
  }

  void _handleInvitadoSalio(BuildContext context, dynamic data) {
    print("👤 Invitado salio de la sala");
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.info(
          "Invitado salio",
          "${data['message']}",
        ),
      );
    final salaProvider = Provider.of<SalaProvider>(context, listen: false);
    salaProvider.actualizarInvitados();
  }

  void _handleSalioAnfitrion(BuildContext context, dynamic data) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.info(
          "Abandonando sala",
          "${data['message']}",
        ),
      );
    Navigator.pushNamedAndRemoveUntil(context, "/principal", (route) => false);
    Provider.of<SalaProvider>(context, listen: false).clearSala();
  }

  void crearSala(Sala sala) {
    _mandarMensaje("crear-sala", {
      "id": sala.id,
      "estado": sala.estado,
      "capacidad": sala.capacidad,
      "video": sala.video,
      "anfitrion": sala.anfitrion.toJson(),
    });
  }

  void unirseSala({
    required String id,
    required Map<String, dynamic> persona,
  }) {
    _mandarMensaje("unirse-sala", {
      "id-sala": id,
      "persona": persona,
    });
  }

  void sendSignal({
    required String roomId,
    required String from,
    required String to,
    required dynamic signalData,
  }) {
    _mandarMensaje('signal', {
      'roomId': roomId,
      'from': from,
      'to': to,
      'signalData': signalData,
    });
  }

  void salirSala({
    required String roomId,
    required String uid,
  }) {
    _mandarMensaje('abandonar-sala', {
      'roomId': roomId,
      'uid': uid,
    });
  }

  void _mandarMensaje(String type, Map<String, dynamic> payload) {
    if (_channel == null) {
      print("⚠️ No conectado o sin token");
      return;
    }

    final message = jsonEncode({
      'type': type,
      'payload': payload,
    });

    _channel?.sink.add(message);
  }

  void disconnect() {
    _channel?.sink.close();
  }

  void incrementarCapacidad(String salaId) {
    print("object");

    _mandarMensaje("subir-capacidad", {
      "salaId": salaId,
    });
  }

  void disminuirCapacidad(String salaId) {
    _mandarMensaje("bajar-capacidad", {
      "salaId": salaId,
    });
  }

  void cambiarEstado(String salaId, String estado) {
    _mandarMensaje("cambiar-estado", {
      "salaId": salaId,
      "estado": estado,
    });
  }

  void expulsarInvitado(String salaId, String uid) {
    _mandarMensaje("expulsar-invitado", {
      "salaId": salaId,
      "uid": uid,
    });
  }

  void bloquearInvitado(String salaId, String uid) {
    _mandarMensaje("bloquear-invitado", {
      "salaId": salaId,
      "uid": uid,
    });
  }

  void video(String salaId) {
    _mandarMensaje("videoON", {
      "salaId": salaId,
    });
  }

  void abandonarSala(String salaId, String uid) {
    _mandarMensaje("abandonar-sala", {
      "salaId": salaId,
      "uid": uid,
    });
  }
}