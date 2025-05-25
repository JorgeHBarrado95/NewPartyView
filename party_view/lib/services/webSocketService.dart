import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:party_view/models/sala.dart';
import 'package:party_view/provider/SalaProvider.dart';
import 'package:party_view/provider/personaProvider.dart';
import 'package:party_view/services/gestorSalasService.dart';
import 'package:party_view/widget/customSnackBar.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebSocketServicio {
  static final WebSocketServicio _instance = WebSocketServicio._internal();
  factory WebSocketServicio() => _instance;
  WebSocketServicio._internal();

  WebSocketChannel? _channel;

  String _url = "ws://localhost:8080"; 
  //String _url ="ws://servidorsocket-r8mu.onrender.com";

  // --- WebRTC Signaling ---
  final Map<String, RTCPeerConnection> _peerConnections = {};
  MediaStream? _localStream;
  Function(MediaStream stream)? onRemoteStream;

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
          case 'signal':
            final contenido = data['contenido'] ?? data['payload'] ?? {};
            print('[SIGNAL] Mensaje recibido: $contenido');
            final from = contenido['from']?.toString() ?? '';
            final to = contenido['to']?.toString() ?? '';
            final signalData = contenido['signalData'] ?? {};
            final salaProvider = Provider.of<SalaProvider>(context, listen: false);
            final salaId = salaProvider.sala?.id;
            if (signalData['type'] == 'offer') {
              await handleOferta(salaId!, from, to, signalData);
            } else if (signalData['type'] == 'answer') {
              await handleRespuesta(from, signalData);
            } else if (signalData['candidate'] != null) {
              await handleCandidate(from, signalData['candidate']);
            }
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
          "❗ Error",
          "${data["message"]}",
        ),
      );
  }

  void _handleInvitadoUnido(BuildContext context, dynamic contenido) async {
    print("👤 Nuevo invitado: " + contenido['nombre']);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.info(
          "🙋 Nuevo invitado",
          "${contenido['nombre']} está ahora con nosotros!!",
          leading: Icon(Icons.person_add, color: Colors.blue, size: 28),
        ),
      );
    final _salaProvider = Provider.of<SalaProvider>(context, listen: false);
    await _salaProvider.actualizarInvitados();

    final sala = _salaProvider.sala;
    final personaProvider = Provider.of<PersonaProvider>(context, listen: false);
    
    if (sala != null && personaProvider.esAnfitrion && _localStream != null) {
      final anfitrionUid = sala.anfitrion.uid;
      final nuevoInvitadoUid = contenido['uid'];
      await _crearOfertaInvitado(sala.id, anfitrionUid, nuevoInvitadoUid);
      print('Oferta enviada al nuevo invitado: ' + nuevoInvitadoUid);
    }
  }

  void _handleUnidoCorrectamente(BuildContext context, dynamic data) async {
    print("👤 Unido correctamente a la sala: #${data['salaId']}");
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.info(
          "✅ Uniéndote a la sala...",
          "${data["message"]}",
          leading: Icon(Icons.login, color: Colors.green, size: 28),
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
          "🚫 Invitado expulsado",
          "${data['message']}",
          leading: Icon(Icons.person_remove, color: Colors.red, size: 28),
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
          "❌ Expulsado",
          "${data['message']}",
          leading: Icon(Icons.block, color: Colors.redAccent, size: 28),
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
          "🎉 Sala creada",
          "${data["message"]} ¡Invita a tus amigos! 🥳",
          leading: Icon(Icons.celebration, color: Colors.deepPurple, size: 28),
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
          "🎬 Sala iniciada",
          "${data["message"]}",
          leading: Icon(Icons.play_circle_fill, color: Colors.green, size: 28),
        ),
      );
    Navigator.pushNamed(context, "/reproduccionInvitado");
  }

  void _handleSalisteSala(BuildContext context, dynamic data) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.info(
          "🚪 Abandonaste la sala",
          "${data['message']}",
          leading: Icon(Icons.exit_to_app, color: Colors.grey, size: 28),
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
          "👋 Invitado salió",
          "${data['message']}",
          leading: Icon(Icons.person_off, color: Colors.orange, size: 28),
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
          "👑 El anfitrión abandonó",
          "${data['message']}",
          leading: Icon(Icons.king_bed, color: Colors.purple, size: 28),
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

  void mandarSenal({
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

  /// Cierra todas las PeerConnections y limpia el stream local
  Future<void> closeAllPeerConnections() async {
    for (final pc in _peerConnections.values) {
      try {
        await pc.close();
      } catch (e) {
        print('Error cerrando PeerConnection: ' + e.toString());
      }
    }
    _peerConnections.clear();
    try {
      await _localStream?.dispose();
    } catch (e) {
      print('Error limpiando localStream: ' + e.toString());
    }
    _localStream = null;
  }


  Future<void> empezarTransmision(String salaId, String anfitrionUid, List<String> invitadosUids, MediaStream stream) async {
    _localStream = stream;
    for (final uid in invitadosUids) {
      await _crearOfertaInvitado(salaId, anfitrionUid, uid);
    }
  }

  /// Esto permite que el anfitrión comparta su stream con cada invitado de la sala.
  Future<void> _crearOfertaInvitado(String salaId, String from, String to) async {
     // 1. Crea una nueva PeerConnection con un servidor STUN público.
    final pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    });

      // 2. Guarda la PeerConnection en el mapa usando el UID del invitado.
    _peerConnections[to] = pc;

    // 3. Si hay un stream local (pantalla/cámara del anfitrión), añade todos sus tracks a la conexión.
    if (_localStream != null) {
      // Usar addTrack en vez de addStream para Unified Plan
      for (var track in _localStream!.getTracks()) {
        print('[ANFITRION] Añadiendo track al peer $to: id=${track.id}, kind=${track.kind}, enabled=${track.enabled}, muted=${track.muted}');
        await pc.addTrack(track, _localStream!);
      }
    } else {
      print('[ANFITRION][ERROR] _localStream es null al crear la oferta para $to');
    }
      // 4. Comprueba si la conexión está cerrada antes de continuar.
    if (pc.connectionState == 'closed') {
      print('[ANFITRION][ERROR] peerConnection $to está cerrado antes de crear la oferta');
    }
    // 5. Crea la oferta SDP para iniciar la conexión.
    final offer = await pc.createOffer({
      'offerToReceiveVideo': 1,
      'offerToReceiveAudio': 1,
      'voiceActivityDetection': false,
      'mandatory': {},
      'optional': [],
    });
    // 6. Establece la descripción local con la oferta creada.
    await pc.setLocalDescription(RTCSessionDescription(offer.sdp!, offer.type));
    // 7. Envía la oferta SDP al invitado usando señalización WebSocket.
    mandarSenal(roomId: salaId, from: from, to: to, signalData: {'sdp': offer.sdp, 'type': offer.type});
  }

  /// Establece la conexión WebRTC con el anfitrión y responde con una answer SDP.
  Future<void> handleOferta(String salaId, String from, String to, Map offer) async {
    print('[INVITADO] Recibida oferta de $from para $to en sala $salaId');

      //Crea una nueva PeerConnection con un servidor STUN público.
    final pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    });
      //Guarda la PeerConnection en el mapa usando el UID del anfitrión.
    _peerConnections[from] = pc;
    // Configura para recibir el stream remoto. (Tracks)
    pc.onTrack = (RTCTrackEvent event) {
      print('[INVITADO] onTrack recibido, streams: ${event.streams.length}');
      if (event.streams.isNotEmpty && onRemoteStream != null) {
        print('[INVITADO] Llamando a onRemoteStream con el stream remoto');
        onRemoteStream!(event.streams[0]);
      }
    };

    // Establece la descripción remota con la oferta recibida del anfitrión.
    await pc.setRemoteDescription(RTCSessionDescription(offer['sdp'], offer['type']));
      
    //Crea una respuesta SDP (answer) ç
    final answer = await pc.createAnswer();
    //Establece la descripción local con la answer creada.
    await pc.setLocalDescription(answer);
    print('[INVITADO] Enviando answer al anfitrión');
     //Envía la answer SDP al anfitrión usando señalización WebSocket.
    mandarSenal(roomId: salaId, from: to, to: from, signalData: {'sdp': answer.sdp, 'type': answer.type});
  }

  Future<void> handleRespuesta(String from, Map answer) async {
    final pc = _peerConnections[from];
    if (pc != null) {
      await pc.setRemoteDescription(RTCSessionDescription(answer['sdp'], answer['type']));
    }
  }

  Future<void> handleCandidate(String from, Map candidate) async {
    final pc = _peerConnections[from];
    if (pc != null) {
      await pc.addCandidate(RTCIceCandidate(candidate['candidate'], candidate['sdpMid'], candidate['sdpMLineIndex']));
    }
  }
}