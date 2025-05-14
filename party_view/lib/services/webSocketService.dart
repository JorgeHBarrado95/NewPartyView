import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:party_view/models/sala.dart';
import 'package:party_view/widget/customSnackBar.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketServicio {
  WebSocketChannel? _channel;


  //String _url = "ws://servidorsocket-r8mu.onrender.com"; // Cambia esto a tu URL de WebSocket
  String _url = "ws://localhost:8081"; // Cambia 'https' por 'wss'

  void conexion(BuildContext context) async {
    _channel = WebSocketChannel.connect(Uri.parse(_url));
    _escucha(context);
  }

  void _escucha(BuildContext context) {
    _channel?.stream.listen(
      (message) {
        final data = jsonDecode(message);
        final type = data['type'];
        final contenido = data["contenido"];

        switch (type) {
          case "error":
            print("⚠️ Error: ");
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                CustomSnackbar.error(
                  "Error",
                  "${data["message"]}",
                ),
              );
            break;
          case 'invitado-join':
            print("👤 Nuevo invitado: ${contenido['nombre']}");
            break;
          case 'signal':
            print("📡 Signal recibido: $contenido");
            break;
          case "sala-creada":
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                CustomSnackbar.info(
                  "Sala creada",
                  "${data["message"]}",
                ),
              );

            Navigator.pushNamed(
              context,
              "/salaEspera",
            );
            break;
          case "conexion":
            print("🔔 $data");
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
    _mandarMensaje('leave-room', {
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
}