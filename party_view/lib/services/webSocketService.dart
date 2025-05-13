import 'dart:convert';
import 'package:party_view/models/sala.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketServicio {
  WebSocketChannel? _channel;
  String? _token;

  //String _url = "ws://servidorsocket-r8mu.onrender.com"; // Cambia esto a tu URL de WebSocket
  String _url = "ws://localhost:8080"; // Cambia 'https' por 'wss'

  void conexion(String token ) async {
    _token = token;
    _channel = WebSocketChannel.connect(Uri.parse(_url));
    _escucha();
  }

  void _escucha() {
    _channel?.stream.listen(
      (message) {
        final data = jsonDecode(message);
        final type = data['type'];
        final payload = data['payload'];

        switch (type) {
          case 'error':
            print("⚠️ Error: ${data['message']}");
            break;
          case 'invitado-join':
            print("👤 Nuevo invitado: ${payload['nombre']}");
            break;
          case 'signal':
            print("📡 Signal recibido: $payload");
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
      'id': id,
      'persona': persona,
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
    if (_channel == null || _token == null) {
      print("⚠️ No conectado o sin token");
      return;
    }

    payload['token'] = _token;

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