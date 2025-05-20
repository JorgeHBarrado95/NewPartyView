import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:party_view/services/webSocketService.dart';

class ReproduccionInvitado extends StatefulWidget {
  @override
  _ReproduccionInvitadoState createState() => _ReproduccionInvitadoState();
}

class _ReproduccionInvitadoState extends State<ReproduccionInvitado> {
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _connected = false;
  String? _error;
  bool _rendererInitialized = false;

  @override
  void initState() {
    super.initState();
    _initRenderer();
    WebSocketServicio().onRemoteStream = (MediaStream stream) async {
      print('Invitado: Recibido stream remoto con ${stream.getVideoTracks().length} pistas de video');
      if (stream.getVideoTracks().isNotEmpty) {
        final videoTrack = stream.getVideoTracks()[0];
        print('Invitado: video track id: ${videoTrack.id}, enabled: ${videoTrack.enabled}, muted: ${videoTrack.muted}');
      } else {
        print('Invitado: No hay pistas de video en el stream remoto');
      }
      await _waitRendererInitialized();
      if (!mounted) return;
      setState(() {
        _remoteRenderer.srcObject = stream;
        _connected = true;
        _error = null;
      });
    };
  }

  Future<void> _initRenderer() async {
    await _remoteRenderer.initialize();
    _rendererInitialized = true;
  }

  Future<void> _waitRendererInitialized() async {
    while (!_rendererInitialized) {
      await Future.delayed(Duration(milliseconds: 10));
    }
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    WebSocketServicio().onRemoteStream = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('[INVITADO][BUILD] _connected=$_connected, _error=$_error, rendererInitialized=$_rendererInitialized');
    if (_connected) {
      print('[INVITADO][BUILD] Renderer textureId: ${_remoteRenderer.textureId}, srcObject: ${_remoteRenderer.srcObject}');
    }
    return Scaffold(
      appBar: AppBar(title: Text('Viendo transmisión del anfitrión')),
      body: Center(
        child: _error != null
            ? Text('Error: $_error', style: TextStyle(color: Colors.red))
            : _connected
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: RTCVideoView(
                      _remoteRenderer,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                      mirror: false,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Esperando transmisión del anfitrión...'),
                    ],
                  ),
      ),
    );
  }
}
