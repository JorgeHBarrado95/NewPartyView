import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:party_view/models/sala.dart';
import 'package:party_view/provider/SalaProvider.dart';
import 'package:party_view/services/gestorSalasService.dart';
import 'package:party_view/widget/customSnackBar.dart';
import 'package:provider/provider.dart';
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
      (message) async { // <-- Hacemos la función async
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
          case "invitado-unido": //Notificacion para el anfitrion
            print("👤 Nuevo invitado: ${contenido['nombre']}");

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                CustomSnackbar.info(
                  "Nuevo invitado",
                  "${contenido['nombre']} esta ahora con nosotros!!",
                ),
              );
            //Actualizamos la lista de invitados
            final _salaProvider = Provider.of<SalaProvider>(
              context,
              listen: false,
            );

            _salaProvider.actualizarInvitados();

            break;

          case "unido-correctamente": //Notificaacion para el invitado
            print("👤 Unido correctamente a la sala: #${data['salaId']}");

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                CustomSnackbar.info(
                  "Uniendote a la sala...",
                  "${data["message"]}",
                ),
              );
            
            final _salaProvider = Provider.of<SalaProvider>(
              context,
              listen: false,
            );

            GestorSalasService _gestorSalasService = GestorSalasService();
            final sala = await _gestorSalasService.obtenerSala(data['salaId']);
            _salaProvider.setSala(sala);

            Navigator.pushNamed(
              context,
              "/salaEspera",
            );

            break;
          //Cada vez q se une un invitado, se actualiza la sala
          // case "actualizacion-sala":
          //   print("Se ha actualizado la sala");
          //   final _salaProvider = Provider.of<SalaProvider>(
          //     context,
          //     listen: false,
          //   );
          //   await _salaProvider.actualizarSala();
          //   break;
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